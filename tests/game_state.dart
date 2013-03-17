part of test_suite;

void runGameStateTests() {
  group('GameState', () {
    
    setUp(() {
      board1.puzzle = puzzles[0].toList();
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