library tests;

import 'sudoku_ui.dart';
import 'package:/unittest/unittest.dart';
import 'package:/unittest/html_enhanced_config.dart';

void main() {
  useHtmlEnhancedConfiguration();
  runTests();
}

void runTests() {
  
  group('Cell', () {
    test('hasValue', () {
      var cell = new Cell.empty();
      expect(cell.hasValue, false);
      cell.value = 5;
      expect(cell.hasValue, true);
    });
  });
  
}