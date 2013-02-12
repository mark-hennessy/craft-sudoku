part of sudoku;

/**
 * A function that performs operations on specific [Cell]s.
 */
typedef void CellFunction(Cell cell);

/**
 * Converts two-dimensional [row] and [column] coordinates and converts 
 * them to a one-dimensional list index. 
 */
int indexAtGridCoordinates(int row, int column) {
  return row * Board.GRID_SIZE + column;
}

/**
 * This class represents a 9x9 [Cell] Sudoku board.
 */
class Board {
  static const int GRID_SIZE = 9;
  static const int BOX_SIZE = 3; 
  
  List<int> cellValues;
  
  List<Unit> units = [];
  List<Cell> cells = [];
  List<Cell> get emptyCells => 
      cells.where((c) => !c.hasValidValue).toList();
  List<Cell> get emptyCellsWithOnlyOnePossibleValue => 
      cells.where((c) => !c.hasValidValue && c.availableValues.length == 1).toList();
  List<Cell> get emptyCellsSortedByAvailableValuesAscending {
    var sortedList = emptyCells;
    sortedList.sort((c1, c2) => 
        CollectionUtils.compareAscending(c1.availableValues.length, c2.availableValues.length));
    return sortedList;
  }
  
  bool get isSolved => emptyCells.isEmpty;
  
  /**
   * Returns a [Cell] at the given [row] and [column].
   */
  Cell getCell(int row, int column) {
    return cells[indexAtGridCoordinates(row, column)];
  }
  
  /**
   * Constructs the [Board], [Cell]s and [Unit]s.
   * 
   * The process of calculating and storing information about cells and 
   * their relationships is slow and memory intensive. Although the values 
   * of cells change, the relationships between cells do not. Because of this,
   * the board is designed as a flyweight object. Its only state/context is
   * a list [cellValues].
   */
  Board(List<int> this.cellValues) {
    // Initialize grid
    for(int r = 0; r < GRID_SIZE; r++) {
      for(int c = 0; c < GRID_SIZE; c++) {
        cells.add(new Cell._internal(this, r, c));
      }
    }  
    // Define row and column units
    for(int i = 0; i < GRID_SIZE; i++) {
      
      var rowUnit = new Unit();
      units.add(rowUnit);
      _traverseCells((cell) {
        rowUnit.add(cell);
        cell.rowUnit = rowUnit;
      }, row: i, columnSpan: GRID_SIZE);
      
      var columnUnit = new Unit();
      units.add(columnUnit);
      _traverseCells((cell) {
        columnUnit.add(cell);
        cell.columnUnit = columnUnit;
      }, column: i, rowSpan: GRID_SIZE);
      
    }
    
    // Define boxes
    var grayBox = false;
    for(int r = 0; r < GRID_SIZE; r+= 3) {
      for(int c = 0; c < GRID_SIZE; c+= 3) {
        var boxUnit = new Unit();
        units.add(boxUnit);
        if(grayBox) {
          boxUnit.cssClass = 'grid-gray';
        }
        grayBox = !grayBox;
        _traverseCells((cell) {
          boxUnit.add(cell);
          cell.boxUnit = boxUnit;
        }, row: r, column: c, rowSpan: BOX_SIZE, columnSpan: BOX_SIZE);
      }
    }
    // Calculate peers for each cell
    cells.forEach((c) => c._calculatePeers());
  }
  
  /**
   * Executes the given [CellFunction] for the given area of the board.
   */
  void _traverseCells(CellFunction cellFunc, {int row: 0, int column: 0, int rowSpan: 1, int columnSpan: 1}) {
    for(int r = row; r < row + rowSpan; r++) {
      for(int c = column; c < column + columnSpan; c++) {
        cellFunc(getCell(r, c));
      }
    }
  }
  
  /**
   * Tells the board to render itself.
   */
  void render() {
    var tableElement = new TableElement();
    tableElement.classes.add('grid');
    for(int r = 0; r < GRID_SIZE; r++) {
      var rowElement = tableElement.insertRow(r);
      for(int c = 0; c < GRID_SIZE; c++) {
        Cell cell = getCell(r, c);
        rowElement.insertCell(c)
        ..text = cell.hasValidValue ? cell.value.toString() : ""
        ..classes.add(cell.boxUnit.cssClass);
      }
    }
    var gridContainer = query('.gridContainer');
    gridContainer.children.add(tableElement);
    gridContainer.children.add(new BRElement());
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
  
  Unit boxUnit;
  Unit rowUnit;
  Unit columnUnit;
  
  Set<Cell> peers;
  
  int get value => 
      board.cellValues[indexAtGridCoordinates(row, column)];
  
  set value(int value) => 
      board.cellValues[indexAtGridCoordinates(row, column)] = value;
  
  /**
   * True if the cell's current value is a number between 1 and 9 inclusive.
   */
  bool get hasValidValue => VALID_VALUES.contains(value);
  
  /**
   * Cell values that are not already taken by the cell's box, row, or column [Unit].
   */
  List<int> get availableValues => 
      CollectionUtils.subtractListAFromListB(unavailableValues, VALID_VALUES);
  
  /**
   * Cell values that are already taken by the cell's box, row, or column.
   */
  List<int> get unavailableValues => 
      peers.where((c) => c.hasValidValue)
      .map((c) => c.value).toList();
  
  /**
   * Constructor. A cell is not well-formed
   * until the [_calculatePeers] method is called.
   */
  Cell._internal(this.board, this.row, this.column) {
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
