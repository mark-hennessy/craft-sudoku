part of sudoku;

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

