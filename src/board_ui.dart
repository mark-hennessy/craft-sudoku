part of sudoku;

class BoardUI {
  Board _board;
  Map<Cell, Element> _cellElementMap;
  Keyboard _keyboard;

  BoardUI(Board board) {
    _board = board;

    _cellElementMap = new Map<Cell, Element>();
    _keyboard = new Keyboard();
  }

  void renderGameState(GameState gameState, [String puzzleTitle]) {
    if(_board != gameState.board)
      throw "The board for which the UI was created must match the board of the game state";

    _board.cellValues = gameState.cellValues;

    render(puzzleTitle);

    for(Cell cell in _cellElementMap.keys) {
      if(gameState.changedCells.contains(cell)) {
        _cellElementMap[cell].classes.add(CSS.RECENTLY_MODIFIED_CELL);
      }
    }
  }

  void render([String puzzleTitle]) {
    var elements = new List<Element>();

    if(?puzzleTitle) {
      var title = new HeadingElement.h3()
      ..text = puzzleTitle;
      elements.add(title);
    }

    var grid = constructGrid();
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

  Element constructGrid() {
    var grid = new TableElement();
    grid.classes.add(CSS.GRID);
    for(int r = 0; r < Board.GRID_SIZE; r++) {
      var rowElement = grid.insertRow(r);
      for(int c = 0; c < Board.GRID_SIZE; c++) {
        Cell cell = _board.getCell(r, c);
        Element cellElement = rowElement.insertCell(c);
        _cellElementMap[cell] = cellElement;
        cellElement.classes.add(cell.boxUnit.cssClass);
        if(cell.isValueFixed) {
          cellElement.classes.add(CSS.FIXED_VALUE_CELL);
        }
        _renderCellValue(cell);
        _initializeUserInput(cell);
        _initializePeerHighlighting(cell);
      }
    }
    return grid;
  }

  void _renderCellValue(Cell cell) {
    _cellElementMap[cell]
    ..text = cell.hasValue ? cell.value.toString() : "";
  }

  void _initializeUserInput(Cell cell) {
    var cellElement = _cellElementMap[cell];
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
        _updateCellValue(cell, e);
      } else if(Keyboard.isArrowKey(e)) {
        _moveToNextCell(cell, e);
      }
    });
  }

  void _selectCellElement(Element cellElement) {
    cellElement.focus();
  }

  void _unselectCellElement(Element cellElement) {
    cellElement.blur();
  }

  void _updateCellValue(Cell cell, KeyboardEvent e) {
    var newValue = Keyboard.parseKeyAsInt(e);
    cell.value = newValue;
    _renderCellValue(cell);
  }

  void _moveToNextCell(Cell cell, KeyboardEvent e) {
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
      var nextCell = _board.getCell(row, column);
      _selectCellElement(_cellElementMap[nextCell]);
    }
    _preventScrollbarFromMoving(e);
  }

  void _preventScrollbarFromMoving(KeyboardEvent event) {
    event.preventDefault();
  }

  void _initializePeerHighlighting(Cell cell) {
    var currentHighlightState = false;

    void highlightPeers(bool highlight) {
      if(highlight != currentHighlightState) {
        var peerElements = cell.peers.map((c) => _cellElementMap[c]);
        for(Element element in peerElements) {
          element.classes.toggle(CSS.HIGHLIGHTED_PEER_CELL);
        }
        currentHighlightState = !currentHighlightState;
      }
    }

    _cellElementMap[cell]
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