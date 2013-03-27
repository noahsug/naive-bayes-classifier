util = require './util.coffee'
PriorityQueue = require('./priority_queue.coffee').PriorityQueue

##
# A simplified decision tree learner with exactly two output variables (0 or 1).
##
class DecisionTreeLearner

  constructor: (@examples, @maxNodes=100) ->
    @informationGainFunction = @weightedInformationGainFunction
    @pq = PriorityQueue()
    @numDecisionNodes = 0

  build: (onExpansionCallback) ->
    dt = @addNode(@examples).tree
    while not @shouldStop()
      leaf = @pq.pop()
      nodes = []
      for featureValue in [0..1]
        featureExamples = leaf.examples.filter (e) -> e[leaf.feature] is featureValue
        break if featureExamples.length is 0 or featureExamples.length is leaf.examples.length
        node = @addNode featureExamples
        nodes.push node.tree
      continue if nodes.length is 0
      leaf.tree.becomeInteriorNode leaf.feature, nodes
      @numDecisionNodes++
      onExpansionCallback?(dt, @numDecisionNodes)
    return dt

  addNode: (examples) ->
    [feature, value] = @findBestFeature examples
    tree = new DecisionTree @pointEstimate examples
    tree.gain = value
    node = {tree, examples, feature, value}
    if value > 0
      @pq.push (1-value), node
    node

  shouldStop: ->
    return @pq.size() is 0 or @numDecisionNodes >= @maxNodes

  pointEstimate: (examples) =>
    return 0 if examples.length is 0
    total = examples.reduce (total, current) =>
      total + current[current.length - 1]
    , 0
    total / examples.length

  findBestFeature: (examples) =>
    bestFeature = -1
    bestValue = -1
    for i in [0..examples[0].length-2]
      value = @informationGainFunction examples, i
      if value > bestValue
        bestValue = value
        bestFeature = i
    [bestFeature, bestValue]

  averageInformationGainFunction: (examples, i) =>
    [examplesSplit1, examplesSplit2] = @splitExamples examples, i
    split1Gain = @gain(examplesSplit1) * .5
    split2Gain = @gain(examplesSplit2) * .5
    @gain(examples) - (split1Gain + split2Gain)

  weightedInformationGainFunction: (examples, i) =>
    [examplesSplit1, examplesSplit2] = @splitExamples examples, i
    split1Gain = @gain(examplesSplit1) * examplesSplit1.length / examples.length
    split2Gain = @gain(examplesSplit2) * examplesSplit2.length / examples.length
    @gain(examples) - (split1Gain + split2Gain)

  splitExamples: (examples, i) =>
    split1 = []
    split2 = []
    for e in examples
      if e[i] is 1
        split1.push e
      else
        split2.push e
    [split1, split2]

  gain: (examples) =>
    probability = @pointEstimate(examples)
    return 0 if probability is 0 or probability is 1
    feature1Prob = -probability * util.log2(probability)
    feature2Prob = -(1-probability) * util.log2(1-probability)
    feature1Prob + feature2Prob

class DecisionTree
  constructor: (@value) ->
    @isLeaf = true

  becomeInteriorNode: (@feature, @children) ->
    @isLeaf = false

  predict: (input) ->
    return @value if @isLeaf
    return @children[input[@feature]].predict(input)

  toString: (words, depth=0) ->
    padding = ''
    if depth > 0
      padding = ('  ' for i in [0..depth-1]).join ''
    if @isLeaf
      padding + @value
    else
      feature = words[@feature] ? @feature
      msg = "#{padding}feature #{feature} - #{@gain}\n"
      for child, value in @children
        msg += '\n' if value isnt 0
        msg += "#{padding}value = #{value}\n"
        msg += child.toString(words, depth + 1)
      msg

exports.DecisionTreeLearner = DecisionTreeLearner
exports.DecisionTree = DecisionTree
