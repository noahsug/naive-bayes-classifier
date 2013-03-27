NBC = require('../coffee/nbc.coffee').NBC
Valuator = require('../coffee/valuator.coffee').Valuator
DatasetBuilder = require('../coffee/dataset_builder.coffee').DatasetBuilder
util = require('../coffee/util.coffee')

run = ->
  console.log 'RESULTS:'
  printResults()
  console.log '\nTOP TEN WORDS:'
  printTree()

##
# Train the classifier, then evaluate it using the test data.
##
printTree = ->
  new DatasetBuilder('trainData.txt', 'trainLabel.txt').build (trainingDS) ->
    parseWords util.dataPath + 'words.txt', (words) ->
      nbc = new NBC(trainingDS, words)
      nbc.build()
      console.log nbc.getMostDiscriminativeWords words

  parseWords = (path, callback) ->
    util.readFile path, (words) ->
      callback words.split '\n'

##
# Print the top ten most important words.
##
printResults = ->
  new DatasetBuilder('trainData.txt', 'trainLabel.txt').build (trainingDS) ->
    new DatasetBuilder('testData.txt', 'testLabel.txt').build (testingDS) ->
      fillWithZeros trainingDS, testingDS[0].length
      nbc = new NBC(trainingDS)
      nbc.build()
      evalNetwork nbc, trainingDS, testingDS

  fillWithZeros = (arrList, len) ->
    for arr in arrList
      t = arr.pop()
      for i in [arr.length..len-2]
        arr[i] = 0
      arr.push t
    console.log arr.length, len

  evalNetwork = (net, trainingDS, testingDS) ->
    valuatorTesting = new Valuator testingDS
    valuatorTraining = new Valuator trainingDS

    testingAccuracy = 1 - valuatorTesting.totalError(net) / testingDS.length
    trainingAccuracy = 1 - valuatorTraining.totalError(net) / trainingDS.length

    console.log 'testing', testingAccuracy
    console.log 'training', trainingAccuracy

run()