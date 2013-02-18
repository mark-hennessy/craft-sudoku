library sudoku;

import 'dart:html';
import 'packages/unittest/unittest.dart';

part 'collection_utils.dart';
part 'dom_utils.dart';
part 'key_map.dart';

part 'puzzle_parser.dart';
part 'board.dart';
part 'tests.dart';

void main() {
  runTests();
  var sudokuGame = new Sudoku();
}

void printDebugInfo(String text) {
  query("#debug")
    ..appendText(text);
}

class GameState {
  List<List<int>> cellValueHistory = [];
  List<int> get currentCellValues => cellValueHistory.last;
  
  set currentCellValues(List<int> cellValues) {
    cellValueHistory.add(new List.from(cellValues));
  }
  
  GameState(List<int> cellValues) {
    currentCellValues = cellValues;
  }
  
}

class Sudoku {

  GameState gameState;
  Board board;
  
  Sudoku() {
    var puzzles = Parser.parseSudokuData(PUZZLES_EASY_50, separator: '==');
    board = new Board(puzzles[0]);
    gameState = new GameState(board.cellValues);
    initializeUI();
  }
  
  void updateGameState(){
    gameState.currentCellValues = board.cellValues;
  }
  
  void initializeUI() {
    query("#tests")
      ..onClick.listen((e) => runTests());
    
    solve();
    gameState.cellValueHistory.forEach((cellValues) {
      board.cellValues = cellValues;
      board.render();
    });
  }
  
  void solve() {
    // If a cell has only one possible value, then set it. 
    var freebieCells = board.emptyCellsWithOnlyOnePossibleValue;
    do {
      for(var cell in freebieCells) {
        cell.value = cell.availableValues.first;
        updateGameState();
      }
      freebieCells = board.emptyCellsWithOnlyOnePossibleValue;
    } while(freebieCells.length > 0);
    
    if(!board.isSolved) {
      search();
    }
  }
  
  void search() {
    
  }
}