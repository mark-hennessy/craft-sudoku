part of sudoku;

class SudokuSolver {

  Board board;

  List<GameState> gameStates = [];
  GameState get currentGameState => gameStates.last;

  SudokuSolver(Board this.board) {
    _resetGameStates();
  }

  void visualizeAlgorithm(bool solveAlgorithm(), [String title]) {
    _resetGameStates();
    solveAlgorithm();
    displayAllGameStates(title);
  }

  /**
   * The algorithm tries all available options for a cell in order.
   * If no solution works for the rest of the board, the algorithm
   * returns false (for “no solution”).
   *
   * Source: http://johannesbrodwall.com/2010/04/06/why-tdd-makes-a-lot-of-sense-for-sudoko/
   */
  bool bruteForceSolve([int cellIndex = 0]) {
    if (cellIndex >= Board.CELL_COUNT) return true;

    var cell = board.cells[cellIndex];

    if (cell.hasValue) return bruteForceSolve(cellIndex + 1);

    for(int value in cell.availableValues) {
      _setCellValue(cell, value);
      if (bruteForceSolve(cellIndex + 1)) return true;
    }

    cell.clearValue();
    return false;
  }

  /**
   * Fills in cells that only have one possible value until there are none left,
   * and then brute force the algorithm if it is not solved.
   */
  bool humanSolve() {
    var emptyCellsWithOnlyOneAvailableValue = board.emptyCellsWithOnlyOneAvailableValue;
    while(emptyCellsWithOnlyOneAvailableValue.length > 0) {
      for(var cell in emptyCellsWithOnlyOneAvailableValue) {
        _setCellValue(cell, cell.availableValues.first);
      }
      _snapshotGameState("Iteration");
      emptyCellsWithOnlyOneAvailableValue = board.emptyCellsWithOnlyOneAvailableValue;
    }

    if(!board.isSolved) {
      _snapshotGameState("Brute Force");
      return bruteForceSolve();
    }
    return true;
  }

  /**
   * The goal of this algorithm is to solve a Sudoku board in a similar sequence
   * to a beginner/intermediate human. An advanced player has a bag of tricks
   * which make him a lot smarter than this algorithm. Also, this algorithm is
   * quite slow and inefficient.
   */
  bool humanSequenceSolve() {
    var puzzleHasContradictions = !bruteForceSolve();
    if(puzzleHasContradictions) return false;
    var solvedBoard = new Board.fromPuzzle(board.cellValues);
    board.clearPuzzle();
    _snapshotGameState("Cells brute forced, then cleared");

    while(true) {
      var emptyCellsWithOnlyOneAvailableValue = board.emptyCellsWithOnlyOneAvailableValue;
      while(emptyCellsWithOnlyOneAvailableValue.length > 0) {
        for(var cell in emptyCellsWithOnlyOneAvailableValue) {
          _setCellValue(cell, cell.availableValues.first);
        }
        emptyCellsWithOnlyOneAvailableValue = board.emptyCellsWithOnlyOneAvailableValue;
      }
      _snapshotGameState("Empty cells w/ 1 val");

      var emptyCellsSorted = board.emptyCellsSortedByAvailableValuesAscending;
      var solved = emptyCellsSorted.isEmpty;
      if(solved) return true;

      var cellToFill = emptyCellsSorted.first;
      var value = solvedBoard.getCell(cellToFill.row, cellToFill.column).value;
      _setCellValue(cellToFill, value);
      _snapshotGameState("Guess");
    }
  }

  void displayAllGameStates([String title = ""]) {
    for(int i = 0; i < gameStates.length; i++) {
      var gameState = gameStates[i];

      var gameTitle = "$title - State $i";
      if(gameState.title != null) {
        gameTitle += " - ${gameState.title}";
      }

      var boardUI = new BoardUI(board);
      boardUI.renderGameState(gameState, gameTitle);
    }
  }

  void _setCellValue(Cell cell, int value) {
    cell.value = value;
    currentGameState.addChangedCell(cell);
  }

  void _resetGameStates() {
    gameStates.clear();
    gameStates.add(new GameState(board));
    //Snapshot the initial state before any cell values have changed.
    _snapshotGameState();
  }

  void _snapshotGameState([String title]) {
    currentGameState.title = title;
    currentGameState.freezeCellValues();
    gameStates.add(new GameState(board));
  }

}