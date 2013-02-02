part of sudoku;

typedef void CellFunction(Cell cell, int row, int column);

class Board {
  static final SIZE = 9;
  
  List<List<Cell>> _grid;
  
  Board(List<int> values) {
    //Initialize grid
    _grid = [];
    for(int r = 0; r < SIZE; r++) {
      var row = [];
      for(int c = 0; c < SIZE; c++) {
        row.add(new Cell(values[r * SIZE + c]));
      }
      _grid.add(row);
    }  
    //Define row and column units
    for(int i = 0; i < SIZE; i++) {
      _defineUnit(row: i, columnSpan: SIZE);
      _defineUnit(column: i, rowSpan: SIZE);
    }
    //Define boxes
    for(int r = 0; r < SIZE; r+= 3) {
      for(int c = 0; c < SIZE; c+= 3) {
        _defineUnit(row: r, column: c, rowSpan: 3, columnSpan: 3);
      }
    }
    
    
  }
  
  _defineUnit({int row: 0, int column: 0, int rowSpan: 1, int columnSpan: 1}) {
    Unit unit = new Unit();
    for(int r = row; r < row + rowSpan; r++) {
      for(int c = column; c < column + columnSpan; c++) {
        unit.add(_grid[r][c]);
      }
    }
  }

  Cell getCell(int row, int column) {
    return _grid[row][column];
  }
  
  void forEachCell(CellFunction cellFunc) {
    for(int r = 0; r < SIZE; r++) {
      for(int c = 0; c < SIZE; c++) {
        cellFunc(_grid[r][c], r, c);
      }
    }  
  }
  
}

class Unit {
  List<Cell> cells = [];
  
  void add(Cell cell) {
    cells.add(cell);
    cell.addUnit(this);
  }
  
}

class Cell {
  List<Unit> units = [];
  List<Cell> peers = [];
  
  int value;
  
  bool get hasValue => value > 0 && value < 10;
  
  Cell(this.value);
  
  void addUnit(Unit unit) {
    units.add(unit);
  }
  
  void addPeer(Cell peer) {
    
  }
  
  List<int> get possibleValues {
  }
  
}
