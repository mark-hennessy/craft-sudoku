part of test_suite;

void runSudokuTests() {
  group('Sudoku', () {
    
    void testSolve(List<int> puzzle, bool solveAlgorithm()) {
      sudoku.prepareGame(puzzle);
      solveAlgorithm();
      expect(sudoku.board.isSolved, true);
    }
    
    test('bruteForceSolveAlgorithm easy', () {
      testSolve(puzzles_easy50[0], sudoku.bruteForceSolveAlgorithm);
    });
    
    test('bruteForceSolveAlgorithm hard', () {
      testSolve(puzzles_hardest11[7], sudoku.bruteForceSolveAlgorithm);
    });

    test('humanSolveAlgorithm easy', () {
      testSolve(puzzles_easy50[0], sudoku.humanSolveAlgorithm);
    });
    
//    test('humanSolveAlgorithm hard', () {
//      testSolve(puzzles_hardest11[7], sudoku.humanSolveAlgorithm);
//    });

  });
}