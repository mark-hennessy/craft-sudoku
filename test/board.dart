part of test_runner;

void runBoardTests() {

  /*
   * puzzles[0]
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
  var testPuzzle = puzzles_easy50[0];

  var puzzleA_unsolved = [0, 8, 3, 9, 2, 1, 6, 5, 7,
                          9, 6, 7, 3, 4, 5, 8, 2, 1,
                          2, 5, 1, 8, 7, 6, 4, 9, 3,
                          5, 4, 8, 1, 3, 2, 9, 7, 6,
                          7, 2, 9, 5, 6, 4, 1, 3, 8,
                          1, 3, 6, 7, 9, 8, 2, 4, 5,
                          3, 7, 2, 6, 8, 9, 5, 1, 4,
                          8, 1, 4, 2, 5, 3, 7, 6, 9,
                          6, 9, 5, 4, 1, 7, 3, 8, 2];

  // Incorrect value at (r:0, c:1, v:4)
  // Contradiction at (r:0, c:0, v:4), (r:0, c:1, v:4), (r:3, c:1, v:0)
  var puzzleA_contradiction = [4, 4, 3, 9, 2, 1, 6, 5, 7,
                               9, 6, 7, 3, 4, 5, 8, 2, 1,
                               2, 5, 1, 8, 7, 6, 4, 9, 3,
                               5, 0, 8, 1, 3, 2, 9, 7, 6,
                               7, 2, 9, 5, 6, 4, 1, 3, 8,
                               1, 3, 6, 7, 9, 8, 2, 4, 5,
                               3, 7, 2, 6, 8, 9, 5, 1, 4,
                               8, 1, 4, 2, 5, 3, 7, 6, 9,
                               6, 9, 5, 4, 1, 7, 3, 8, 2];

  var puzzleA_solved = [4, 8, 3, 9, 2, 1, 6, 5, 7,
                        9, 6, 7, 3, 4, 5, 8, 2, 1,
                        2, 5, 1, 8, 7, 6, 4, 9, 3,
                        5, 4, 8, 1, 3, 2, 9, 7, 6,
                        7, 2, 9, 5, 6, 4, 1, 3, 8,
                        1, 3, 6, 7, 9, 8, 2, 4, 5,
                        3, 7, 2, 6, 8, 9, 5, 1, 4,
                        8, 1, 4, 2, 5, 3, 7, 6, 9,
                        6, 9, 5, 4, 1, 7, 3, 8, 2];

  var puzzle_sameValue = [2, 2, 2, 2, 2, 2, 2, 2, 2,
                          2, 2, 2, 2, 2, 2, 2, 2, 2,
                          2, 2, 2, 2, 2, 2, 2, 2, 2,
                          2, 2, 2, 2, 2, 2, 2, 2, 2,
                          2, 2, 2, 2, 2, 2, 2, 2, 2,
                          2, 2, 2, 2, 2, 2, 2, 2, 2,
                          2, 2, 2, 2, 2, 2, 2, 2, 2,
                          2, 2, 2, 2, 2, 2, 2, 2, 2,
                          2, 2, 2, 2, 2, 2, 2, 2, 2,];

  group('Board', () {

    setUp(() {
      board1.puzzle = testPuzzle.toList();
    });

    test('originalPuzzle', () {
      expect(board1.puzzle, equals(testPuzzle));

      board1.cells[0].value = 5;
      expect(board1.puzzle, equals(testPuzzle));

      board1.cellValues = puzzleA_solved;
      expect(board1.puzzle, equals(testPuzzle));
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
      expect(board1.cellValues, hasLength(Board.CELL_COUNT));
      expect(board1.cells, hasLength(Board.CELL_COUNT));
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

    test('emptyCellsWithOneAvailableValue', () {
      for(var cell in board1.emptyCellsWithOneAvailableValue) {
        expect(cell.hasValue, isFalse);
        expect(cell.availableValues, hasLength(1));
      }
    });

    test('emptyCellsSortedByAvailableValuesAscending', () {
      Cell previousCell = null;
      for(var cell in board1.emptyCellsSortedByAvailableValuesAscending) {
        expect(cell.hasValue, isFalse);
        if(previousCell != null) {
          expect(cell.availableValues.length, greaterThanOrEqualTo(previousCell.availableValues.length));
        }
        previousCell = cell;
      }
    });

    test('hasContradictions', () {
      board1.cellValues = puzzleA_unsolved;
      expect(board1.hasContradictions, isFalse);

      board1.cellValues = puzzleA_contradiction;
      expect(board1.hasContradictions, isTrue);

      board1.cellValues = puzzle_sameValue;
      expect(board1.hasContradictions, isTrue);

      board1.cellValues = puzzleA_solved;
      expect(board1.hasContradictions, isFalse);
    });

    test('isSolved', () {
      board1.cellValues = puzzleA_unsolved;
      expect(board1.isSolved, isFalse);

      board1.cellValues = puzzleA_contradiction;
      expect(board1.isSolved, isFalse);

      board1.cellValues = puzzleA_solved;
      expect(board1.isSolved, isTrue);

      board1.cellValues = puzzle_sameValue;
      expect(board1.isSolved, isFalse);
    });

    test('clearPuzzle', () {
      board1.cellValues = puzzleA_solved;
      var puzzle = board1.puzzle;
      expect(board1.cellValues, isNot(orderedEquals(puzzle)));
      board1.clearPuzzle();
      expect(board1.cellValues, orderedEquals(puzzle));
    });

  });

  group('Unit', () {

    setUp(() {
      board1.puzzle = testPuzzle.toList();
    });

    test('boxUnit', () {
      var boxUnit = board1.getCell(0, 0).boxUnit;
      List<Cell> firstBox = [];
      for(int row = 0; row < Board.BOX_SIZE; row++) {
        for(int column = 0; column < Board.BOX_SIZE; column++) {
          firstBox.add(board1.getCell(row, column));
        }
      }
      expect(boxUnit.cells, orderedEquals(firstBox));
    });

    test('rowUnit', () {
      var rowUnit = board1.getCell(0, 0).rowUnit;
      List<Cell> firstRow = [];
      for(int column = 0; column < Board.GRID_SIZE; column++) {
        firstRow.add(board1.getCell(0, column));
      }
      expect(rowUnit.cells, orderedEquals(firstRow));
    });

    test('columnUnit', () {
      var columnUnit = board1.getCell(0, 0).columnUnit;
      List<Cell> firstColumn = [];
      for(int row = 0; row < Board.GRID_SIZE; row++) {
        firstColumn.add(board1.getCell(row, 0));
      }
      expect(columnUnit.cells, orderedEquals(firstColumn));
    });

    test('cellValues', () {
      var cell = board1.getCell(0, 0).rowUnit;
      expect(cell.cellValues, unorderedEquals([3, 2, 6]));
    });

  });

  group('Cell', () {

    setUp(() {
      board1.puzzle = testPuzzle.toList();
      board2.puzzle = testPuzzle.toList();
    });

    test('isValueFixed', () {
      var cellA = board1.getCell(0, 0);
      var cellB = board1.getCell(0, 2);
      expect(cellA.isValueFixed, isFalse);
      expect(cellB.isValueFixed, isTrue);
    });

    test('value', () {
      var row = 0, column = 0;
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

    test('setting value when fixed', () {
      var cell = board1.getCell(0, 2);
      expect(cell.isValueFixed, isTrue);
      expect(() => cell.value = 5, throws);
    });

    test('hasValue', () {
      var cell = board1.getCell(0, 0);

      cell.value = null;
      expect(cell.hasValue, isFalse);

      cell.value = 0;
      expect(cell.hasValue, isFalse);

      cell.value = 10;
      expect(cell.hasValue, isFalse);

      cell.value = 5;
      expect(cell.hasValue, isTrue);
    });

    test('clearValue', () {
      var row = 0;
      var column = 0;
      var index = Board.indexAtGridCoordinates(row, column);
      var cell = board1.getCell(row, column);

      var newValue = 5;
      cell.value = newValue;
      expect(cell.value, equals(newValue));
      expect(cell.hasValue, isTrue);
      expect(board1.cellValues[index], newValue);

      cell.clearValue();
      expect(cell.value, equals(0));
      expect(cell.hasValue, isFalse);
      expect(board1.cellValues[index], 0);
    });

    test('availableValues', () {
      var cell = board1.getCell(0, 0);
      expect(cell.availableValues, unorderedEquals([4, 5]));
    });

    test('peerValues', () {
      var cell = board1.getCell(0, 0);
      expect(cell.peerValues, unorderedEquals([1, 2, 3, 6, 7, 8, 9]));
    });

    test('contradictions', () {
      var contradictionCells = [board1.getCell(0, 0), board1.getCell(0, 1), board1.getCell(3, 1)];
      board1.cellValues = puzzleA_unsolved;
      expect(board1.contradictions, unorderedEquals([]));

      board1.cellValues = puzzleA_contradiction;
      expect(board1.contradictions, unorderedEquals(contradictionCells));

      board1.cellValues = puzzleA_solved;
      expect(board1.contradictions, unorderedEquals([]));
    });

    test('hasContradictions', () {
      var contradictionCells = [board1.getCell(0, 0), board1.getCell(0, 1), board1.getCell(3, 1)];
      for(var cell in contradictionCells) {
        board1.cellValues = puzzleA_unsolved;
        expect(cell.hasContradiction, isFalse);

        board1.cellValues = puzzleA_contradiction;
        expect(cell.hasContradiction, isTrue);

        board1.cellValues = puzzleA_solved;
        expect(cell.hasContradiction, isFalse);
      }
    });

    test('equality', () {
      var cell1 = board1.getCell(0, 0);
      var cell2 = board2.getCell(0, 0);
      expect(cell1, equals(cell2));
    });

  });

}

