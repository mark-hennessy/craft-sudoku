part of sudoku;

/**
 * Utilities for working with DOM elements.
 */
class DomUtils {
  
  /**
   * Makes the given [Element] focusable.
   */
  static void makeFocusable(Element element) {
    if(element.tabIndex == null || element.tabIndex < 0) {
      element.tabIndex = 0;
    }
  }
  
}

