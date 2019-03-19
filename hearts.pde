import java.util.*;
import hearts.*;

void setup() {
  List<Integer> result = new Match(new TestAlgorithm(), new GreatAlgorithm(), new RandomAlgorithm(), new RandomAlgorithm()).run();
  println("平均失点");
  println(result);
}

void draw() {
  exit();
}
