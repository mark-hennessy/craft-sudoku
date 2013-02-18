part of sudoku;

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
   * Converts two-dimensional [row] and [column] coordinates and converts 
   * them to a one-dimensional list index. 
   */
  static int indexAtGridCoordinates(int row, int column) {
    return row * Board.GRID_SIZE + column;
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
    _initializeGrid();  
    _defineRowAndColumnUnits();
    _defineBoxes();
    _calculatePeersForEachCell();
  }

  void _initializeGrid() {
    for(int r = 0; r < GRID_SIZE; r++) {
      for(int c = 0; c < GRID_SIZE; c++) {
        cells.add(new Cell._internal(this, r, c));
      }
    }
  }

  void _defineRowAndColumnUnits() {
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
  }

  void _defineBoxes() {
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
  }

  void _calculatePeersForEachCell() {
    cells.forEach((c) => c._calculatePeers());
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
  
  /**
   * Tells the board to render itself.
   */
  void render() {
    var grid = new TableElement();
    grid.classes.add('grid');
    var cellElementMap = new Map<Cell, Element>();
    for(int r = 0; r < GRID_SIZE; r++) {
      var rowElement = grid.insertRow(r);
      for(int c = 0; c < GRID_SIZE; c++) {
        Cell cell = getCell(r, c);
        Element cellElement = rowElement.insertCell(c);
        cellElementMap[cell] = cellElement;
        DomUtils.makeFocusable(cellElement);
        
        void renderCellValue() {
          cellElement.text = cell.hasValidValue ? cell.value.toString() : "";
        }
        
        cellElement
        ..classes.add(cell.boxUnit.cssClass)
        ..onMouseOver.listen((e) {
          cellElement.focus();
        })
        ..onKeyDown.listen((e) {
          if(DomUtils.isNumericKeyCode(e.keyCode)) {
            var newValue = DomUtils.parseKeyCodeAsInt(e.keyCode);
            cell.value = newValue;
            renderCellValue();
          }
        });
        renderCellValue();
      }
    }
    _initializePeerHighlighting(grid, cellElementMap);
    _addGridToPage(grid);
  }
  
  void _addGridToPage(Element grid) {
    var gridContainer = query('.gridContainer');
    gridContainer.children
    ..add(grid)
    ..add(new BRElement());
  }
  
  void _initializePeerHighlighting(Element parent, Map<Cell, Element> cellElementMap) {
    bool isHighlightPeersKey(KeyboardEvent e)
      => (e.keyCode == KeyMap.HIGHLIGHT_PEERS);
    
    var isHighlightPeersKeyPressed = false;
    parent
    ..onKeyDown.listen((e) {
      if(isHighlightPeersKey(e)) {
        isHighlightPeersKeyPressed = true;
      }
    })
    ..onKeyUp.listen((e) {
      if(isHighlightPeersKey(e)) {
        isHighlightPeersKeyPressed = false;
      }
    });
    
    cellElementMap.forEach((cell, cellElement) {
      var peersHighlighted = false;
      void togglePeerHighlighting() {
        var peerElements = cell.peers.map((c) => cellElementMap[c]);
        peerElements.forEach((e) => e.classes.toggle('peer-cell'));
        peersHighlighted = !peersHighlighted;
      }
      
      cellElement
      ..onFocus.listen((e) {
        if(isHighlightPeersKeyPressed && !peersHighlighted) {
          togglePeerHighlighting();
        }
      })
      ..onBlur.listen((e) {
        if(peersHighlighted) {
          togglePeerHighlighting();
        }
      })
      ..onKeyDown.listen((e) {
        if(isHighlightPeersKey(e) && !peersHighlighted) {
          togglePeerHighlighting();
        }
      })
      ..onKeyUp.listen((e) {
        if(isHighlightPeersKeyPressed && peersHighlighted) {
          togglePeerHighlighting();
        }
      });
    });
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
      peers.where((c) => c.hasValidValue)
      .map((c) => c.value).toList();
  
  Cell._internal(this.board, this.row, this.column) {
    peers = new Set<Cell>();
  }
  
  void _calculatePeers() {
    peers.addAll(boxUnit.cells);
    peers.addAll(rowUnit.cells);
    peers.addAll(columnUnit.cells);
    peers.remove(this);
  }
  
}
