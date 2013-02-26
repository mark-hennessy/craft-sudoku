part of test_suite;

void runBoardTests() {
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
  
}

