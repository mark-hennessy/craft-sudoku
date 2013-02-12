library sudoku;

import 'dart:html';
import 'packages/unittest/unittest.dart';

part 'puzzle_parser.dart';
part 'board.dart';
part 'tests.dart';
part 'collection_utils.dart';

void main() {
  //runTests();
  var sudokuGame = new Sudoku();
}

class Sudoku {
  Board board;
  
  Sudoku() {
    var boards = Parser.parseSudokuData(PUZZLES_EASY_50, separator: '==');
    board = boards[0];
    initializeUI();
  }
  
  void initializeUI() {
    query("#tests")
      ..onClick.listen((e) => runTests());
    
    board.render();
  }

}