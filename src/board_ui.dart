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

  List<String> _temporaryCellStyles = [CSS.CONTRADICTION_SOURCE_CELL, CSS.CONTRADICTION_CELL, CSS.HINT_CELL];

  BoardUI(Board board) {
    _board = board;

    _cellElementMap = new Map<Cell, Element>();
    _keyboard = new Keyboard();
  }

  /**
   * Update the UI. This renders the board UI, or refreshes it if it has
   * already been rendered.
   */
  void update() {
    if(isRendered) {
      refresh(boardTitle);
    } else {
      render(boardTitle);
    }
  }

  /**
   * Renders a new board UI for the given game state and title. This can be
   * helpful for visualizing specific steps in an algorithm.
   */
  void renderGameState(GameState gameState, [String stateTitle]) {
    if(_board != gameState.board)
      throw "The board for which the UI was created must match the board of the game state";

    _board.cellValues = gameState.cellValues;

    render(stateTitle);

    for(Cell cell in cells) {
      if(gameState.changedCells.contains(cell)) {
        var cellElement = _cellElementMap[cell];
        cellElement.classes.add(CSS.RECENTLY_MODIFIED_CELL);
      }
    }
  }

  /**
   * Renders a new board. If there is already boards on the screen,
   * then the new board is placed beneath them.
   */
  void render([String title]) {
    var elements = new List<Element>();

    _titleElement = new HeadingElement.h3();
    elements.add(titleElement);

    var grid = constructGrid();
    elements.add(grid);

    _addGridElementsToDom(elements);
    _isRendered = true;
    refresh(title);
  }

  /**
   * Refresh the board UI to reflect accurate title, cell values, and cell styles.
   * Refreshing the UI will remove temporary cell styles.
   */
  void refresh([String title]) {
    if(title != null) {
      _setTitle(title);
    }
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
        cellElement.classes.add(CSS.CELL);
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
    cellElement.classes.add(CSS.SELECTED_CELL);
  }

  void _unselectCellElement(Element cellElement) {
    cellElement.blur();
    cellElement.classes.remove(CSS.SELECTED_CELL);
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

  void _updateCellValue(Cell cell, KeyboardEvent e) {
    var value = Keyboard.parseKeyAsInt(e);
    updateCellValue(cell, value);
  }

  /**
   * Updates the given cell with the given value as if the player
   * had used the UI.
   */
  void updateCellValue(Cell cell, int value) {
    if(cellElements.isEmpty)
      throw "The board UI must be rendered or updated before updating specific cell values.";

    cell.value = value;
    _renderCellValue(cell);
    _updateStyle(cell);
  }

  void _updateStyle(Cell cellToUpdate) {
    for(var cell in cells) {
      _clearTemporaryCellStyle(cell);
      var recentlyChanged = (cell == cellToUpdate);
      _setTemporaryCellStyle(cell, recentlyChanged);
    }
  }

  /**
   * Clears all temporary cell styles such as styles meant to draw the player's
   * attention to hint and contradiction cells.
   */
  void clearTemporaryCellStyles() {
    for(var cell in cells) {
      _clearTemporaryCellStyle(cell);
    }
  }

  /**
   * Clears cell hints, but keeps other temporary cell styles.
   */
  void clearHints() {
    for(var cellElement in cellElements) {
      cellElement.classes.remove(CSS.HINT_CELL);
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

  /**
   * Hints the given cells to the player.
   */
  void hintCells(List<Cell> cells) {
    for(var cell in cells) {
      var cellElement = _cellElementMap[cell];
      cellElement.classes.add(CSS.HINT_CELL);
    }
  }

}