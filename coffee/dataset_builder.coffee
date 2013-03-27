util = require('../coffee/util.coffee')

class DatasetBuilder

  constructor: (dataPath, labelPath) ->
    @dataPath = util.dataPath + dataPath
    @labelPath = util.dataPath + labelPath
    @numInput = 0
    @dataset = []

  build: (callback) ->
    util.readFile @dataPath, (inputData) =>
      @parseInput(inputData)
      util.readFile @labelPath, (outputData) =>
        @parseOutput(outputData)
        callback @dataset

  parseInput: (data) ->
    for line in data.split '\n'
      [docId, wordId] = line.split('\t')
      wordId = parseInt(wordId) - 1
      continue if isNaN wordId
      docId = parseInt(docId) - 1
      @dataset[docId] ?= []
      @dataset[docId][wordId] = 1
      @numInput = wordId + 1 if @numInput < wordId + 1

  parseOutput: (data) ->
    for line, docId in data.split '\n'
      label = parseInt(line) - 1
      continue if isNaN label
      @dataset[docId] ?= []
      @fillEmptyIndexesWithZero(@dataset[docId])
      @dataset[docId].push(label)

  fillEmptyIndexesWithZero: (arr) ->
    for i in [0..@numInput-1]
      arr[i] ?= 0

exports.DatasetBuilder = DatasetBuilder