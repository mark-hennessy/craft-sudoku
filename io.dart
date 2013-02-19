part of sudoku;

class IO {
  
  static void printDebugInfo(String text) {
    query("#debug-output")
    ..appendText(text);
  }

  static void clearDebugInfo() {
    query("#debug-output")
    ..text = "";
  }
  
}

