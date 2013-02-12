part of sudoku;

/**
 * Utilites for working with collections. 
 */
class CollectionUtils {
  
  /**
   * Returns the elements in [b] that are not in [a]
   */
  static List subtractListAFromListB(List a, List b) {
    return b.where((v) => !a.contains(v)).toList();
  }
  
  /**
   * Returns a new [List] with the elements in the given [List] in reverse order.
   */
  static List reverse(List list) {
    var reversedList = new List();
    for(int i = list.length - 1; i >= 0; i--) {
      reversedList.add(list[i]);
    }
    return reversedList;
  }
  
  /**
   * Comparator function for sorting numeric collections in ascending order.
   */
  static int compareAscending(int a, int b) {
    if (a < b) {
      return -1;
    } else if (a > b) {
      return 1;
    } else {
      return 0;
    }
  }
  
  /**
   * Comparator function for sorting numeric collections in decending order.
   */
  static int compareDecending(int a, int b) {
    if (a > b) {
      return -1;
    } else if (a < b) {
      return 1;
    } else {
      return 0;
    }
  }
  
}