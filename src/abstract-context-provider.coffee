React = require 'react'


class AbstractContextProvider extends React.Component
  @childContextTypes: {}

  getChildContext: -> {}

  render: ->
    React.DOM.div className: 'context-provider',
      @props.children


module.exports = AbstractContextProvider
