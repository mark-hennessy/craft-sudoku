part of sudoku;

typedef void CellFunction(Cell cell, int row, int column);

class Board {
  static final SIZE = 9;
  
  List<List<Cell>> _grid;
  
  List<Cell> get cells {
    var cells = new List<Cell>();
    for(var row in _grid) {
      cells.addAll(row);
    }
    return cells;
  }
  
  Cell getCell(int row, int column) {
    return _grid[row][column];
  }
  
  Board(List<int> cellValues) {
    //Initialize grid
    _grid = [];
    for(int r = 0; r < SIZE; r++) {
      var row = [];
      for(int c = 0; c < SIZE; c++) {
        row.add(new Cell(cellValues[r * SIZE + c]));
      }
      _grid.add(row);
    }  
    //Define row and column units
    for(int i = 0; i < SIZE; i++) {
      var rowUnit = new Unit();
      traverseCells((cell, row, column) {
        rowUnit.add(cell);
        cell.row = rowUnit;
      }, row: i, columnSpan: SIZE);
      
      var columnUnit = new Unit();
      traverseCells((cell, row, column) {
        columnUnit.add(cell);
        cell.column = columnUnit;
      }, column: i, rowSpan: SIZE);
    }
    //Define boxes
    var grayBox = false;
    for(int r = 0; r < SIZE; r+= 3) {
      for(int c = 0; c < SIZE; c+= 3) {
        var boxUnit = new Unit();
        if(grayBox) {
          boxUnit.cssClass = 'grid-gray';
        }
        grayBox = !grayBox;
        traverseCells((cell, row, column) {
          boxUnit.add(cell);
          cell.box = boxUnit;
        }, row: r, column: c, rowSpan: 3, columnSpan: 3);
      }
    }
    //Calculate peers for each cell
    cells.forEach((c) => c.calculatePeers());
  }
  
  void traverseCells(CellFunction cellFunc, {int row: 0, int column: 0, int rowSpan: 1, int columnSpan: 1}) {
    for(int r = row; r < row + rowSpan; r++) {
      for(int c = column; c < column + columnSpan; c++) {
        cellFunc(getCell(r, c), r, c);
      }
    }
  }
  
  void render() {
    var tableElement = new TableElement();
    for(int r = 0; r < SIZE; r++) {
      var rowElement = tableElement.insertRow(r);
      for(int c = 0; c < SIZE; c++) {
        Cell cell = getCell(r, c);
        rowElement.insertCell(c)
        ..text = cell.hasValidValue ? cell.value.toString() : "0"
        ..classes.add(cell.box.cssClass);
      }
    }
    var gridContainer = query('.grid');
    gridContainer.children.clear();
    gridContainer.children.add(tableElement);
  }
  
}

/**
 * A collection of cells such as a row, column or block.
 */
class Unit {
  List<Cell> cells = [];
  
  String cssClass = '';
  
  void add(Cell cell) {
    cells.add(cell);
  }
  
}

/**
 * Represents a single cell in the 81 cell grid.
 */
class Cell {
  const List<int> VALID_VALUES = const[1, 2, 3, 4, 5, 6, 7, 8, 9];
  
  Unit box;
  Unit row;
  Unit column;
  
  Set<Cell> peers;
  
  int value;
  bool get hasValidValue => VALID_VALUES.contains(value);
  
  List<int> get unavailableValues => peers
      .where((c) => c.hasValidValue)
      .mappedBy((c) => c.value).toSet().toList();
  
  List<int> get availableValues => 
      subtractListAFromListB(unavailableValues, VALID_VALUES);
  
  Cell([this.value]) {
    peers = new Set<Cell>();
  }
  
  void calculatePeers() {
    peers.addAll(box.cells);
    peers.addAll(row.cells);
    peers.addAll(column.cells);
    peers.remove(this);
  }
  
}
