part of test_suite;

void runGameStateTests() {
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
}



