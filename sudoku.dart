library sudoku;

import 'dart:html';
import 'packages/unittest/unittest.dart';

part 'puzzle_parser.dart';
part 'board.dart';
part 'tests.dart';

void main() {
  initializeUI();
  var puzzles = Parser.parseSudokuData(PUZZLES_EASY_50, "========");
  var values = Parser.parsePuzzle(puzzles[0]);
  var board = new Board(values);
  
  runTests();
}

void initializeUI() {
  query("#tests")
    ..onClick.listen((e) => runTests());
}