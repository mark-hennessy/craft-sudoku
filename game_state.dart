part of sudoku;

class GameState {
  List<int> _cellValues = [];
  get cellValues => _cellValues;
  set cellValues(List<int> cellValues) {
    //"Deep clone" the values so that they do not change as the puzzle is solved. 
    _cellValues = new List.from(cellValues);
  }
  
  List<Cell> changedCells = [];
  
  GameState([this._cellValues]);
  
}

