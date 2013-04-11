part of test_suite;

void runGameTests() {
  group('Game', () {

    var puzzleA_unsolved = [0, 8, 3, 9, 2, 1, 6, 0, 7,
                            9, 6, 7, 3, 4, 5, 8, 2, 1,
                            2, 5, 1, 8, 7, 6, 4, 9, 3,
                            5, 4, 8, 1, 3, 2, 9, 7, 6,
                            7, 2, 0, 5, 6, 4, 1, 3, 8,
                            1, 3, 6, 7, 9, 0, 2, 4, 5,
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

    test('selectDifficulty', () {
      game.puzzleDifficulty = "easy";
      game.puzzleIndex = 2;

      game.selectDifficulty("medium");
      expect(game.puzzleDifficulty, equals("medium"));
      expect(game.puzzleIndex, equals(0));
    });

    test('firstPuzzle', () {
      game.puzzleIndex = 2;

      game.firstPuzzle();
      expect(game.puzzleIndex, equals(0));
    });

    test('previousPuzzle', () {
      var lastIndex = game.puzzlesAtDifficulty.length - 1;
      game.puzzleIndex = 1;

      game.previousPuzzle();
      expect(game.puzzleIndex, equals(0));

      game.previousPuzzle();
      expect(game.puzzleIndex, equals(lastIndex));

      game.previousPuzzle();
      expect(game.puzzleIndex, equals(lastIndex - 1));
    });

    test('nextPuzzle', () {
      var lastIndex = game.puzzlesAtDifficulty.length - 1;
      game.puzzleIndex = lastIndex - 1;

      game.nextPuzzle();
      expect(game.puzzleIndex, equals(lastIndex));

      game.nextPuzzle();
      expect(game.puzzleIndex, equals(0));

      game.nextPuzzle();
      expect(game.puzzleIndex, equals(1));
    });

    test('lastPuzzle', () {
      var lastIndex = game.puzzlesAtDifficulty.length - 1;
      game.puzzleIndex = 2;

      game.lastPuzzle();
      expect(game.puzzleIndex, equals(lastIndex));
    });

    test('resetGame / clearPuzzle', () {
      for(var methodCall in [game.resetGame, game.clearPuzzle]) {
        var gameBoard = game.gameBoard;
        gameBoard.puzzle = puzzleA_unsolved;
        gameBoard.cellValues = puzzleA_solved;

        expect(gameBoard.cellValues, isNot(orderedEquals(puzzleA_unsolved)));
        game.clearPuzzle();
        expect(gameBoard.cellValues, orderedEquals(puzzleA_unsolved));
      }
    });

    test('hintOneCell', () {
      var game = new SudokuGame();
      var gameBoard = game.gameBoard;
      // Makes the game update the board UI
      game.resetGame();

      var emptyCellCount = gameBoard.emptyCells.length;
      for(var i = 0; i < 3; i++) {
        game.hintOneCell(solve: true);
        expect(gameBoard.emptyCells.length, --emptyCellCount);
      }
    });

    test('solvePuzzle', () {
      var game = new SudokuGame();
      var gameBoard = game.gameBoard;
      gameBoard.puzzle = puzzleA_unsolved;

      expect(gameBoard.cellValues, orderedEquals(puzzleA_unsolved));
      game.solvePuzzle();
      expect(gameBoard.cellValues, orderedEquals(puzzleA_solved));
    });

  });
}