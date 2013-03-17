part of sudoku;

class BoardUI {
  
  Board _internalBoard;
  Keyboard _keyboard;
  
  BoardUI() {
    _internalBoard = new Board();
    _keyboard = new Keyboard();
  }
  
  void renderGame(Board board, [String puzzleTitle]) {
    _render(board, puzzleTitle);
  }
  
  void renderGameState(GameState gameState, [String puzzleTitle]) {
    _internalBoard.puzzle = gameState.board.puzzle;
    _internalBoard.cellValues = gameState.cellValues;
    
    void highlightRecentlyModifiedCells(Cell cell, Element cellElement) {
      if(gameState.changedCells.contains(cell)) {
        cellElement.classes.add(CSS.RECENTLY_MODIFIED_CELL);
      }
    }
    
    _render(_internalBoard, puzzleTitle, highlightRecentlyModifiedCells);
  }
  
  void _render(Board board, [String puzzleTitle, void customCellRenderBehavior(Cell cell, Element cellElement)]) {
    var elements = new List<Element>();
    
    if(?puzzleTitle) {
      var title = new HeadingElement.h3()
      ..text = puzzleTitle;
      elements.add(title);
    }
    
    var grid = constructGrid(board, customCellRenderBehavior);
    elements.add(grid);
    
    _addGridElementsToDom(elements);
  }
  
  void _addGridElementsToDom(List<Element> gridElements) {
    var div = new DivElement();
    for(var element in gridElements) {
      div.children.add(element);
    }
    div.children.add(new BRElement());
    
    var puzzleContainer = query(CSS.PUZZLE_CONTAINER_ID);
    puzzleContainer.children
    ..add(div);
  }
  
  Element constructGrid(Board board, [void customCellRenderBehavior(Cell cell, Element cellElement)]) {
    var grid = new TableElement();
    grid.classes.add(CSS.GRID);
    var cellElementMap = new Map<Cell, Element>();
    for(int r = 0; r < Board.GRID_SIZE; r++) {
      var rowElement = grid.insertRow(r);
      for(int c = 0; c < Board.GRID_SIZE; c++) {
        Cell cell = board.getCell(r, c);
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
        _initializeUserInput(cell, cellElementMap);
        _initializePeerHighlighting(cell, cellElementMap);
      }
    }
    return grid;
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
      _selectCellElement(cellElement);
    })
    ..onMouseOut.listen((e) {
      _unselectCellElement(cellElement);
    })
    ..onKeyDown.listen((e) {
      if(Keyboard.isNumericKey(e) && !cell.isValueFixed) {
        _updateCellValue(cell, cellElementMap, e);
      } else if(Keyboard.isArrowKey(e)) {
        _moveToNextCell(cell, cellElementMap, e);
      }
    });
  }

  void _selectCellElement(Element cellElement) {
    cellElement.focus();
  }
  
  void _unselectCellElement(Element cellElement) {
    cellElement.blur();
  }
  
  void _updateCellValue(Cell cell, Map<Cell, Element> cellElementMap, KeyboardEvent e) {
    var newValue = Keyboard.parseKeyAsInt(e);
    cell.value = newValue;
    _renderCellValue(cell, cellElementMap);
  }

  void _moveToNextCell(Cell cell, Map<Cell, Element> cellElementMap, KeyboardEvent e) {
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
      var nextCell = _internalBoard.getCell(row, column);
      _selectCellElement(cellElementMap[nextCell]);
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
        for(Element element in peerElements) {
          element.classes.toggle(CSS.HIGHLIGHTED_PEER_CELL);
        }
        currentHighlightState = !currentHighlightState;
      }
    }
    
    cellElementMap[cell]
    ..onFocus.listen((e) {
      if(_keyboard.isHighlightPeersKeyPressed) {
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
      if(_keyboard.isHighlightPeersKeyPressed) {
        highlightPeers(false);
      }
    });
  }
  
}