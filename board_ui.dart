part of sudoku;

class BoardUI {
  
  Board board;
  Keyboard keyboard;
  
  BoardUI() {
    board = new Board.empty();
    keyboard = new Keyboard();
  }
  
  void renderGameState(GameState gameState) {
    render(gameState.cellValues, (cell, cellElement) {
      if(gameState.changedCells.contains(cell)) {
        cellElement.classes.add('recently-modified-cell');
      }
    });
  }
  
  /**
   * Tells the board to render itself.
   */
  void render(List<int> cellValues, [void customCellRenderBehavior(Cell cell, Element cellElement)]) {
    board.cellValues = cellValues;
    
    var grid = new TableElement();
    grid.classes.add('grid');
    var cellElementMap = new Map<Cell, Element>();
    for(int r = 0; r < Board.GRID_SIZE; r++) {
      var rowElement = grid.insertRow(r);
      for(int c = 0; c < Board.GRID_SIZE; c++) {
        Cell cell = board.getCell(r, c);
        Element cellElement = rowElement.insertCell(c);
        cellElementMap[cell] = cellElement;
        cellElement.classes.add(cell.boxUnit.cssClass);
        if(?customCellRenderBehavior) {
          customCellRenderBehavior(cell, cellElement);
        }
        _renderCellValue(cell, cellElementMap);
        _initializeUserInput(cell, cellElementMap);
        _initializePeerHighlighting(cell, cellElementMap);
      }
    }
    _addGridToDom(grid);
  }
  
  void _renderCellValue(Cell cell, Map<Cell, Element> cellElementMap) {
    cellElementMap[cell].text = cell.hasValidValue ? cell.value.toString() : "";
  }
  
  void _initializeUserInput(Cell cell, Map<Cell, Element> cellElementMap) {
    var cellElement = cellElementMap[cell];
    DomUtils.makeFocusable(cellElement);
    cellElement
    ..onMouseOver.listen((e) {
      selectCellElement(cellElement);
    })
    ..onKeyDown.listen((e) {
      if(Keyboard.isNumericKey(e)) {
        updateCellValue(cell, cellElementMap, e);
      } else if(Keyboard.isArrowKey(e)) {
        moveToNextCell(cell, cellElementMap, e);
      }
    });
  }

  void selectCellElement(Element cellElement) {
    cellElement.focus();
  }
  
  void updateCellValue(Cell cell, Map<Cell, Element> cellElementMap, KeyboardEvent e) {
    var newValue = Keyboard.parseKeyAsInt(e);
    cell.value = newValue;
    _renderCellValue(cell, cellElementMap);
  }

  void moveToNextCell(Cell cell, Map<Cell, Element> cellElementMap, KeyboardEvent e) {
    var row = cell.row;
    var column = cell.column;
    if(Keyboard.isKey(KeyCode.LEFT, e)) {
      column -= 1;
    } else if(Keyboard.isKey(KeyCode.UP, e)) {
      row -= 1;
    } else if(Keyboard.isKey(KeyCode.RIGHT, e)) {
      column += 1;
    } else if(Keyboard.isKey(KeyCode.DOWN, e)) {
      row += 1;
    }
    if(Board.gridCoordinatesInBounds(row, column)) {
      var nextCell = board.getCell(row, column);
      selectCellElement(cellElementMap[nextCell]);
    }
    //prevent arrow key from moving scrollbar
    e.preventDefault();
  }
  
  void _initializePeerHighlighting(Cell cell, Map<Cell, Element> cellElementMap) {
    var currentHighlightState = false;
    
    void enablePeerHighlighting(bool enablePeerHighlighting) {
      if(enablePeerHighlighting != currentHighlightState) {
        var peerElements = cell.peers.map((c) => cellElementMap[c]);
        peerElements.forEach((e) => e.classes.toggle('peer-cell'));
        currentHighlightState = !currentHighlightState;
      }
    }
    
    cellElementMap[cell]
    ..onFocus.listen((e) {
      if(keyboard.isHighlightPeersKeyPressed) {
        enablePeerHighlighting(true);
      }
    })
    ..onBlur.listen((e) {
      enablePeerHighlighting(false);
    })
    ..onKeyDown.listen((e) {
      if(Keyboard.isKey(Keyboard.HIGHLIGHT_PEERS, e)) {
        enablePeerHighlighting(true);
      }
    })
    ..onKeyUp.listen((e) {
      if(keyboard.isHighlightPeersKeyPressed) {
        enablePeerHighlighting(false);
      }
    });
  }
  
  void _addGridToDom(Element grid) {
    var gridContainer = query('.gridContainer');
    gridContainer.children
    ..add(grid)
    ..add(new BRElement());
  }
  
}

