fs = require('fs')

exports.dataPath = './datasets/'

exports.logb = (num, base) ->
  Math.log(num) / Math.log(base)

exports.log2 = (num) ->
  exports.logb num, 2

exports.readFile = (path, callback) ->
  fs.readFile path, 'utf8', (err, data) ->
    if (err) then console.error 'error reading', path, err
    callback(data)
