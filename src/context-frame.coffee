React = require 'react'

AbstractContextProvider = require './abstract-context-provider'
CssFrame = require 'react-css-iframe'


class ContextFrame extends React.Component
  constructor: ->
    super
    @state = @_createState(@props)

  componentWillReceiveProps: (nextProps) ->
    @setState(@_createState(nextProps))

  _createState: (props) ->
    frameProps: @_createFrameProps(props)
    ContextProvider: @_createContextProvider(props)

  _createFrameProps: (props) ->
    frameProps = {}
    Object.keys(props).forEach (key) ->
      frameProps[key] = props[key]

    delete frameProps.parent
    return frameProps

  _createContextProvider: (props) ->
    # HACK: Private React API. This might break with future versions of React.
    internalContext = props.parent._reactInternalInstance._context
    contextKeys = Object.keys(internalContext).filter (key) -> (key[0] != '_')
    contextKeys.sort()

    context = @_createContext(internalContext, contextKeys)
    if not @_shouldUpdateContextProvider(@state?.ContextProvider, context)
      return @state.ContextProvider

    contextTypes = @_createContextTypes(contextKeys)

    class ContextProvider extends AbstractContextProvider
      @childContextTypes: contextTypes
      getChildContext: -> context

    return ContextProvider

  _shouldUpdateContextProvider: (prevContextProvider, nextContext) ->
    prevContext = prevContextProvider?::getChildContext()
    if !prevContext
      return true

    nextContextKeys = Object.keys(nextContext)
    removedKey = Object.keys(prevContext).some (key) ->
      index = nextContextKeys.indexOf(key)
      if index != -1
        nextContextKeys.splice(index, -1)
        return (prevContext[key] != nextContext[key])

      return true

    return removedKey or nextContextKeys.length > 0

  _createContextTypes: (contextKeys) ->
    contextTypeReducer = (contextTypes, value) ->
      contextTypes[value] = React.PropTypes.any.isRequired
      return contextTypes

    contextTypes = contextKeys.reduce(contextTypeReducer, {})
    return contextTypes

  _createContext: (source, contextKeys) ->
    contextKeyReducer = (context, contextKey) ->
      context[contextKey] = source[contextKey]
      return context

    context = contextKeys.reduce(contextKeyReducer, {})
    return context

  render: ->
    React.createElement CssFrame, @state.frameProps,
      React.createElement @state.ContextProvider, null,
        @props.children


module.exports = ContextFrame
