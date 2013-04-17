part of test_suite;

void runSolverTests() {
  group('Solver', () {

    var solver = new SudokuSolver(board1);

    void testSolve(List<int> puzzle, bool solveAlgorithm()) {
      solver.board.puzzle = puzzle;
      solveAlgorithm();
      expect(solver.board.isSolved, true);
    }

    test('bruteForceSolve', () {
      testSolve(puzzles_easy50[0], solver.bruteForceSolve);
      testSolve(puzzles_hardest11[7], solver.bruteForceSolve);
    });

    test('humanSolve', () {
      testSolve(puzzles_easy50[0], solver.humanSolve);
      testSolve(puzzles_hardest11[7], solver.humanSolve);
    });

    test('humanSolveThenBruteforce', () {
      testSolve(puzzles_easy50[0], solver.humanSolveThenBruteforce);
      testSolve(puzzles_hardest11[7], solver.humanSolveThenBruteforce);
    });

    test('humanSequenceSolve', () {
      testSolve(puzzles_easy50[0], solver.humanSequenceSolve);
      testSolve(puzzles_hardest11[7], solver.humanSequenceSolve);
    });

  });
}