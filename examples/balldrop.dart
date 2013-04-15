library balldrop;

import 'dart:html';
import 'package:boxbox/boxbox.dart' as bb;

void main() {
  final simulation = new Simulation(query("#container"));
  simulation.start();
}

class Simulation {
  var canvas;
  var _world;
  Simulation(this.canvas) {
    _world = new bb.World(canvas, {});
  }
  void start() {
  }
}


