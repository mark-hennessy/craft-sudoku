part of sudoku;

class BoardUI {
  
  Board boardToRender;
  Keyboard keyboard;
  
  BoardUI() {
    boardToRender = new Board();
    keyboard = new Keyboard();
  }
  
  void renderGameState(Board gameBoard, GameState gameState) {
    boardToRender.puzzle = gameBoard.originalPuzzle;
    boardToRender.cellValues = gameState.cellValues;
    
    void highlightRecentlyModifiedCells(Cell cell, Element cellElement) {
      if(gameState.changedCells.contains(cell)) {
        cellElement.classes.add(CSS.RECENTLY_MODIFIED_CELL);
      }
    }
    
    render(boardToRender, highlightRecentlyModifiedCells);
  }
  
  /**
   * Tells the board to render itself.
   */
  void render(Board board, [void customCellRenderBehavior(Cell cell, Element cellElement)]) {
    var grid = new TableElement();
    grid.classes.add(CSS.GRID);
    var cellElementMap = new Map<Cell, Element>();
    for(int r = 0; r < Board.GRID_SIZE; r++) {
      var rowElement = grid.insertRow(r);
      for(int c = 0; c < Board.GRID_SIZE; c++) {
        Cell cell = boardToRender.getCell(r, c);
        Element cellElement = rowElement.insertCell(c);
        cellElementMap[cell] = cellElement;
        cellElement.classes.add(cell.boxUnit.cssClass);
        if(cell.isValueFixed) {
          cellElement.classes.add(CSS.FIXED_VALUE_CELL);
        }
        if(?customCellRenderBehavior) {
          customCellRenderBehavior(cell, cellElement);
        }
        _renderCellValue(cell, cellElementMap);
        if(!cell.isValueFixed) {
          _initializeUserInput(cell, cellElementMap);
        }
        _initializePeerHighlighting(cell, cellElementMap);
      }
    }
    _addGridToDom(grid);
  }
  
  void _renderCellValue(Cell cell, Map<Cell, Element> cellElementMap) {
    cellElementMap[cell]
    ..text = cell.hasValue ? cell.value.toString() : "";
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
    if(Keyboard.isEventForKey(e, KeyCode.LEFT)) {
      column -= 1;
    } else if(Keyboard.isEventForKey(e, KeyCode.UP)) {
      row -= 1;
    } else if(Keyboard.isEventForKey(e, KeyCode.RIGHT)) {
      column += 1;
    } else if(Keyboard.isEventForKey(e, KeyCode.DOWN)) {
      row += 1;
    }
    if(Board.gridCoordinatesInBounds(row, column)) {
      var nextCell = boardToRender.getCell(row, column);
      selectCellElement(cellElementMap[nextCell]);
    }
    _preventScrollbarFromMoving(e);
  }
  
  void _preventScrollbarFromMoving(KeyboardEvent event) {
    event.preventDefault();
  }
  
  void _initializePeerHighlighting(Cell cell, Map<Cell, Element> cellElementMap) {
    var currentHighlightState = false;
    
    void highlightPeers(bool highlight) {
      if(highlight != currentHighlightState) {
        var peerElements = cell.peers.map((c) => cellElementMap[c]);
        peerElements.forEach((e) => e.classes.toggle(CSS.PEER_CELL));
        currentHighlightState = !currentHighlightState;
      }
    }
    
    cellElementMap[cell]
    ..onFocus.listen((e) {
      if(keyboard.isHighlightPeersKeyPressed) {
        highlightPeers(true);
      }
    })
    ..onBlur.listen((e) {
      highlightPeers(false);
    })
    ..onKeyDown.listen((e) {
      if(Keyboard.isEventForKey(e, Keyboard.HIGHLIGHT_PEERS_KEY)) {
        highlightPeers(true);
      }
    })
    ..onKeyUp.listen((e) {
      if(keyboard.isHighlightPeersKeyPressed) {
        highlightPeers(false);
      }
    });
  }
  
  void _addGridToDom(Element grid) {
    var gridContainer = query(CSS.GRID_CONTAINER_ID);
    gridContainer.children
    ..add(grid)
    ..add(new BRElement());
  }
  
}

