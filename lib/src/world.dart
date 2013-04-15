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
    final world = _world;
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

    // animation loop
    void animationLoop(num _) {
      var key;
      var entity;
      var v;
      var impulse;
      var f;
      var toDestroy;
      var id;
      var o;

      // set velocities for this step
      for (key in _constantVelocities.keys) {
        v = _constantVelocities[key];
        v.body.SetLinearVelocity(new box2d.vec2(v.x, v.y),
            v.body.GetWorldCenter());
      }

      // apply impulses for this step
      for (var i = 0; i < _impulseQueue.length; i++) {
        impulse = _impulseQueue.removeLast();
        impulse.body.ApplyImpulse(new box2d.vec2(impulse.x, impulse.y),
            impulse.body.GetWorldCenter());
      }

      // set forces for this step
      for (key in _constantForces.keys) {
        f = _constantForces[key];
        f.body.ApplyForce(new box2d.vec2(f.x, f.y),
            f.body.GetWorldCenter());
      }

      for (key in _entities.keys) {
        entity = _entities[key];
        v = entity._body.GetLinearVelocity();
        if (v.x > entity._ops.maxVelocityX) {
          v.x = entity._ops.maxVelocityX;
        }
        if (v.x < -entity._ops.maxVelocityX) {
          v.x = -entity._ops.maxVelocityX;
        }
        if (v.y > entity._ops.maxVelocityY) {
          v.y = entity._ops.maxVelocityY;
        }
        if (v.y < -entity._ops.maxVelocityY) {
          v.y = -entity._ops.maxVelocityY;
        }
      }

      // destroy
      for (var i = 0; i < _destroyQueue.length; i++) {
        toDestroy = _destroyQueue.removeLast();
        id = toDestroy._id;
        world.DestroyBody(toDestroy._body);
        toDestroy._destroyed = true;
        _keydownHandlers.remove(id);
        _startContactHandlers.remove(id);
        _finishContactHandlers.remove(id);
        _destroyQueue.remove(id);
        _impulseQueue.remove(id);
        _constantVelocities.remove(id);
        _constantForces.remove(id);
        _entities.remove(id);
      }

      // framerate, velocity iterations, position iterations
      world.Step(1 / 60, 10, 10);

      // create
      for (var i = 0; i < _creationQueue.length; i++) {
        createEntity(_creationQueue.removeLast());
      }

      // position
      for (var i = 0; i < _positionQueue.length; i++) {
        o = _positionQueue.removeLast();
        o.o.position.call(o.o, o.val);
      }

      // render stuff
      for (key in _entities.keys) {
        entity = _entities[key];
        entity._draw(_ctx,
            entity.canvasPosition().x,
            entity.canvasPosition().y);
      }
      for (var i = 0; i < _onRender.length; i++) {
        _onRender[i].fun.call(_onRender[i].ctx, _ctx);
      }

      world.ClearForces();
      world.DrawDebugData();

      window.requestAnimationFrame(animationLoop);
    }
  }
}
