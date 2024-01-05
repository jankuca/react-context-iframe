# React Context iFrame

Creates a *CSS frame component* ([react-css-iframe](https://github.com/jankuca/react-css-iframe)) which preserves the whole React context of its parent.

```javascript
import ContextFrame from 'react-context-iframe'

class MyComponent extends React.Component {
  render() {
    return (
      <ContextFrame parent={this} src={...} [width={...}] [height={...}]>
        <MyChildComponent />
      </ContextFrame>
    )
  }
}
```

Notice the `parent={this}` prop. This is the component from which to clone the context.

The parent component does **not** need to specify a context type declaration (neither `contextTypes` or `childContextTypes`) for this to work. The whole unmasked context object is considered automatically. The child (`MyChildComponent` in the example) can take whatever it needs from the context as if there was no intermediary component in the tree.

Props other than `parent` are passed to the *react-css-frame* component.

## Licence

MIT
