library sudoku;

import 'dart:html';
import 'packages/unittest/unittest.dart';

part 'board.dart';
part 'game_state.dart';
part 'board_ui.dart';
part 'tests.dart';
part 'puzzle_parser.dart';
part 'io.dart';

part 'collection_utils.dart';
part 'dom_utils.dart';
part 'keyboard.dart';

void main() {
  runTests();
  var sudokuGame = new Sudoku();
}

class Sudoku {
  Board board;
  BoardUI board_ui;
  
  List<GameState> gameStates = [];
  get currentGameState => gameStates.last;
  set currentGameState(GameState state) => gameStates.add(state);
  
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
    
    gameStates.forEach((gameState) 
        => board_ui.renderGameState(gameState));
  }
  
  void solve() {
    // If a cell has only one possible value, then set it. 
    var freebieCells = board.emptyCellsWithOnlyOnePossibleValue;
    do {
      for(var cell in freebieCells) {
        updateCellValue(cell, cell.availableValues.first);
        snapshotGameState();
      }
      freebieCells = board.emptyCellsWithOnlyOnePossibleValue;
    } while(freebieCells.length > 0);
    
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
    currentGameState.cellValues = board.cellValues;
    currentGameState = new GameState();
  }
 
}