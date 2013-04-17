part of sudoku;

/**
 * Utilities for working with [String]s.
 */
class StringUtils {
  
  /**
   * Returns a list of the characters in the given String.
   */
  static List<String> splitChars(String stringToSplit) {
    return stringToSplit.runes
        .map((c) => new String.fromCharCode(c)).toList();
  }
  
}

