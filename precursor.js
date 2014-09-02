(function(base) {

function Precursor() {
  return Precursor.invoke.apply(Precursor, arguments);
};

// Defines a non-enumerable value
Precursor.def = function def(name, fn) {
  if (typeof name === 'function') {
    fn = name, name = fn.name;
  }

  return Object.defineProperty(this, name, {
    value: fn,
    configurable: true,
    writable: true,
    enumerable: false
  });
};

Precursor.def(Precursor.def);

Precursor.def(function invoke() {
  return this;
});

Precursor.def(function getter(name, fn) {
  if (typeof name === 'function') {
    fn = name, name = fn.name;
  }

  return Object.defineProperty(this, name, {
    get: !fn.length ? fn : function get() {
      return fn.call(this, this);
    },
    set: function(value) {
      Object.defineProperty(this, name, {
        value: value,
        writable: true,
        enumerable: true,
        configurable: true
      });
      return this;
    },
    configurable: true
  });
});

Precursor.getter(function clone() {
  function pre() {
    return pre.invoke.apply(pre, arguments);
  }

  pre.__proto__ = pre.prototype = this;
  pre.def('precursor', this);

  return pre;
});

Precursor.def(function flag(flagName, props) {
  return this.getter(flagName, function() {
    return this.with(props);
  });
});

Precursor.def(function lazy(name, fn) {
  if (typeof name === 'function') {
    fn = name, name = fn.name;
  }

  return this.getter(name, function() {
    return this.def(name, fn.call(this, this))[name];
  });
});

Precursor.def('with', function(key, value) {
  return this.tap(function() {
    if (typeof key === 'object') {
      for (var k in key) {
        this[k] = key[k];
      }
    } else {
      this[key] = value;
    }
  });
});

Precursor.def(function tap(fn) {
  var clone = this.clone;
  fn && fn.call(clone, clone);
  return clone;
});

Precursor.lazy('Promise', function() {
  return Promise;
});

Precursor.def(function promise(fn) {
  return this.clone.lazy('_promise', function() {
    return new this.Promise(fn.bind(this));
  });
});

Precursor.def(function then(onResolved, onRejected) {
  if (!this._promise) throw new Error('Nothing has been promised!');

  onResolved = onResolved && onResolved.bind(this);
  onRejected = onRejected && onRejected.bind(this);

  return this.clone.def('_promise', this._promise.then(onResolved, onRejected));
});

Precursor.def('done', Precursor.then);

Precursor.def('catch', function(onRejected) {
  return this.then(undefined, onRejected);
});

base.Precursor = Precursor;

})(this);
