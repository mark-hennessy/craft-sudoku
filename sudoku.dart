library sudoku;

import 'dart:html';
import 'packages/unittest/unittest.dart';

part 'puzzle_parser.dart';
part 'board.dart';
part 'tests.dart';
part 'collection_utils.dart';

void main() {
  runTests();
  var sudokuGame = new Sudoku();
}

class Sudoku {
  List<List<int>> previousStates;
  List<int> currentState;
  Board board;
  
  Sudoku() {
    var puzzles = Parser.parseSudokuData(PUZZLES_EASY_50, separator: '==');
    previousStates = new List<List<int>>();
    currentState = puzzles[0];
    board = new Board(currentState);
    initializeUI();
  }
  
  void initializeUI() {
    query("#tests")
      ..onClick.listen((e) => runTests());
    
    board.render();
  }
  
  
}