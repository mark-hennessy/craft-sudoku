part of test_suite;

void runSudokuTests() {
  group('Sudoku', () {

    void testSolve(List<int> puzzle, bool solveAlgorithm(Board board)) {
      sudoku.prepareGame(puzzle);
      solveAlgorithm(board1);
      expect(sudoku.board.isSolved, true);
    }

    test('bruteForceSolveAlgorithm easy', () {
      testSolve(puzzles_easy50[0], sudoku.bruteForceSolve);
    });

    test('bruteForceSolveAlgorithm hard', () {
      testSolve(puzzles_hardest11[7], sudoku.bruteForceSolve);
    });

    test('humanSolveAlgorithm easy', () {
      testSolve(puzzles_easy50[0], sudoku.humanSolve);
    });

    test('humanSolveAlgorithm hard', () {
      testSolve(puzzles_hardest11[7], sudoku.humanSolve);
    });

  });
}