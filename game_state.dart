part of sudoku;

class GameState {
  List<int> cellValues = [];
  
  List<Cell> _changedCells = [];
  List<Cell> get changedCells => new List.from(_changedCells);
  
  GameState(List<int> this.cellValues);
  
  void addChangedCell(Cell cell) {
    _changedCells.add(cell);
  }
  
  /**
   * Freeze/snapshot the game state, so that modifications to the board 
   * do not effect this state object.
   */
  void freeze() {
    cellValues = new List.from(cellValues);
  }
  
}

