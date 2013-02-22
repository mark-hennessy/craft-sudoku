library sudoku;

import 'dart:html';
import 'packages/unittest/unittest.dart';
import 'packages/unittest/mock.dart';

part 'tests/tests.dart';

part 'puzzle_parser.dart';
part 'board.dart';
part 'board_ui.dart';
part 'game_state.dart';

part 'utils/io.dart';
part 'utils/collection_utils.dart';
part 'utils/dom_utils.dart';
part 'utils/keyboard.dart';

void main() {
  runTests();
  var sudokuGame = new Sudoku();
}

class Sudoku {
  Board board;
  BoardUI board_ui;
  
  List<GameState> previousGameStates = [];
  GameState currentGameState;
  
  Sudoku() {
    var puzzles = Parser.parseSudokuData(PUZZLES_EASY_50, separator: '==');
    board = new Board(puzzles[0]);
    board_ui = new BoardUI();
    currentGameState = new GameState(board.cellValues);
    initializeUI();
  }
  
  void initializeUI() {
    query("#clear-debug-output")
    ..onClick.listen((e) => IO.clearDebugInfo());
    
    solve();
    
    previousGameStates.forEach((gameState) 
        => board_ui.renderGameState(gameState));
  }
  
  void solve() {
    var emptyCellsWithOnlyOnePossibleValue = board.emptyCellsWithOnlyOnePossibleValue;
    do {
      for(var cell in emptyCellsWithOnlyOnePossibleValue) {
        updateCellValue(cell, cell.availableValues.first);
        snapshotGameState();
      }
      emptyCellsWithOnlyOnePossibleValue = board.emptyCellsWithOnlyOnePossibleValue;
    } while(emptyCellsWithOnlyOnePossibleValue.length > 0);
    
    if(!board.isSolved) {
      search();
    }
  }
  
  void search() {
    
  }
  
  void updateCellValue(Cell cell, int value) {
    cell.value = value;
    currentGameState.changedCells.add(cell);
  }
  
  void snapshotGameState(){
    currentGameState.freeze();
    previousGameStates.add(currentGameState);
    currentGameState = new GameState(board.cellValues);
  }
 
}