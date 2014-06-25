(function(base) {

function Chain() {
  return Chain.invoke.apply(Chain, arguments);
};

// Defines a non-enumerable value
Chain.def = function def(name, fn) {
  if (typeof name == 'function') {
    fn = name;
    name = fn.name;
  }

  return Object.defineProperty(this, name, {
    value: fn,
    configurable: true,
    writable: true,
    enumerable: false
  });
};

Chain.def(Chain.def);

Chain.def(function invoke() {
  return this;
});

Chain.def(function getter(name, fn) {
  if (typeof name == 'function') {
    fn = name;
    name = fn.name;
  }

  return Object.defineProperty(this, name, {
    get: fn,
    configurable: true
  });
});

Chain.getter(function clone() {
  function link() {
    return link.invoke.apply(link, arguments);
  };

  link.__proto__ = link.prototype = this;

  return link;
});

Chain.def(function flag(flagName, props) {
  return this.getter(flagName, function() {
    return this.with(props);
  });
});

Chain.def(function lazy(name, fn) {
  if (typeof name == 'function') {
    fn = name;
    name = fn.name;
  }

  return this.getter(name, function() {
    return this.def(name, fn.call(this))[name];
  });
});

Chain.def('with', function(key, value) {
  var link = this.clone;

  if (typeof key === 'object') {
    for (var k in key) {
      if (key.hasOwnProperty(k))
        link[k] = key[k];
    }
  } else {
    link[key] = value
  }

  return link;
});

Chain.def(function tap(fn) {
  var link = this.clone;
  fn && fn.call(link, link);
  return this;
});

Chain.def(function promise(fn) {
  return this.clone.lazy('_promise', function() {
    return new Promise(fn.bind(this));
  });
});

Chain.def(function then(onResolved, onRejected) {
  if (!this._promise) throw new Error("Nothing has been promised!");

  return this.clone.def('_promise', this._promise.then(onResolved, onRejected));
});

Chain.def('done', Chain.then);

Chain.def('catch', function(onRejected) {
  return this.then(undefined, onRejected);
});

base.Chain = Chain;

})(this);
