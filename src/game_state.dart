part of sudoku;

class GameState {
  Board _board;
  Board get board => _board;
  
  bool isFrozen = false;
  
  List<int> _cellValues;
  List<int> get cellValues => isFrozen ? _cellValues : board.cellValues;
  
  List<Cell> _changedCells = [];
  List<Cell> get changedCells => _changedCells.toList();
  
  GameState(this._board);
  
  void addChangedCell(Cell cell) {
    _changedCells.add(cell);
  }
  
  /**
   * Freeze/snapshot the game state, so that modifications to the board 
   * do not effect the [cellValues] property of this state object.
   */
  void freezeCellValues() {
    isFrozen = true;
    _cellValues = board.cellValues.toList();
  }
  
  /**
   * Unfreezing the game state will make the [cellValues] property
   * return the current cell values of the board.
   */
  void unfreezeCellValues() {
    isFrozen = false;
  }
}

