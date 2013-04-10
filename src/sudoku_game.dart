library sudoku;

import 'dart:html';
import 'dart:math';
import 'dart:async';

part 'sudoku_solver.dart';
part 'puzzle_parser.dart';
part 'board.dart';
part 'board_ui.dart';
part 'game_state.dart';
part 'style/css.dart';

part 'utils/io.dart';
part 'utils/collection_utils.dart';
part 'utils/string_utils.dart';
part 'utils/dom_utils.dart';
part 'utils/keyboard.dart';

void main() {
  var game = new SudokuGame();
  game.run();

//  visualizeHumanSequenceAlgorithm();
}

void visualizeHumanSequenceAlgorithm() {
  var game = new SudokuGame();
  game.puzzleDifficulty = "easy";
  game.puzzleIndex = 1;
  var solver = new SudokuSolver(new Board.fromPuzzle(game.puzzle));
  solver.visualizeAlgorithm(solver.humanSequenceSolve, "Human Sequence");
}

class SudokuGame {
  Random _randomGenerator;

  Map _puzzles;
  List<List<int>> get puzzlesAtDifficulty => _puzzles[puzzleDifficulty];
  List<int> get puzzle => _puzzles[puzzleDifficulty][puzzleIndex];

  String puzzleDifficulty;

  int _puzzleIndex;
  int get puzzleIndex => _puzzleIndex;
  set puzzleIndex(int index) {
    _puzzleIndex = index % puzzlesAtDifficulty.length;
  }

  String get gameTitle => "$puzzleDifficulty $puzzleIndex";

  Board _gameBoard;
  Board get gameBoard => _gameBoard;

  BoardUI _boardUI;

  SudokuSolver _solver;
  Board _solvedBoard;

  SudokuGame() {
    _randomGenerator = new Random();

    _puzzles = new Map();
    _puzzles["easy"] = Parser.parseSudokuData(PUZZLES_EASY_50, separator: '==');
    _puzzles["medium"] = Parser.parseSudokuData(PUZZLES_HARD_95);
    _puzzles["hard"] = Parser.parseSudokuData(PUZZLES_HARDEST_11);

    puzzleDifficulty = "easy";
    puzzleIndex = 0;

    _gameBoard = new Board();
    _boardUI = new BoardUI(gameBoard);

    _solvedBoard = new Board();
    _solver = new SudokuSolver(_solvedBoard);

    _initializeUI();
  }

  void run() {
    resetGame();
  }

  void _initializeUI() {
    _initializePuzzleSelection();
    _initializePuzzleControl();
    _initializeDebugInfo();
  }

  void _initializePuzzleSelection() {
    var selectElement = query(CSS.PUZZLE_DIFFICULTY_SELECT);
    selectElement
    ..onChange.listen((e) {
      selectDifficulty(selectElement.value);
    });

    query(CSS.FIRST_PUZZLE_BTN)
    ..onClick.listen((e) => firstPuzzle());
    query(CSS.PREV_PUZZLE_BTN)
    ..onClick.listen((e) => previousPuzzle());
    query(CSS.NEXT_PUZZLE_BTN)
    ..onClick.listen((e) => nextPuzzle());
    query(CSS.LAST_PUZZLE_BTN)
    ..onClick.listen((e) => lastPuzzle());
    query(CSS.RANDOM_PUZZLE_BTN)
    ..onClick.listen((e) => randomPuzzle());
  }

  void _initializePuzzleControl() {
    query(CSS.CLEAR_PUZZLE_BTN)
    ..onClick.listen((e) => clearPuzzle());
    query(CSS.SOLVE_PUZZLE_BTN)
    ..onClick.listen((e) => solvePuzzle());
  }

  void _initializeDebugInfo() {
    query(CSS.CLEAR_DEBUG_OUTPUT_BTN)
    ..onClick.listen((e) => IO.clearDebugInfo());
  }

  void selectDifficulty(String difficulty) {
    puzzleDifficulty = difficulty;
    puzzleIndex = 0;
    resetGame();
  }

  void firstPuzzle() {
    puzzleIndex = 0;
    resetGame();
  }

  void previousPuzzle() {
    puzzleIndex -= 1;
    resetGame();
  }

  void nextPuzzle() {
    puzzleIndex += 1;
    resetGame();
  }

  void lastPuzzle() {
    puzzleIndex = puzzlesAtDifficulty.length - 1;
    resetGame();
  }

  void randomPuzzle() {
    puzzleIndex = _randomGenerator.nextInt(puzzlesAtDifficulty.length);
    resetGame();
  }

  void resetGame() {
    gameBoard.puzzle = puzzle;
    _boardUI.boardTitle = gameTitle;
    _boardUI.update();
  }

  void clearPuzzle() {
    gameBoard.clearPuzzle();
    _boardUI.update();
  }

  Future solvePuzzle() {
    _solvedBoard.puzzle = gameBoard.puzzle;
    // Runs async
    Future future = new Future.of(() {
      _solver.bruteForceSolve();
    }).then((unused) {
      gameBoard.cellValues = _solvedBoard.cellValues;
      _boardUI.update();
    });
    return future;
  }

}