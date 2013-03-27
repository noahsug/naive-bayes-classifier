PriorityQueue = require('./priority_queue.coffee').PriorityQueue
util = require('../coffee/util.coffee')

class NBC

  constructor: (@examples, @words) ->
    @nodes = []
    @examples1 = @examples.filter (e) -> e[e.length-1] is 0
    @examples2 = @examples.filter (e) -> e[e.length-1] is 1

  build: ->
    for i in [0..@examples[0].length-2]
      node = []
      node[0] = @probability @examples1, i
      node[1] = @probability @examples2, i
      if node[1] is 1 or node[0] is 1
        console.log i, node[1]
        console.log @examples2[0][i]
        console.log @examples2[1][i]
        console.log @examples2[2][i]
        console.log @examples2[3][i]
        console.log @examples2[4][i]
        console.log @examples2[5][i]
      @nodes.push node

  probability: (examples, feature) ->
    total = examples.reduce (total, current) ->
      total + current[feature]
    , 1
    return total / (1 + examples.length)

  getMostDiscriminativeWords: (words) ->
    pq = PriorityQueue()
    for n, word in @nodes
      label1Prob = util.log2 @probability @examples1, word
      label2Prob = util.log2 @probability @examples2, word
      value = Math.abs label1Prob - label2Prob
      pq.push 1 - value, words[word]
    for i in [1..10]
      pq.pop()

  predict: (input) ->
    prob1 = @probH input, 0
    prob2 = @probH input, 1
    if prob1 > prob2 then 0 else 1

  probH: (input, h) ->
    sum = 0
    for value, word in input
      if value is 1
        sum += Math.log @nodes[word][h]
      else
        sum += Math.log (1 - @nodes[word][h])
    sum

exports.NBC = NBC