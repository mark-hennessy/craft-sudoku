library test_runner;

import 'dart:html';
import '../web/client/sudoku_game.dart';
import '../packages/unittest/unittest.dart';
import '../packages/unittest/html_enhanced_config.dart';
import '../packages/unittest/mock.dart';

part 'mocks/mock_keyboard_event.dart';

part 'sudoku_game.dart';
part 'sudoku_solver.dart';
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

SudokuGame game = new SudokuGame();
Board board1 = game.gameBoard;
Board board2 = new Board();

List<List<int>> puzzles_easy50 = Parser.parseSudokuData(PUZZLES_EASY_50, separator: '==');
List<List<int>> puzzles_hardest11 = Parser.parseSudokuData(PUZZLES_HARDEST_11);

class TestSuite {

  void runTests() {
    useHtmlEnhancedConfiguration();

    runPuzzleParserTests();
    runBoardTests();
    runSolverTests();
    runGameTests();
    runGameStateTests();

    runStringUtilsTests();
    runCollectionUtilsTests();
    runDomUtilsTests();
    runIOTests();
    runKeyboardTests();
  }

}

