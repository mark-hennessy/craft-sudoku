library sudoku;

import 'dart:html';

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
  var sudokuGame = new SudokuGame();
  sudokuGame.run();
}

class SudokuGame {
  Board board;
  BoardUI board_ui;
  List<List<int>> puzzles;
  
  List<GameState> previousGameStates = [];
  GameState currentGameState;
  
  SudokuGame() {
    board = new Board();
    board_ui = new BoardUI();
    puzzles = Parser.parseSudokuData(PUZZLES_EASY_50, separator: '==');
    initializeUI();
  }
  
  void initializeUI() {
    query(CSS.CLEAR_DEBUG_OUTPUT_BUTTON_ID)
    ..onClick.listen((e) => IO.clearDebugInfo());
  }
  
  void run() {
    var puzzle = selectPuzzle();
    solve(puzzle, findHumanSolution, "Human Algorithm");
    solve(puzzle, findBruteForceSolution, "Brute Force Algorithm");
  }
  
  List<int> selectPuzzle() {
    return puzzles[0];
  }
  
  void solve(List<int> puzzle, bool findSolution(), [String title]) {
    prepareGame(puzzle);
    findSolution();
    displayGame(title);
  }
  
  void prepareGame(List<int> puzzle) {
    board.puzzle = puzzle;
    resetGameStates();
  }
  
  void resetGameStates() {
    previousGameStates.clear();
    currentGameState = new GameState(board);
    //Snapshot the initial state before any cell values have changed.
    //snapshotGameState();
  }
  
  void snapshotGameState() {
    currentGameState.freeze();
    previousGameStates.add(currentGameState);
    currentGameState = new GameState(board);
  }
  
  /**
   * The algorithm tries all available options for a cell in order. 
   * If no solution works for the rest of the board, 
   * the algorithm returns false (for “no solution”).
   * 
   * Source: http://johannesbrodwall.com/2010/04/06/why-tdd-makes-a-lot-of-sense-for-sudoko/
   */
  bool findBruteForceSolution([int cellIndex = 0]) {
    
    
    if(cellIndex == 19) {
    }
    
    if (cellIndex == Board.CELL_COUNT) return true;
    
    var cell = board.cells[cellIndex];

    if (cell.hasValue) {
      bool result = findBruteForceSolution(cellIndex + 1);
      IO.printDebugInfo("${cellIndex}\n");
      return result;
    }
    
    var available = cell.availableValues.toList();
    for(int value in available) {
      setCellValue(cell, value);
      if (findBruteForceSolution(cellIndex + 1)) {
        IO.printDebugInfo("${cellIndex}\n");
        return true;
      }
    }
    cell.clearValue;
    
    IO.printDebugInfo("${cellIndex}\n");
    return false;
  }
  
  bool findHumanSolution() {
    var emptyCellsWithOnlyOnePossibleValue = board.emptyCellsWithOnlyOnePossibleValue;
    do {
      for(var cell in emptyCellsWithOnlyOnePossibleValue) {
        setCellValue(cell, cell.availableValues.first);
        //snapshotGameState();
      }
      emptyCellsWithOnlyOnePossibleValue = board.emptyCellsWithOnlyOnePossibleValue;
    } while(emptyCellsWithOnlyOnePossibleValue.length > 0);
    
    if(board.hasContradictions) return false;
    
    if(!board.isSolved) {
      guess();
    }
  }
  
  void guess() {
    
  }
  
  void setCellValue(Cell cell, int value) {
    cell.value = value;
    currentGameState.addChangedCell(cell);
  }
  
  void displayGame([String title = ""]) {
    for(int i = 0; i < previousGameStates.length; i++) {
      board_ui.renderGameState(previousGameStates[i], "$title - State $i");
    }
    board_ui.renderGameState(currentGameState, "$title - Current State");
  }
  
}