provider = require './provider'

module.exports =

  config:

    bracket:
      title: 'Bracket insertion'
      description: 'Specify a way to insert brackets when a clause follows input.'
      type: 'integer'
      default: 0
      enum: [
        { value: 0, description: 'Select each time' }
        { value: 1, description: 'Single line only' }
        { value: 2, description: 'Multiple lines only' }
      ]

    includeloc:
      title: 'Include locations'
      description: 'Specify whether it uses location dictionaries or not.'
      type: 'integer'
      default: 0
      enum: [
        { value: 0, description: 'Include locations' }
        { value: 1, description: 'Include locations without clauses' }
        { value: 2, description: 'Not include locations' }
      ]

    includedesc:
      title: 'Include descriptions'
      description: 'Specify whether word matching includes descriptions or not.'
      type: 'boolean'
      default: true
      enum: [
        { value: true , description: 'Include descriptions' }
        { value: false, description: 'Not include descriptions' }
      ]

  activate: ->
  provider: -> provider
