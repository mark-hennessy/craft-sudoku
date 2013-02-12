part of sudoku;

/**
 * A function that performs operations on specific [Cell]s.
 */
typedef void CellFunction(Cell cell);

class GameState {
  Queue<List<int>> previousValues;
  List<int> currentValues;
}

/**
 * This class represents a 9x9 [Cell] Sudoku board.
 */
class Board {
  static const int GRID_SIZE = 9;
  static const int BOX_SIZE = 3; 
  
  List<Cell> cells;
  
  /**
   * Returns a [Cell] at the given row and column.
   */
  Cell getCell(int row, int column) {
    return cells[row * GRID_SIZE * column];
  }
  
  /**
   * Constructs a board using the given cell values.
   */
  Board(List<int> this._cellValues) {
    //Initialize grid
    cells = [];
    for(int r = 0; r < GRID_SIZE; r++) {
      for(int c = 0; c < GRID_SIZE; c++) {
        cells.add(new Cell(this, r, c));
      }
    }  
    //Define row and column units
    for(int i = 0; i < GRID_SIZE; i++) {
      var rowUnit = new Unit();
      traverseCells((cell) {
        rowUnit.add(cell);
        cell.rowUnit = rowUnit;
      }, row: i, columnSpan: GRID_SIZE);
      
      var columnUnit = new Unit();
      traverseCells((cell) {
        columnUnit.add(cell);
        cell.columnUnit = columnUnit;
      }, column: i, rowSpan: GRID_SIZE);
    }
    //Define boxes
    var grayBox = false;
    for(int r = 0; r < GRID_SIZE; r+= 3) {
      for(int c = 0; c < GRID_SIZE; c+= 3) {
        var boxUnit = new Unit();
        if(grayBox) {
          boxUnit.cssClass = 'grid-gray';
        }
        grayBox = !grayBox;
        traverseCells((cell) {
          boxUnit.add(cell);
          cell.boxUnit = boxUnit;
        }, row: r, column: c, rowSpan: BOX_SIZE, columnSpan: BOX_SIZE);
      }
    }
    //Calculate peers for each cell
    cells.forEach((c) => c._calculatePeers());
  }
  
  /**
   * Executes the given [CellFunction] for the given area of the board.
   */
  void traverseCells(CellFunction cellFunc, {int row: 0, int column: 0, int rowSpan: 1, int columnSpan: 1}) {
    for(int r = row; r < row + rowSpan; r++) {
      for(int c = column; c < column + columnSpan; c++) {
        cellFunc(getCell(r, c));
      }
    }
  }
  
  /**
   * Tells the board to render itself. An optional [containerSelector] can 
   * be specified to select the container DOM element for the board.
   */
  void render([String containerSelector = '.grid']) {
    var tableElement = new TableElement();
    for(int r = 0; r < GRID_SIZE; r++) {
      var rowElement = tableElement.insertRow(r);
      for(int c = 0; c < GRID_SIZE; c++) {
        Cell cell = getCell(r, c);
        rowElement.insertCell(c)
        ..text = cell.hasValidValue ? cell.value.toString() : "0"
        ..classes.add(cell.boxUnit.cssClass);
      }
    }
    var gridContainer = query(containerSelector);
    gridContainer.children.clear();
    gridContainer.children.add(tableElement);
  }
  
}

/**
 * A grouping of cells such as a row, column or block.
 */
class Unit {
  List<Cell> cells = [];
  
  String cssClass = '';
  
  /**
   * Adds the given [Cell] to the unit.
   */
  void add(Cell cell) {
    cells.add(cell);
  }
  
}

/**
 * Represents a single cell in the 81 cell [Board].
 */
class Cell {
  
  static const List<int> VALID_VALUES = const[1, 2, 3, 4, 5, 6, 7, 8, 9];
  
  Board board;
  int row;
  int column;
  int get _index => row * Board.GRID_SIZE * column;
  
  Unit boxUnit;
  Unit rowUnit;
  Unit columnUnit;
  
  Set<Cell> peers;
  
  int get value => board._cellValues[_index];
  set value(int value) => board._cellValues[_index] = value;
  
  /**
   * True if the cell's current value is a number between 1 and 9 inclusive.
   */
  bool get hasValidValue => VALID_VALUES.contains(value);
  
  /**
   * Cell values that are already taken by the cell's box, row, or column.
   */
  List<int> get unavailableValues => peers
      .where((c) => c.hasValidValue)
      .mappedBy((c) => c.value).toList();
  
  /**
   * Cell values that are not already taken by the cell's box, row, or column [Unit].
   */
  List<int> get availableValues => 
      CollectionUtils.subtractListAFromListB(unavailableValues, VALID_VALUES);
  
  /**
   * Constructor. A cell is not well-formed
   * until the [_calculatePeers] method is called.
   */
  Cell(this.board, this.row, this.column) {
    peers = new Set<Cell>();
  }
  
  /**
   * This method must be called after the box, row, and column units 
   * have been set, but before other properties are used.
   */
  void _calculatePeers() {
    peers.addAll(boxUnit.cells);
    peers.addAll(rowUnit.cells);
    peers.addAll(columnUnit.cells);
    peers.remove(this);
  }
  
}
