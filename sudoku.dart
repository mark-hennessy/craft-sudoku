library sudoku;

import 'dart:html';
import 'packages/unittest/unittest.dart';

part 'puzzle_parser.dart';
part 'board.dart';
part 'tests.dart';


void main() {
  runTests();
  var sudokuGame = new Sudoku();
}

class Sudoku {
  Board board;
  
  Sudoku() {
    var puzzles = Parser.parseSudokuData(PUZZLES_EASY_50, "========");
    var values = Parser.parsePuzzle(puzzles[0]);
    board = new Board(values);
    initializeUI();
  }
  
  void initializeUI() {
    query("#tests")
      ..onClick.listen((e) => runTests());
    
    board.render();
  }

}