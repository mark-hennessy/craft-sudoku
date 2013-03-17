part of test_suite;

void runGameStateTests() {
  group('GameState', () {
    
    setUp(() {
      board1.puzzle = puzzles_easy50[0].toList();
    });

    test('addChangedCell', () {
      var gameState = new GameState(board1);
      expect(gameState.changedCells, orderedEquals([]));
      var cell = board1.getCell(0, 0);
      gameState.addChangedCell(cell);
      expect(gameState.changedCells, orderedEquals([cell]));
    });
    
    test('freeze', () {
      var gameState = new GameState(board1);
      var cell = board1.getCell(0, 0);
      
      cell.value = 5;
      expect(gameState.cellValues, orderedEquals(board1.cellValues));
      
      var cellValueSnapshot = new List.from(board1.cellValues);
      gameState.freeze();
      cell.value = 7;
      expect(gameState.cellValues, orderedEquals(cellValueSnapshot));
    });
    
  });
}