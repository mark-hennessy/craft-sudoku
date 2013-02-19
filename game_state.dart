part of sudoku;

class GameState {
  List<int> cellValues = [];
  List<Cell> changedCells = [];
  
  GameState(List<int> this.cellValues);
  
  /**
   * Freeze/snapshot the game state, so that modifications to the board 
   * do not effect this state object.
   */
  void freeze() {
    cellValues = new List.from(cellValues);
  }
}

