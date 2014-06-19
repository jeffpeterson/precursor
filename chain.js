(function(base) {

var Chain = base.Chain = function() {
  return Chain.invoke.apply(Chain, arguments);
};

// Defines a non-enumerable value
Chain.def = function(name, fn) {
  return Object.defineProperty(this, name, {
    value: fn,
    configurable: true,
    writable: true,
    enumerable: false
  });
};

Chain.def('def', Chain.def);

Chain.def('invoke', function() {
  return this;
});

Chain.def('getter', function(name, fn) {
  return Object.defineProperty(this, name, {
    get: fn,
    configurable: true
  });
});

Chain.getter('clone', function() {
  var fn = function() {
    return fn.invoke.apply(fn, arguments);
  };

  fn.__proto__ = fn.prototype = this;

  return fn;
});

Chain.def('flag', function(flagName, props) {
  return this.getter(flagName, function() {
    return this.with(props);
  });
});

Chain.def('lazy', function(name, fn) {
  return this.getter(name, function() {
    return this.def(name, fn.call(this))[name];
  });
});

Chain.def('with', function(key, value) {
  var child = this.clone;

  if (typeof key === 'object') {
    for (var k in key) {
      if (key.hasOwnProperty(k))
        child[k] = key[k];
    }
  } else {
    child[key] = value
  }

  return child;
});

Chain.def('tap', function(fn) {
  var link = this.clone;
  fn && fn.call(link, link);
  return this;
});

Chain.def('promise', function(fn) {
  return this.clone.lazy('_promise', function() {
    return new Promise(fn.bind(this));
  });
});

Chain.def('then', function(onResolved, onRejected) {
  if (!this._promise) throw new Error("Nothing has been promised!");

  return this.clone.def('_promise', this._promise.then(onResolved, onRejected));
});

Chain.def('done', Chain.then);

Chain.def('catch', function(onRejected) {
  return this.then(undefined, onRejected);
});

})(this);
