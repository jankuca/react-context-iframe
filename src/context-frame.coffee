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

    if not @_shouldUpdateContextProvider(@state?.ContextProvider, contextKeys)
      return @state.ContextProvider

    context = @_createContext(internalContext, contextKeys)
    contextTypes = @_createContextTypes(contextKeys)

    class ContextProvider extends AbstractContextProvider
      @childContextTypes: contextTypes
      getChildContext: -> context

    return ContextProvider

  _shouldUpdateContextProvider: (prevContextProvider, nextContextKeys) ->
    prevContextTypes = prevContextProvider?.childContextTypes
    if !prevContextTypes
      return true

    # NOTE: Object key comparison algorithm.
    # 1. Start with a copy of the object the keys of which are being compared.
    diff = {}
    Object.keys(prevContextTypes).forEach (key) ->
      diff[key] = prevContextTypes[key]

    addedContextKey = nextContextKeys.some (contextKey) ->
      # 2A. Remove untouched keys from the diff.
      if diff[contextKey]
        delete diff[contextKey]
        return false

      # 2B. Stop on a missing key.
      return true

    # 3. Whether a new key was added or at least one key was removed.
    return addedContextKey or (Object.keys(diff).length > 1)

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
