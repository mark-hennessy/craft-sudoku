part of sudoku;

/**
 * This class represents a 9x9 [Cell] Sudoku board.
 */
class Board {
  static const int GRID_SIZE = 9;
  static const int BOX_SIZE = 3;
  static const int CELL_COUNT = GRID_SIZE * GRID_SIZE;
  
  static int indexAtGridCoordinates(int row, int column) {
    return row * Board.GRID_SIZE + column;
  }
  
  static bool gridCoordinatesInBounds(int row, int column) {
    return [row, column].every((coord) 
        => (coord >= 0 && coord < GRID_SIZE));
  }
  
  List<int> cellValues = [];
  
  List<Unit> _units = [];
  List<Unit> get units => new List.from(_units);
  
  List<Cell> _cells = [];
  List<Cell> get cells => new List.from(_cells);
  
  List<Cell> get emptyCells => 
      _cells.where((cell) => !cell.hasValidValue).toList();
  
  List<Cell> get emptyCellsWithOnlyOnePossibleValue => 
      _cells.where((cell) => !cell.hasValidValue && cell.availableValues.length == 1).toList();
  
  List<Cell> get emptyCellsSortedByAvailableValuesAscending {
    var sortedList = emptyCells;
    sortedList.sort((c1, c2) => 
        CollectionUtils.compareAscending(c1.availableValues.length, c2.availableValues.length));
    return sortedList;
  }
  
  bool get isSolved => emptyCells.isEmpty;
  
  Cell getCell(int row, int column) {
    return _cells[indexAtGridCoordinates(row, column)];
  }
  
  Board.empty() : this(new List<int>.fixedLength(CELL_COUNT, fill: 0));
  
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
    if(cellValues.length != CELL_COUNT)
      throw new ArgumentError("cellValues must have length ${CELL_COUNT}, but was ${cellValues.length}.");
    
    _initializeGrid();
    _defineRowAndColumnUnits();
    _defineBoxes();
    _calculatePeersForEachCell();
  }

  void _initializeGrid() {
    for(int r = 0; r < GRID_SIZE; r++) {
      for(int c = 0; c < GRID_SIZE; c++) {
        _cells.add(new Cell._internal(this, r, c));
      }
    }
  }

  void _defineRowAndColumnUnits() {
    for(int i = 0; i < GRID_SIZE; i++) {
      
      var rowUnit = new Unit();
      _units.add(rowUnit);
      _traverseCells((cell) {
        rowUnit.add(cell);
        cell._rowUnit = rowUnit;
      }, row: i, columnSpan: GRID_SIZE);
      
      var columnUnit = new Unit();
      _units.add(columnUnit);
      _traverseCells((cell) {
        columnUnit.add(cell);
        cell._columnUnit = columnUnit;
      }, column: i, rowSpan: GRID_SIZE);
      
    }
  }

  void _defineBoxes() {
    var grayBox = false;
    for(int r = 0; r < GRID_SIZE; r+= BOX_SIZE) {
      for(int c = 0; c < GRID_SIZE; c+= BOX_SIZE) {
        var boxUnit = new Unit();
        _units.add(boxUnit);
        if(grayBox) {
          boxUnit.cssClass = 'grid-gray';
        }
        grayBox = !grayBox;
        _traverseCells((cell) {
          boxUnit.add(cell);
          cell._boxUnit = boxUnit;
        }, row: r, column: c, rowSpan: BOX_SIZE, columnSpan: BOX_SIZE);
      }
    }
  }

  void _calculatePeersForEachCell() {
    _cells.forEach((cell) => cell._calculatePeers());
  }
  
  /**
   * Executes the given [cellFunc] for the given area of the board.
   */
  void _traverseCells(void cellFunc(Cell cell), {int row: 0, int column: 0, int rowSpan: 1, int columnSpan: 1}) {
    for(int r = row; r < row + rowSpan; r++) {
      for(int c = column; c < column + columnSpan; c++) {
        cellFunc(getCell(r, c));
      }
    }
  }
  
}

/**
 * A grouping of cells such as a row, column or block.
 */
class Unit {
  List<Cell> _cells = [];
  List<Cell> get cells => new List.from(_cells);
  
  String cssClass = '';
  
  void add(Cell cell) {
    _cells.add(cell);
  }
  
}

/**
 * Represents a single cell in the 81 cell [Board].
 */
class Cell {
  
  static const List<int> VALID_VALUES = const[1, 2, 3, 4, 5, 6, 7, 8, 9];
  
  Board _board;
  Board get board => _board;
  
  int _row, _column;
  int get row => _row;
  int get column => _column;
  
  Unit _boxUnit, _rowUnit, _columnUnit;
  Unit get boxUnit => _boxUnit;
  Unit get rowUnit => _rowUnit;
  Unit get columnUnit => _columnUnit;
  
  Set<Cell> _peers;
  Set<Cell> get peers => new Set.from(_peers);
  
  int get value => 
      board.cellValues[Board.indexAtGridCoordinates(row, column)];
  
  set value(int value) => 
      board.cellValues[Board.indexAtGridCoordinates(row, column)] = value;
  
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
      _peers.where((c) => c.hasValidValue)
      .map((c) => c.value).toList();
  
  Cell._internal(this._board, this._row, this._column) {
    _peers = new Set<Cell>();
  }
  
  void _calculatePeers() {
    _peers.addAll(boxUnit.cells);
    _peers.addAll(rowUnit.cells);
    _peers.addAll(columnUnit.cells);
    _peers.remove(this);
  }
  
  operator ==(Object other) {
    Cell otherCell = other as Cell;
    if(otherCell == null) return false;
    return otherCell.row == this.row && 
        otherCell.column == this.column && 
        otherCell.value == this.value;
  }
  
}
