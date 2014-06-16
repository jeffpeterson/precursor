chain.js
========

`chain.js` is designed to make chaining-based APIs easy.

Usage
=====

Here's an example:

```js
```

Methods
-------

- `Chain.set()`
- `Chain.def()`
- `Chain.getter()`
- `Chain.flag()`
- `Chain.clone`
- `Chain.tap()`
- `Chain.promise()`
- `Chain.resolve()`
- `Chain.reject()`
- `Chain.then()`
- `Chain.catch()`

Values defined with `Chain.def` are not enumberable: `Object.keys(Chain).length == 0`.

Getters
-------

Getters are meant to be called without parenthesis:

```js
var Invoice = Chain.clone;

Invoice.getter('isDue', function() {
  return this.dueDate < new Date();
});

var invoice = Invoice.set({dueDate: new Date(2020)})

invoice.isDue == false;
```

Flags
-----

```js
var car = chain.clone;

car.getter('car', { color: 'red' });
```

Attributes
----------
