part of test_suite;

void runSolverTests() {
  group('Solver', () {

    var solver = new SudokuSolver(board1);

    void testSolve(List<int> puzzle, bool solveAlgorithm()) {
      solver.board.puzzle = puzzle;
      solveAlgorithm();
      expect(solver.board.isSolved, true);
    }

    test('bruteForceSolve easy', () {
      testSolve(puzzles_easy50[0], solver.bruteForceSolve);
    });

    test('bruteForceSolve hard', () {
      testSolve(puzzles_hardest11[7], solver.bruteForceSolve);
    });

    test('humanSolve easy', () {
      testSolve(puzzles_easy50[0], solver.humanSolve);
    });

    test('humanSolve hard', () {
      testSolve(puzzles_hardest11[7], solver.humanSolve);
    });

  });
}