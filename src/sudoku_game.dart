library sudoku;

import 'dart:html';

part 'puzzle_parser.dart';
part 'board.dart';
part 'board_ui.dart';
part 'game_state.dart';
part 'style/css.dart';

part 'utils/io.dart';
part 'utils/collection_utils.dart';
part 'utils/string_utils.dart';
part 'utils/dom_utils.dart';
part 'utils/keyboard.dart';

void main() {
  var sudokuGame = new SudokuGame();
  sudokuGame.run();
}

class SudokuGame {
  Board board;
  BoardUI board_ui;
  List<List<int>> puzzles;
  
  List<GameState> gameStates = [];
  GameState get currentGameState => gameStates.last;
  
  SudokuGame() {
    board = new Board();
    puzzles = Parser.parseSudokuData(PUZZLES_EASY_50, separator: '==');
    _initializeUI();
  }
  
  void _initializeUI() {
    _initializeDebugInfo();
  }
  
  void _initializeDebugInfo() {
    query(CSS.CLEAR_DEBUG_OUTPUT_BUTTON_ID)
    ..onClick.listen((e) => IO.clearDebugInfo());
  }
  
  void run() {
    var puzzle = selectPuzzle();
    solve(puzzle, humanSolveAlgorithm, "Human Algorithm");
    solve(puzzle, bruteForceSolveAlgorithm, "Brute Force Algorithm");
  }
  
  List<int> selectPuzzle() {
    return puzzles[1];
  }
  
  void solve(List<int> puzzle, bool solveAlgorithm(), [String title]) {
    prepareGame(puzzle);
    solveAlgorithm();
    displayGame(title);
  }
  
  void prepareGame(List<int> puzzle) {
    board.puzzle = puzzle;
    resetGameStates();
  }
  
  void resetGameStates() {
    gameStates.clear();
    gameStates.add(new GameState(board));
    //Snapshot the initial state before any cell values have changed.
    //snapshotGameState();
  }
  
  void displayGame([String title = ""]) {
    for(int i = 0; i < gameStates.length; i++) {
      board.cellValues = gameStates[i].cellValues;
      board_ui = new BoardUI(board);
      board_ui.render("$title - State $i");
    }
  }
  
  /**
   * The algorithm tries all available options for a cell in order. 
   * If no solution works for the rest of the board, the algorithm 
   * returns false (for “no solution”).
   * 
   * Source: http://johannesbrodwall.com/2010/04/06/why-tdd-makes-a-lot-of-sense-for-sudoko/
   */
  bool bruteForceSolveAlgorithm([int cellIndex = 0]) {
    if (cellIndex >= Board.CELL_COUNT) return true;
    
    var cell = board.cells[cellIndex];

    if (cell.hasValue) return bruteForceSolveAlgorithm(cellIndex + 1);
    
    for(int value in cell.availableValues) {
      setCellValue(cell, value);
      if (bruteForceSolveAlgorithm(cellIndex + 1)) return true;
    }
    
    cell.clearValue();
    return false;
  }
  
  bool humanSolveAlgorithm() {
    var emptyCellsWithOnlyOnePossibleValue = board.emptyCellsWithOnlyOnePossibleValue;
    do {
      for(var cell in emptyCellsWithOnlyOnePossibleValue) {
        setCellValue(cell, cell.availableValues.first);
      }
      emptyCellsWithOnlyOnePossibleValue = board.emptyCellsWithOnlyOnePossibleValue;
    } while(emptyCellsWithOnlyOnePossibleValue.length > 0);
    
    if(board.hasContradictions) return false;
    
    if(!board.isSolved) {
      guess();
    }
  }
  
  void guess() {
    
  }
  
  void setCellValue(Cell cell, int value) {
    cell.value = value;
    currentGameState.addChangedCell(cell);
  }
  
  void addGameState() {
    currentGameState.freezeCellValues();
    gameStates.add(new GameState(board));
  }
  
  void removeLastGameState() {
    gameStates.removeLast();
    currentGameState.unfreezeCellValues();
  }
  
}