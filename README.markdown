
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

## `#def( namedFunction )` or `#def( name, value )`

`def` is used to assign non-enumerable values or functions.

## `#getter( namedFunction )` or `#getter( name, fn )`

Getters are meant to be called without parenthesis:

```js
var Invoice = Chain.clone;

Invoice.getter(function isDue() {
  return this.dueDate < new Date();
});

var invoice = Invoice.set({dueDate: new Date(2020)})

invoice.isDue === false;
```

## `#lazy( name, fn )`

`lazy` is just like `getter`, but when it's first accessed, it evaluates
to the return value of the passed function.

## `#flag( name, attributes )`

`flag` is a shortcut for cloning with attributes in getters:

```js
var Order = Chain.clone;

Order.flag('shipped', {status: 'shipped'});
Order.flag('delivered', {status: 'delivered'});

var order1 = Order.shipped;
var order2 = order1.delivered;

order1.status === 'shipped';
order2.status === 'delivered';
```

## `#with( attributes)`
## `#clone`
## `#tap( fn )`
## `#promise( fn )`
## `#then( onResolved, onRejected )`
## `#catch( onRejected )`
