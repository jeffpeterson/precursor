chain.js
========

`chain.js` is designed to make chaining-based APIs easy.

Usage
=====

Here's an example:

```js
var Ajax = Chain.with({
  dataType: 'txts',
  method: 'post'
});

Ajax.flag('get', {method: 'get'});
Ajax.flag('json', {dataType: 'json'});

Ajax.getter('go', function() {
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

var lazyRequest = Ajax.get.json.with({url: '/albums/12345.json'});
var request = lazyRequest.go;

request.then(function(person) {
  alert(person.name)
});
```

Methods
-------

- `Chain.with()`
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
