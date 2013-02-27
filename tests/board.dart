part of test_suite;

void runBoardTests() {
  
  var unsolvedPuzzle = [0, 8, 3, 9, 2, 1, 6, 5, 7, 
                  9, 6, 7, 3, 4, 5, 8, 2, 1,
                  2, 5, 1, 8, 7, 6, 4, 9, 3,
                  5, 4, 8, 1, 3, 2, 9, 7, 6,
                  7, 2, 9, 5, 6, 4, 1, 3, 8,
                  1, 3, 6, 7, 9, 8, 2, 4, 5,
                  3, 7, 2, 6, 8, 9, 5, 1, 4,
                  8, 1, 4, 2, 5, 3, 7, 6, 9,
                  6, 9, 5, 4, 1, 7, 3, 8, 2];

  //contradiction at (r:0, c:0, v:4) and (r:3, c:1, v:0) 
  //caused by incorrect value at(r:0, c:1, v:4)
  var contradictionPuzzle = [4, 4, 3, 9, 2, 1, 6, 5, 7, 
                       9, 6, 7, 3, 4, 5, 8, 2, 1,
                       2, 5, 1, 8, 7, 6, 4, 9, 3,
                       5, 0, 8, 1, 3, 2, 9, 7, 6,
                       7, 2, 9, 5, 6, 4, 1, 3, 8,
                       1, 3, 6, 7, 9, 8, 2, 4, 5,
                       3, 7, 2, 6, 8, 9, 5, 1, 4,
                       8, 1, 4, 2, 5, 3, 7, 6, 9,
                       6, 9, 5, 4, 1, 7, 3, 8, 2];
  
  var solvedPuzzle = [4, 8, 3, 9, 2, 1, 6, 5, 7, 
                9, 6, 7, 3, 4, 5, 8, 2, 1,
                2, 5, 1, 8, 7, 6, 4, 9, 3,
                5, 4, 8, 1, 3, 2, 9, 7, 6,
                7, 2, 9, 5, 6, 4, 1, 3, 8,
                1, 3, 6, 7, 9, 8, 2, 4, 5,
                3, 7, 2, 6, 8, 9, 5, 1, 4,
                8, 1, 4, 2, 5, 3, 7, 6, 9,
                6, 9, 5, 4, 1, 7, 3, 8, 2];
  
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
        expect(cell.possibleValues, hasLength(1));
      }
    });
    
    test('emptyCellsSortedByAvailableValuesAscending', () {
      var previousCell = null;
      for(var cell in board1.emptyCellsSortedByAvailableValuesAscending) {
        expect(cell.hasValidValue, isFalse);
        if(previousCell != null) {
          expect(cell.possibleValues.length, greaterThanOrEqualTo(previousCell.possibleValues.length));
        }
        previousCell = cell;
      }
    });
    
    test('hasContradictions', () {
      board1.cellValues = unsolvedPuzzle;
      expect(board1.hasContradictions, isFalse);
      board1.cellValues = contradictionPuzzle;
      expect(board1.hasContradictions, isTrue);
      board1.cellValues = solvedPuzzle;
      expect(board1.hasContradictions, isFalse);
    });
    
    test('isSolved', () {
      board1.cellValues = unsolvedPuzzle;
      expect(board1.isSolved, isFalse);
      board1.cellValues = contradictionPuzzle;
      expect(board1.isSolved, isFalse);
      board1.cellValues = solvedPuzzle;
      expect(board1.isSolved, isTrue);
    });
  });
  
  group('Cell', () {
    
    setUp(() {
      board1.cellValues = puzzles[0];
    });
    
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
    
    test('possibleValues', () {
      var cell = board1.getCell(0, 0);
      expect(cell.possibleValues, unorderedEquals([4, 5]));
    });
    
    test('takenValues', () {
      var cell = board1.getCell(0, 0);
      expect(cell.takenValues, unorderedEquals([1, 2, 3, 6, 7, 8, 9]));
    });
    
    test('hasContradictions', () {
      var contradictionCells = [board1.getCell(0, 0), board1.getCell(3, 1)];
      for(var cell in contradictionCells) {
        board1.cellValues = unsolvedPuzzle;
        expect(cell.hasContradiction, isFalse);
        board1.cellValues = contradictionPuzzle;
        expect(cell.hasContradiction, isTrue);
        board1.cellValues = solvedPuzzle;
        expect(cell.hasContradiction, isFalse);
      }
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
  
}

