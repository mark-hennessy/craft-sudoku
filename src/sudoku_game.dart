library sudoku;

import 'dart:html';
import 'dart:async';

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
    solve(puzzle, humanSolve, "Human Algorithm");
//    solve(puzzle, bruteForceSolve, "Brute Force Algorithm");
  }

  List<int> selectPuzzle() {
    return puzzles[1];
  }

  void solve(List<int> puzzle, bool solveAlgorithm(Board board), [String title]) {
    prepareGame(puzzle);
    solveAlgorithm(board);
    displayAllGameStates(title);
  }

  void prepareGame(List<int> puzzle) {
    board.puzzle = puzzle;
    resetGameStates();
  }

  void resetGameStates() {
    gameStates.clear();
    gameStates.add(new GameState(board));
    //Snapshot the initial state before any cell values have changed.
    snapshotGameState();
  }

  void displayAllGameStates([String title = ""]) {
    for(int i = 0; i < gameStates.length; i++) {
      var gameState = gameStates[i];

      var label = "$title - State $i";
      if(gameState.title != null) {
        label += " - ${gameState.title}";
      }

      board_ui = new BoardUI(board);
      board_ui.renderGameState(gameState, label);
    }
  }

  /**
   * The algorithm tries all available options for a cell in order.
   * If no solution works for the rest of the board, the algorithm
   * returns false (for “no solution”).
   *
   * Source: http://johannesbrodwall.com/2010/04/06/why-tdd-makes-a-lot-of-sense-for-sudoko/
   */
  bool bruteForceSolve(Board board, [int cellIndex = 0]) {
    if (cellIndex >= Board.CELL_COUNT) return true;

    var cell = board.cells[cellIndex];

    if (cell.hasValue) return bruteForceSolve(board, cellIndex + 1);

    for(int value in cell.availableValues) {
      setCellValue(cell, value);
      if (bruteForceSolve(board, cellIndex + 1)) return true;
    }

    cell.clearValue();
    return false;
  }

  bool humanSolve(Board board) {
    var solvedBoard = new Board.fromPuzzle(board.puzzle);
    var puzzleHasContradictions = !bruteForceSolve(solvedBoard);
    if(puzzleHasContradictions) return false;

    while(true) {
      var emptyCellsWithOnlyOneAvailableValue = board.emptyCellsWithOnlyOneAvailableValue;
      while(emptyCellsWithOnlyOneAvailableValue.length > 0) {
        for(var cell in emptyCellsWithOnlyOneAvailableValue) {
          setCellValue(cell, cell.availableValues.first);
        }
        emptyCellsWithOnlyOneAvailableValue = board.emptyCellsWithOnlyOneAvailableValue;
      }
      snapshotGameState("Empty cells w/ 1 val");

      var emptyCellsSorted = board.emptyCellsSortedByAvailableValuesAscending;
      var solved = emptyCellsSorted.isEmpty;
      if(solved) return true;

      var cellToFill = emptyCellsSorted.first;
      var value = solvedBoard.getCell(cellToFill.row, cellToFill.column).value;
      setCellValue(cellToFill, value);
      snapshotGameState("Guess");
    }
  }

  void setCellValue(Cell cell, int value) {
    cell.value = value;
    currentGameState.addChangedCell(cell);
  }

  void snapshotGameState([String title]) {
    currentGameState.title = title;
    currentGameState.freezeCellValues();
    gameStates.add(new GameState(board));
  }

}