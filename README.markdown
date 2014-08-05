
# chain.js [![Build Status](https://travis-ci.org/jeffpeterson/chain-js.svg?branch=master)](https://travis-ci.org/jeffpeterson/chain-js)

`chain.js` is designed to make chaining-based APIs easy.

Usage
=====

Here's an example:

```js
var Ajax = Chain.with({
  dataType: 'txts',
  method: 'post',
  url: '/'
});

Ajax.flag('get', {method: 'get'});
Ajax.flag('json', {dataType: 'json'});

Ajax.def(function invoke() {
  var request = new XMLHttpRequest();

  return this.with('request', request).promise(function(resolve, reject) {
    request.onreadystatuschange = function() {
      if (request.readyState != XMLHttpRequest.DONE) return;

      if (request.status === 200) {
        resolve(request.responseText);
      } else {
        reject(new Error(request.statusText));
      }
    };

    request.open(this.method, this.url, true);
    request.send(this.data);
  }).then(function(result) {
    switch (this.dataType) {
      case 'json': return JSON.parse(json);
    }
  });
});

var request = Ajax.get.json.with({url: '/albums/12345.json'});

request().then(function(album) {
  alert(album.name);
});

request.with({url: '/'})().then(function())
```

### Mutating Methods

- `Chain.def( fn )`
- `Chain.getter( fn )`
- `Chain.lazy( fn )`
- `Chain.flag( name, properties )`

### Cloning Methods

- `Chain.with()`
- `Chain.clone`
- `Chain.tap()`
- `Chain.promise()`
- `Chain.then()`
- `Chain.catch()`

## `#def( namedFunction )`

`def` is used to assign non-enumerable functions.
Values can be assigned with `#def( name, value )`.

## `#getter( namedFunction )`

Similar to `def` except getters are called without parenthesis:

```js
var Invoice = Chain.clone;

Invoice.getter(function isDue() {
  return this.dueDate < new Date();
});

var invoice = Invoice.set({dueDate: new Date(2020)})

invoice.isDue === false;
```

## `#lazy( namedFunction )`

`lazy` is just like `getter`, but it re-assigns itself
as the return value of the passed function.

## `#with( attributes )`
Create a clone with the passed attributes appended:

```js
var person = Chain.with({
  first_name: "John",
  last_name: "Doe"
});
```

## `#flag( name, attributes )`

`flag` is a shortcut for creating a getter that returns a clone with attributes appended:

```js
var Order = Chain.clone;

Order.flag('asShipped', {status: 'shipped'});
Order.flag('asDelivered', {status: 'delivered'});

var order1 = Order.asShipped;
var order2 = order1.asDelivered;

order1.status === 'shipped';
order2.status === 'delivered';
```

## `#clone`
## `#tap( fn )`

`tap` creates a clone, applies `fn` to it, and then returns it.
The clone is also passed as the first argument.

```js
Chain.tap(function(clone) {
  this === clone;
});
```

## `#promise( fn )`

`chain.js` promises require an ES6-compatible `window.Promise` object.
Alternatively, you can set your own: `Chain.def('Promise', RSVP.Promise)`.
`chain.js` promises are lazy: `fn` isn't invoked until `#then()`
has been called on the chain.

## `#then( onResolved, onRejected )`
## `#catch( onRejected )`
