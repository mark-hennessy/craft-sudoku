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
   * Algorithm has medium efficiency.
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
   * makes a guess, and then continues filling in cells that only have one
   * possible value until there are none left, then makes another guess and so on.
   * The algorithm undoes moves and tries a different guess if a contradiction is found.
   *
   * Algorithm has low efficiency.
   */
  bool humanSolve() {
    if(board.hasContradictions) return false;
    if(board.isSolved) return true;

    var modifiedCells = new Set<Cell>();

    var emptyCellsWithOnlyOneAvailableValue = board.emptyCellsWithOneAvailableValue;
    var cellValueMap = new Map<Cell, int>();
    for(var cell in emptyCellsWithOnlyOneAvailableValue) {
      cellValueMap[cell] = cell.availableValues.first;
    }
    for(var cell in cellValueMap.keys) {
      _setCellValue(cell, cellValueMap[cell]);
      modifiedCells.add(cell);
    }

    if(modifiedCells.length > 0) {
      if(humanSolve()) return true;
    } else {
      var emptyCell = board.emptyCellsSortedByAvailableValuesAscending.first;
      for(var value in emptyCell.availableValues) {
        _setCellValue(emptyCell, value);
        modifiedCells.add(emptyCell);
        if(humanSolve()) return true;
      }
    }

    modifiedCells.forEach((Cell c) => c.clearValue());
    return false;
  }

  /**
   * Fills in cells that only have one possible value until there are none left,
   * and then brute force the algorithm if it is not solved.
   *
   * Algorithm has low efficiency.
   */
  bool humanSolveThenBruteforce() {
    var emptyCellsWithOnlyOneAvailableValue = board.emptyCellsWithOneAvailableValue;
    while(emptyCellsWithOnlyOneAvailableValue.length > 0) {
      var cellValueMap = new Map<Cell, int>();
      for(var cell in emptyCellsWithOnlyOneAvailableValue) {
        cellValueMap[cell] = cell.availableValues.first;
      }
      for(var cell in cellValueMap.keys) {
        _setCellValue(cell, cellValueMap[cell]);
      }
      _snapshotGameState("Iteration");
      emptyCellsWithOnlyOneAvailableValue = board.emptyCellsWithOneAvailableValue;
    }

    if(board.isSolved) {
      return true;
    } else {
      _snapshotGameState("Brute Force");
      return bruteForceSolve();
    }
  }

  /**
   * The goal of this algorithm is to solve a Sudoku board in a similar sequence
   * to a beginner/intermediate human. An advanced player has a bag of tricks
   * which make him a lot smarter than this algorithm.
   *
   * Algorithm has low efficiency.
   */
  bool humanSequenceSolve() {
    var puzzleHasContradictions = !bruteForceSolve();
    if(puzzleHasContradictions) return false;
    var solvedBoard = new Board.fromPuzzle(board.cellValues);
    _snapshotGameState("Cells brute forced");
    board.clearPuzzle();

    while(true) {
      var emptyCellsWithOnlyOneAvailableValue = board.emptyCellsWithOneAvailableValue;
      while(emptyCellsWithOnlyOneAvailableValue.length > 0) {
        for(var cell in emptyCellsWithOnlyOneAvailableValue) {
          _setCellValue(cell, cell.availableValues.first);
        }
        emptyCellsWithOnlyOneAvailableValue = board.emptyCellsWithOneAvailableValue;
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