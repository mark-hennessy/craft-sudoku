part of sudoku;

class StringUtils {
  
  static List<String> splitChars(String stringToSplit) {
    return stringToSplit.runes
        .map((c) => new String.fromCharCode(c)).toList();
  }
  
}

