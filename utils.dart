part of sudoku;

/**
 * Returns the elements in [b] that are not in [a]
 */
List subtractListAFromListB(List a, List b) {
  return b.where((v) => !a.contains(v)).toList();
}

List reverse(List list) {
  var reversedList = new List();
  for(int i = list.length - 1; i >= 0; i--) {
    reversedList.add(list[i]);
  }
  return reversedList;
}

int compareAcending(int a, int b) {
  if (a < b) {
    return -1;
  } else if (a > b) {
    return 1;
  } else {
    return 0;
  }
}

int compareDecending(int a, int b) {
  if (a > b) {
    return -1;
  } else if (a < b) {
    return 1;
  } else {
    return 0;
  }
}