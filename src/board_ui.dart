part of sudoku;

class BoardUI {
  Board _board;

  String boardTitle;

  HeadingElement _titleElement;
  HeadingElement get titleElement => _titleElement;

  Map<Cell, Element> _cellElementMap;
  List<Cell> get cells => _cellElementMap.keys.toList();
  List<Element> get cellElements => _cellElementMap.values.toList();

  Keyboard _keyboard;

  bool _isRendered = false;
  bool get isRendered => _isRendered;

  List<String> _temporaryCellStyles = [CSS.CONTRADICTION_SOURCE_CELL, CSS.CONTRADICTION_CELL];

  BoardUI(Board board) {
    _board = board;

    _cellElementMap = new Map<Cell, Element>();
    _keyboard = new Keyboard();
  }

  void update([String puzzleTitle]) {
    if(isRendered) {
      refresh(boardTitle);
    } else {
      render(boardTitle);
    }
  }

  void renderGameState(GameState gameState, [String puzzleTitle]) {
    if(_board != gameState.board)
      throw "The board for which the UI was created must match the board of the game state";

    _board.cellValues = gameState.cellValues;

    render(puzzleTitle);

    for(Cell cell in cells) {
      if(gameState.changedCells.contains(cell)) {
        var cellElement = _cellElementMap[cell];
        cellElement.classes.add(CSS.RECENTLY_MODIFIED_CELL);
      }
    }
  }

  void render([String puzzleTitle]) {
    var elements = new List<Element>();

    _titleElement = new HeadingElement.h3();
    elements.add(titleElement);

    var grid = constructGrid();
    elements.add(grid);

    _addGridElementsToDom(elements);
    _isRendered = true;
    refresh(puzzleTitle);
  }

  void refresh([String puzzleTitle]) {
    _setTitle(puzzleTitle);
    for(var cell in cells) {
      _renderCellValue(cell);
      _setCellStyle(cell);
      _clearTemporaryCellStyle(cell);
    }
  }

  void _setTitle(String title) {
    titleElement.text = title != null ? title : "";
  }

  void _setCellStyle(Cell cell) {
    var cellElement = _cellElementMap[cell];
    if(cell.isValueFixed) {
      cellElement.classes.add(CSS.FIXED_VALUE_CELL);
    } else {
      cellElement.classes.remove(CSS.FIXED_VALUE_CELL);
    }
  }

  void _addGridElementsToDom(List<Element> gridElements) {
    var div = new DivElement();
    for(var element in gridElements) {
      div.children.add(element);
    }
    div.children.add(new BRElement());

    var puzzleContainer = query(CSS.PUZZLE_CONTAINER);
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
    var value = Keyboard.parseKeyAsInt(e);
    updateCellValue(cell, value);
  }

  void updateCellValue(Cell cell, int value) {
    cell.value = value;
    _renderCellValue(cell);
    _updateStyle(cell);
  }

  void _updateStyle(Cell cell) {
    for(var c in cells) {
      _clearTemporaryCellStyle(c);
      var recentlyChanged = (c == cell);
      _setTemporaryCellStyle(c, recentlyChanged);
    }
  }

  void _clearTemporaryCellStyle(Cell cell) {
    var cellElement = _cellElementMap[cell];
    for(var style in _temporaryCellStyles) {
      cellElement.classes.remove(style);
    }
  }

  void _setTemporaryCellStyle(Cell cell, bool recentlyChanged) {
    var cellElement = _cellElementMap[cell];
    if(cell.hasContradiction) {
      var contradictionStyle = recentlyChanged ? CSS.CONTRADICTION_SOURCE_CELL : CSS.CONTRADICTION_CELL;
      cellElement.classes.add(contradictionStyle);
    }
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