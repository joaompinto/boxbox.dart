library balldrop;

import 'dart:html';
import 'package:boxbox/boxbox.dart';

void main() {
  final simulation = new Simulation(query("#container"));
  simulation.start();
}

class Simulation {
  var canvas;
  Simulation(this.canvas);
  void start() {
  }
}


