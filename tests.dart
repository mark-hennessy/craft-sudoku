part of sudoku;

void runTests() {
  group('All', () {
    List<String> puzzles = Parser.parseSudokuData(PUZZLES_EASY_50, "========");
    List<int> values = Parser.parsePuzzle(puzzles[0]);
    
    group('Parser', () {
      test('parseSudokuData', () {
        expect("003020600\n900305001\n001806400\n008102900\n700000008\n006708200\n002609500\n800203009\n005010300\n", 
            equals(puzzles[0]));
      });
      
      test('parsePuzzle', () {
        expect(values, hasLength(81));
        expect(values.getRange(0, 9), orderedEquals([0, 0, 3, 0, 2, 0, 6, 0, 0]));
      });
    });
    
    group('Board', () {
      test('grid initialization', () {
        var board = new Board(values);
        expect(board._grid, hasLength(Board.SIZE));
        expect(board._grid[0], hasLength(Board.SIZE));
        board.forEachCell((cell, row, column) {
          expect(cell, isNotNull);
        });
        expect(board.getCell(0, 2).value, equals(3));
        expect(board.getCell(0, 4).value, equals(2));
      });
    });
  
    group('Cell', () {
      test('hasValue', () {
        var cell = new Cell(0);
        expect(cell.hasValue, isFalse);
        cell.value = 5;
        expect(cell.hasValue, isTrue);
      });
    });
  
  });
}

void print(String text) {
  query("#debug")
    ..appendText(text);
}

