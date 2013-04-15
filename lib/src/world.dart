part of boxbox;

var WORLD_DEFAULT_OPTIONS = {
                             'gravity': {'x':0, 'y':10},
                             'allowSleep': true,
                             'scale': 30,
                             'tickFrequency': 50,
                             'collisionOutlines': false
};

class World {
  var _ops;
  var _world;
  var _canvas;
  var _ctx;
  var _scale;
  final _keydownHandlers = {};
  final  _keyupHandlers = {};
  final _startContactHandlers = {};
  final _finishContactHandlers = {};
  final _impactHandlers =  {};
  final _destroyQueue = [];
  final _impulseQueue = [];
  final _constantVelocities = {};
  final _constantForces = {};
  final _entities = {};
  var _nextEntityId = 0;
  var _cameraX =  0;
  var _cameraY =  0;
  final _onRender = [];
  final _onTick = [];
  final _creationQueue = [];
  final _positionQueue = [];
  World (canvasElem, options) {
    _ops = new Map.from(WORLD_DEFAULT_OPTIONS);
    final gravity = new box2d.vec2(_ops['gravity']['x'], _ops['gravity']['y']);
    _world = new box2d.World(gravity, true, new box2d.DefaultWorldPool());
    _canvas = canvasElem;
    _ctx = _canvas.getContext("2d");
    _scale = _ops['scale'];
    
    ontick_loop(Timer timer) {
      var i;
      var ctx;
      for (i = 0; i < _onTick.length; i++) {
        ctx = _onTick[i].ctx;
        if (!ctx._destroyed) {
          _onTick[i].fun.call(ctx);
        }
      }
    }
    new Timer.periodic(const Duration(milliseconds: 1) * _ops['tickFrequency'], ontick_loop);    
  }
}
