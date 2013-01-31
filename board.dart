part of sudoku;

class Board {
  List<List<Cell>> grid;
  
  Board() {
  }
  
}

class Cell {
  int value;
  List<Rule> rules;
  
  Cell.empty();
  Cell(this.value);
  
  bool get hasValue => value != null;
  
  List<int> get possibleValues {
    //var possible = [1..9];
    return null;
  }
  
  void addRule(Rule rule) {
    rules.add(rule);
  }
  
}

class Rule {
  int x, y, width, hight;
  
  Rule(this.x, this.y, this.width, this.hight);
  
  List<Cell> get cells {
    return null;
  }
  
}
