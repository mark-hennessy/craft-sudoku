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
  group('All', () {
    
    
    group('Parser', () {
      test('parse string with multiple puzzles into a list of string puzzles', () {
        List<String> puzzles = Parser.parseSudokuData(PUZZLES_EASY_50, separator: "========");
        expect("003020600\n900305001\n001806400\n008102900\n700000008\n006708200\n002609500\n800203009\n005010300\n", 
            equals(puzzles[0]));
      });
      
      test('parse puzzle stored as a string into a list of cell values', () {
        List<String> puzzles = Parser.parseSudokuData(PUZZLES_EASY_50, separator: "========");
        List<int> cellValues = Parser.parsePuzzle(puzzles[0]);
        expect(cellValues, hasLength(81));
        //Spot check values
        expect(cellValues.getRange(0, 9), orderedEquals([0, 0, 3, 0, 2, 0, 6, 0, 0]));
      });
    });
    
    group('Board', () {
      List<String> puzzles = Parser.parseSudokuData(PUZZLES_EASY_50, separator: "========");
      List<int> cellValues = Parser.parsePuzzle(puzzles[0]);
      
      Board board;
      
      setUp(() {
        board = new Board(cellValues);
      });
      
      test('board initialized cells correctly', () {
        expect(board._grid, hasLength(Board.SIZE));
        expect(board._grid[0], hasLength(Board.SIZE));
        board.cells.forEach((c) => expect(c, isNotNull));
      });
      
      test('board has the correct values', () {
        //Spot check values
        expect(board.getCell(0, 2).value, equals(3));
        expect(board.getCell(0, 4).value, equals(2));
      });
      
      group('Cell', () {
        test('hasValidValue', () {
          var cell = new Cell();
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
      
    });
  
  });
}

void print(String text) {
  query("#debug")
    ..appendText(text);
}

