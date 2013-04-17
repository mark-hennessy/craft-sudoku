part of sudoku;

/**
 * Utilities for working with IO.
 */
class IO {
  
  static void printDebugInfo(String text) {
    query(CSS.DEBUG_OUTPUT)
    ..appendText(text);
  }

  static void clearDebugInfo() {
    query(CSS.DEBUG_OUTPUT)
    ..text = "";
  }
  
}

