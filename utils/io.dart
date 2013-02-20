part of sudoku;

class IO {
  
  static String debugOutputCssClass = "#debug-output";
  
  static void printDebugInfo(String text) {
    query(debugOutputCssClass)
    ..appendText(text);
  }

  static void clearDebugInfo() {
    query(debugOutputCssClass)
    ..text = "";
  }
  
}

