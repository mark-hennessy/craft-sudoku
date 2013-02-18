part of sudoku;

/**
 * This class contains the unit tests for the Sudoku solver.
 * 
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
void runTests() {
  Sudoku sudoku = new Sudoku();
  Board board = sudoku.board;
  List<List<int>> puzzles = Parser.parseSudokuData(PUZZLES_EASY_50, separator: '==');
  
  group('Parser', () {
    List<String> stringBoards = Parser._splitBoards(PUZZLES_EASY_50, separator: '==');
    test('_splitBoards', () {
      expect("003020600\n900305001\n001806400\n008102900\n700000008\n006708200\n002609500\n800203009\n005010300\n", 
          equals(stringBoards[0]));
    });
    
    test('_parseCellValues', () {
      List<int> cellValues = Parser._parseCellValues(stringBoards[0]);
      expect(cellValues, orderedEquals([0, 0, 3, 0, 2, 0, 6, 0, 0, 
                                        9, 0, 0, 3, 0, 5, 0, 0, 1,
                                        0, 0, 1, 8, 0, 6, 4, 0, 0,
                                        0, 0, 8, 1, 0, 2, 9, 0, 0,
                                        7, 0, 0, 0, 0, 0, 0, 0, 8,
                                        0, 0, 6, 7, 0, 8, 2, 0, 0,
                                        0, 0, 2, 6, 0, 9, 5, 0, 0,
                                        8, 0, 0, 2, 0, 3, 0, 0, 9,
                                        0, 0, 5, 0, 1, 0, 3, 0, 0]));
    });
    
    test('parseSudokuData', () {
      expect(puzzles, hasLength(50));
    });
  });
  
  group('Board', () {
    
    setUp(() {
      board.cellValues = puzzles[0];
    });
    
    test('indexAtGridCoordinates', () {
      expect(Board.indexAtGridCoordinates(3, 2), equals(29));
      expect(Board.indexAtGridCoordinates(8, 8), equals(80));
    });
    
    test('board initialized cells correctly', () {
      expect(board.cellValues, hasLength(81));
      expect(board.cells, hasLength(81));
      board.cells.forEach((c) => expect(c, isNotNull));
    });
    
    test('board has the correct values', () {
      //Spot check values
      expect(board.getCell(0, 2).value, equals(3));
      expect(board.getCell(0, 4).value, equals(2));
    });
    
    test('emptyCells', (){
      expect(board.emptyCells, hasLength(49));
      expect(board.emptyCells, contains(board.getCell(0, 0)));
      expect(board.emptyCells, contains(board.getCell(0, 1)));
      expect(board.emptyCells, isNot(contains(board.getCell(0, 2))));
    });
    
    test('emptyCellsWithOnlyOnePossibleValue', () {
      for(var cell in board.emptyCellsWithOnlyOnePossibleValue) {
        expect(cell.hasValidValue, isFalse);
        expect(cell.availableValues, hasLength(1));
      }
    });

    test('emptyCellsSortedByAvailableValuesAscending', () {
      var previousCell = null;
      for(var cell in board.emptyCellsSortedByAvailableValuesAscending) {
        expect(cell.hasValidValue, isFalse);
        if(previousCell != null) {
          expect(cell.availableValues.length, greaterThanOrEqualTo(previousCell.availableValues.length));
        }
        previousCell = cell;
      }
    });
    
  });
  
  group('Cell', () {
    test('hasValidValue', () {
      var cell = board.cells.first;
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
      var cell = board.getCell(0, 0);
      expect(cell.availableValues, unorderedEquals([4, 5]));
    });
    
    test('unavailableValues', () {
      var cell = board.getCell(0, 0);
      expect(cell.unavailableValues, unorderedEquals([1, 2, 3, 6, 7, 8, 9]));
    });
    
  });
  
  group('Sovlve Algorithms', () {
    
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
      expect(sudoku.gameState.currentCellValues, orderedEquals(solved_p0));
    });
    
    test('search', () {
      
    });
    
  });

}

