part of sudoku;

class GameState {
  Board _board;
  Board get board => _board;
  
  List<int> _cellValues;
  List<int> get cellValues => _cellValues == null ? board.cellValues : _cellValues;
  
  List<Cell> _changedCells = [];
  List<Cell> get changedCells => _changedCells.toList();
  
  GameState(this._board);
  
  void addChangedCell(Cell cell) {
    _changedCells.add(cell);
  }
  
  /**
   * Freeze/snapshot the game state, so that modifications to the board 
   * do not effect this state object.
   */
  void freeze() {
    _cellValues = board.cellValues.toList();
  }
  
}

