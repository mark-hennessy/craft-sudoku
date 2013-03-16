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

SudokuGame sudoku = new SudokuGame();
BoardUI boardUI = new BoardUI();
Board board1 = sudoku.board;
Board board2 = boardUI.boardToRender;

List<List<int>> puzzles = Parser.parseSudokuData(PUZZLES_EASY_50, separator: '==');

class TestSuite {
  
  void runTests() {
//  useHtmlEnhancedConfiguration();
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

