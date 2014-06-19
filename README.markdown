
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

Ajax.def('url')

Ajax.flag('get', {method: 'get'});
Ajax.flag('json', {dataType: 'json'});

Ajax.def('invoke', function() {
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

Methods
-------

- `Chain.def()`
- `Chain.lazy()`
- `Chain.getter()`
- `Chain.flag()`
- `Chain.with()`
- `Chain.clone`
- `Chain.tap()`
- `Chain.promise()`
- `Chain.then()`
- `Chain.catch()`

Values defined with `Chain.def`, `Chain.getter`, or `Chain.flag` are not enumberable: `Object.keys(Chain).length == 0`.

`#getter( name, fn )`
---------------------

Getters are meant to be called without parenthesis:

```js
var Invoice = Chain.clone;

Invoice.getter('isDue', function() {
  return this.dueDate < new Date();
});

var invoice = Invoice.set({dueDate: new Date(2020)})

invoice.isDue === false;
```

`#flag( name, attributes )`
---------------------------

Flags are like getters, but instead of calling a function, they set attributes:

```js
var Order = Chain.clone;

Order.flag('shipped', {status: 'shipped'});
Order.flag('delivered', {status: 'delivered'});

var order1 = Order.shipped;
var order2 = order1.delivered;

order1.status === 'shipped';
order2.status === 'delivered';
```
