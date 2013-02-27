library test_suite;

import 'dart:html';
import '../sudoku_game.dart';
import '../packages/unittest/unittest.dart';
import '../packages/unittest/html_enhanced_config.dart';
import '../packages/unittest/mock.dart';

part 'mocks/mock_keyboard_event.dart';

part 'sudoku_game.dart';
part 'board.dart';
part 'game_state.dart';
part 'puzzle_parser.dart';

part 'utils/collection_utils.dart';
part 'utils/dom_utils.dart';
part 'utils/io.dart';
part 'utils/keyboard.dart';
part 'utils/string_utils.dart';

void main() {
  var testSuite = new TestSuite();
  testSuite.runTests();
}

//Variables that are costly to create and are needed by most tests.
SudokuGame sudoku = new SudokuGame();
BoardUI boardUI = new BoardUI();
Board board1 = sudoku.board;
Board board2 = boardUI.board;

/*
 * puzzles.first
 * ----------
 * 003020600
 * 900305001
 * 001806400
 * 008102900
 * 700000008
 * 006708200
 * 002609500
 * 800203009
 * 005010300
 */
List<List<int>> puzzles = Parser.parseSudokuData(PUZZLES_EASY_50, separator: '==');

class TestSuite {
  
  void runTests() {
//    useHtmlEnhancedConfiguration();
    runPuzzleParserTests();
    runBoardTests();
    runSudokuTests();
    runGameStateTests();
    runStringUtilsTests();
    runCollectionUtilsTests();
    runDomUtilsTests();
    runIOTests();
    runKeyboardTests();
  }
  
}

