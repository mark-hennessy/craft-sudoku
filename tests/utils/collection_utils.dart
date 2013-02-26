part of test_suite;

void runCollectionUtilsTests() {
  group('CollectionUtils', () {
    test('subtractListAFromListB', () {
      var list1 = [1, 3, 2, -5];
      var list2 = [1, 3];
      expect(CollectionUtils
          .subtractListAFromListB(list1, list2), 
          unorderedEquals([]));
      expect(CollectionUtils
          .subtractListAFromListB(list2, list1), 
          unorderedEquals([2, -5]));
    });
    
    test('reverse', () {
      var list1 = [1, 3, 2, -5];
      expect(CollectionUtils.reverse(list1), 
          orderedEquals([-5, 2, 3, 1]));
    });
    
    test('compareAscending', () {
      var list1 = [1, 3, 2, -5];
      list1.sort(CollectionUtils.compareAscending);
      expect(list1, orderedEquals([-5, 1, 2, 3]));
    });
    
    test('compareDecending', () {
      var list1 = [1, 3, 2, -5];
      list1.sort(CollectionUtils.compareDecending);
      expect(list1, orderedEquals([3, 2, 1, -5]));
    });
  });
}

