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
  
  List<GameState> previousGameStates = [];
  GameState currentGameState;
  
  SudokuGame() {
    var puzzles = Parser.parseSudokuData(PUZZLES_EASY_50, separator: '==');
    board = new Board(puzzles[2]);
    board_ui = new BoardUI();
    currentGameState = new GameState(board.cellValues);
    initializeUI();
  }
  
  void initializeUI() {
    query(CSS.CLEAR_DEBUG_OUTPUT_BUTTON_ID)
    ..onClick.listen((e) => IO.clearDebugInfo());
  }
  
  void run() {
    solve();
    displayAllGameStates();
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
      guess();
    }
  }
  
  void guess() {
    
  }
  
  void updateCellValue(Cell cell, int value) {
    cell.value = value;
    currentGameState.addChangedCell(cell);
  }
  
  void snapshotGameState(){
    currentGameState.freeze();
    previousGameStates.add(currentGameState);
    currentGameState = new GameState(board.cellValues);
  }
 
  void displayAllGameStates() {
    previousGameStates.forEach((gameState) 
        => board_ui.renderGameState(gameState));
  }
  
}