part of sudoku;

/**
 * Utilities for working with IO.
 */
class IO {
  
  static void printDebugInfo(String text) {
    query(CSS.DEBUG_OUTPUT_ID)
    ..appendText(text);
  }

  static void clearDebugInfo() {
    query(CSS.DEBUG_OUTPUT_ID)
    ..text = "";
  }
  
}

