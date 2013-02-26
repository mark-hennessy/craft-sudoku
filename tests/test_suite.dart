library test_suite;

import 'dart:html';
import '../sudoku.dart';
import '../packages/unittest/unittest.dart';
import '../packages/unittest/html_enhanced_config.dart';
import '../packages/unittest/mock.dart';

part 'mocks/mock_keyboard_event.dart';

void main() {
  var testSuite = new TestSuite();
  testSuite.runTests();
}

//Variables that are costly to create and are needed by most tests.
Sudoku sudoku = new Sudoku();
BoardUI boardUI = new BoardUI();
Board board1 = sudoku.board;
Board board2 = boardUI.board;
List<List<int>> puzzles = Parser.parseSudokuData(PUZZLES_EASY_50, separator: '==');

/**
 * Test board
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
class TestSuite {
  
  void runTests() {
//    useHtmlEnhancedConfiguration();
    
    group('Parser', () {
      
      test('parseSudokuData', () {
        List<List<int>> puzzles = Parser.parseSudokuData(PUZZLES_EASY_50, separator: '==');
        expect(puzzles, hasLength(50));
        expect(puzzles[0], orderedEquals([0, 0, 3, 0, 2, 0, 6, 0, 0, 
                                          9, 0, 0, 3, 0, 5, 0, 0, 1,
                                          0, 0, 1, 8, 0, 6, 4, 0, 0,
                                          0, 0, 8, 1, 0, 2, 9, 0, 0,
                                          7, 0, 0, 0, 0, 0, 0, 0, 8,
                                          0, 0, 6, 7, 0, 8, 2, 0, 0,
                                          0, 0, 2, 6, 0, 9, 5, 0, 0,
                                          8, 0, 0, 2, 0, 3, 0, 0, 9,
                                          0, 0, 5, 0, 1, 0, 3, 0, 0]));
        
      });
    });
    
    group('Board', () {
      
      setUp(() {
        board1.cellValues = puzzles[0];
      });
      
      test('indexAtGridCoordinates', () {
        expect(Board.indexAtGridCoordinates(3, 2), equals(29));
        expect(Board.indexAtGridCoordinates(8, 8), equals(80));
      });
      
      test('gridCoordinatesInBounds', () {
        expect(Board.gridCoordinatesInBounds(0, -1), isFalse);
        expect(Board.gridCoordinatesInBounds(0, 0), isTrue);
        expect(Board.gridCoordinatesInBounds(5, 5), isTrue);
        expect(Board.gridCoordinatesInBounds(8, 8), isTrue);
        expect(Board.gridCoordinatesInBounds(8, 9), isFalse);
      });
      
      test('board initialized cells correctly', () {
        expect(board1.cellValues, hasLength(81));
        expect(board1.cells, hasLength(81));
        board1.cells.forEach((c) => expect(c, isNotNull));
      });
      
      test('board has the correct values', () {
        //Spot check values
        expect(board1.getCell(0, 2).value, equals(3));
        expect(board1.getCell(0, 4).value, equals(2));
        expect(board1.getCell(5, 7).value, equals(0));
      });
      
      test('emptyCells', (){
        expect(board1.emptyCells, hasLength(49));
        expect(board1.emptyCells, contains(board1.getCell(0, 0)));
        expect(board1.emptyCells, contains(board1.getCell(0, 1)));
        expect(board1.emptyCells, isNot(contains(board1.getCell(0, 2))));
      });
      
      test('emptyCellsWithOnlyOnePossibleValue', () {
        for(var cell in board1.emptyCellsWithOnlyOnePossibleValue) {
          expect(cell.hasValidValue, isFalse);
          expect(cell.availableValues, hasLength(1));
        }
      });
  
      test('emptyCellsSortedByAvailableValuesAscending', () {
        var previousCell = null;
        for(var cell in board1.emptyCellsSortedByAvailableValuesAscending) {
          expect(cell.hasValidValue, isFalse);
          if(previousCell != null) {
            expect(cell.availableValues.length, greaterThanOrEqualTo(previousCell.availableValues.length));
          }
          previousCell = cell;
        }
      });
      
    });
    
    group('Cell', () {
      test('value', () {
        var row = 3, column = 5;
        var cellIndex = Board.indexAtGridCoordinates(row, column);
        var cell = board1.getCell(row, column);
        
        //Setting the cell value should update the board's list of cellValues.
        var newValue = 5;
        cell.value = newValue;
        expect(cell.value, equals(newValue));
        expect(board1.cellValues[cellIndex], equals(newValue));
        
        //Setting the board's list of cellValues should update the cell value.
        newValue = 8;
        board1.cellValues[cellIndex] = newValue;
        expect(cell.value, equals(newValue));
        expect(board1.cellValues[cellIndex], equals(newValue));
      });
      
      test('hasValidValue', () {
        var cell = board1.cells.first;
        cell.value = null;
        expect(cell.hasValidValue, isFalse);
        cell.value = 0;
        expect(cell.hasValidValue, isFalse);
        cell.value = 10;
        expect(cell.hasValidValue, isFalse);
        cell.value = 5;
        expect(cell.hasValidValue, isTrue);
      });
      
      test('availableValues', () {
        var cell = board1.getCell(0, 0);
        expect(cell.availableValues, unorderedEquals([4, 5]));
      });
      
      test('unavailableValues', () {
        var cell = board1.getCell(0, 0);
        expect(cell.unavailableValues, unorderedEquals([1, 2, 3, 6, 7, 8, 9]));
      });
      
      test('equality', () {
        var value = 5;
        var cell1 = board1.getCell(0, 0);
        var cell2 = board2.getCell(0, 0);
        cell1.value = value;
        cell2.value = value;
        expect(cell1, equals(cell2));
      });
      
    });
    
    group('Sudoku', () {
      
      test('solve', () {
        var unsolved_p0 = [0, 0, 3, 0, 2, 0, 6, 0, 0, 
                           9, 0, 0, 3, 0, 5, 0, 0, 1,
                           0, 0, 1, 8, 0, 6, 4, 0, 0,
                           0, 0, 8, 1, 0, 2, 9, 0, 0,
                           7, 0, 0, 0, 0, 0, 0, 0, 8,
                           0, 0, 6, 7, 0, 8, 2, 0, 0,
                           0, 0, 2, 6, 0, 9, 5, 0, 0,
                           8, 0, 0, 2, 0, 3, 0, 0, 9,
                           0, 0, 5, 0, 1, 0, 3, 0, 0];
        
        var solved_p0 = [4, 8, 3, 9, 2, 1, 6, 5, 7, 
                         9, 6, 7, 3, 4, 5, 8, 2, 1,
                         2, 5, 1, 8, 7, 6, 4, 9, 3,
                         5, 4, 8, 1, 3, 2, 9, 7, 6,
                         7, 2, 9, 5, 6, 4, 1, 3, 8,
                         1, 3, 6, 7, 9, 8, 2, 4, 5,
                         3, 7, 2, 6, 8, 9, 5, 1, 4,
                         8, 1, 4, 2, 5, 3, 7, 6, 9,
                         6, 9, 5, 4, 1, 7, 3, 8, 2];
        
        sudoku.board.cellValues = unsolved_p0;
        sudoku.solve();
        expect(sudoku.board.isSolved, true);
        expect(sudoku.board.cellValues, orderedEquals(solved_p0));
        expect(sudoku.currentGameState.cellValues, orderedEquals(solved_p0));
      });
      
      test('search', () {
        
      });
      
    });
    
    group('GameState', () {
      test('freeze', () {
        var gameState = new GameState(board1.cellValues);
        var cell = board1.getCell(0, 0);
        cell.value = 5;
        expect(gameState.cellValues, orderedEquals(board1.cellValues));
        var cellValueSnapshot = new List<int>.from(board1.cellValues);
        gameState.freeze();
        cell.value = 7;
        expect(gameState.cellValues, orderedEquals(cellValueSnapshot));
      });
    });
    
    group('CollectionUtils', () {
      test('subtractListAFromListB', () {
        var list1 = [1, 3, 2, -5];
        var list2 = [1, 3];
        expect(CollectionUtils
            .subtractListAFromListB(list1, list2), 
            unorderedEquals([]));
        expect(CollectionUtils
            .subtractListAFromListB(list2, list1), 
            unorderedEquals([2, -5]));
      });
      
      test('reverse', () {
        var list1 = [1, 3, 2, -5];
        expect(CollectionUtils.reverse(list1), 
            orderedEquals([-5, 2, 3, 1]));
      });
      
      test('compareAscending', () {
        var list1 = [1, 3, 2, -5];
        list1.sort(CollectionUtils.compareAscending);
        expect(list1, orderedEquals([-5, 1, 2, 3]));
      });
      
      test('compareDecending', () {
        var list1 = [1, 3, 2, -5];
        list1.sort(CollectionUtils.compareDecending);
        expect(list1, orderedEquals([3, 2, 1, -5]));
      });
    });
    
    group('DomUtils', () {
      test('makeFocusable', () {
        var divElement = new DivElement();
        expect(divElement.tabIndex, -1);
        
        DomUtils.makeFocusable(divElement);
        expect(divElement.tabIndex, equals(0));
        
        var customTabIndex = 5;
        divElement.tabIndex = customTabIndex;
        DomUtils.makeFocusable(divElement);
        expect(divElement.tabIndex, equals(customTabIndex));
      });
    });
  
    group('IO', () {
      test('printDebugInfo', () {
        var output = query(CSS.DEBUG_OUTPUT_ID);
        expect(output.text, equals(""));
        var message = "Hello";
        IO.printDebugInfo(message);
        expect(output.text, equals(message));
        IO.clearDebugInfo();
        expect(output.text, equals(""));
      });
    });
    
    group('Keyboard', () {
      MockKeyboardEvent event;
      
      setUp(() {
        event = new MockKeyboardEvent('keyDown');
      });
      
      void keyTest(List<int> keys, void test()) {
        for(var key in keys) {
          event.when(callsTo('get keyCode'))
            .alwaysReturn(key);
          test();
          event.reset();
        }
      }
      
      test('isKey', () {
        keyTest([KeyCode.A], () {
          expect(Keyboard.isEventForKey(event, KeyCode.A), isTrue);
          expect(Keyboard.isEventForKey(event, KeyCode.B), isFalse);
        });
      });
      
      test('isNumericKey', () {
        keyTest([KeyCode.FIVE, KeyCode.ZERO], () {
          expect(Keyboard.isNumericKey(event), isTrue);
        });
        
        keyTest([KeyCode.A, KeyCode.SHIFT], () {
          expect(Keyboard.isNumericKey(event), isFalse);
        });
      });
      
      test('isArrowKey', () {
        var arrowKeys = [KeyCode.LEFT, KeyCode.UP, KeyCode.RIGHT, KeyCode.DOWN];
        keyTest(arrowKeys, () {
          expect(Keyboard.isArrowKey(event), isTrue);
        });
        keyTest([KeyCode.A, KeyCode.SHIFT], () {
          expect(Keyboard.isArrowKey(event), isFalse);
        });
      });
      
      test('parseKeyAsString', () {
        keyTest([KeyCode.A], () {
          String string = Keyboard.parseKeyAsString(event);
          expect(string, "A");
        });
        keyTest([KeyCode.ZERO], () {
          expect(Keyboard.parseKeyAsString(event), "0");
        });
      });
      
      test('parseKeyAsInt', () {
        keyTest([KeyCode.ZERO], () {
          expect(Keyboard.parseKeyAsInt(event), 0);
        });
        keyTest([KeyCode.NINE], () {
          expect(Keyboard.parseKeyAsInt(event), 9);
        });
      });
    });
    
  }
  
}

