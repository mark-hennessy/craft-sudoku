part of test_suite;

void runDomUtilsTests() {
  group('DomUtils', () {
    test('makeFocusable', () {
      var divElement = new DivElement();
      expect(divElement.tabIndex, -1);
      
      DomUtils.makeFocusable(divElement);
      expect(divElement.tabIndex, equals(0));
      
      var customTabIndex = 5;
      divElement.tabIndex = customTabIndex;
      DomUtils.makeFocusable(divElement);
      expect(divElement.tabIndex, equals(customTabIndex));
    });
  });
}



