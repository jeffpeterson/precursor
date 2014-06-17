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

Chain.def('attr', function(name, fn) {
  return Object.defineProperty(this, name, {
    get: fn,
    enumerable: true,
    configurable: true
  });
});

Chain.def('flag', function(flagName, props) {
  return this.getter(flagName, function() {
    return this.set(props);
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

Chain.def('set', Chain.with);

Chain.def('tap', function(fn) {
  var link = this.clone;
  fn && fn.call(link, link);
  return this;
});

Chain.def('promise', function(fn) {
  this._promise = new Promise(fn);
  return this;
});

Chain.def('resolve', function(value) {
  this._promise = Promise.resolve(value);
  return this
});

Chain.def('reject', function(error) {
  this._promise = Promise.reject(error);
  return this
});

Chain.def('then', function(onResolved, onRejected) {
  if (!this._promise) throw new Error("Nothing has been promised!");

  return this.set('_promise', this._promise.then(onResolved, onRejected));
});

Chain.def('done', Chain.then);

Chain.def('catch', function(onRejected) {
  if (!this._promise) throw new Error("Nothing has been promised!");

  return this.set('_promise', this._promise.catch(onRejected));
});

})(this);
