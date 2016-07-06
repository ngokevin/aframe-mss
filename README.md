# aframe-mss

Mixin Style Sheets: CSS for A-Frame.

<img alt="logo" src="mss.png" width="320">

## Usage

Declaratively declare mixins and components in a stylesheet form:

```css
/* example.mss */

wideBox {
  geometry {
    primitive: box;
    width: 5;
  }
  position: 5 5 2;
}

red {
  material {
    color: #FF2222;
  }
}
```

Then import and use from A-Frame:

```html
<a-scene>
  <a-assets>
    <a-style src="example.mss"></a-style>
  </a-assets>

  <a-entity mixin="red wideBox"></a-entity>
</a-scene>
```
