/* global AFRAME, THREE */
var parse = require('./parser/main').parse

var ANode = AFRAME.ANode;
var styleStringify = AFRAME.utils.styleParser.stringify;

var xhrLoader = new THREE.XHRLoader();

var AStyle = document.registerElement('a-style', {
  prototype: Object.create(ANode.prototype, {
    createdCallback: {
      value: function () {
        // Will make <a-asset-item> wait for load.
        this.isAssetItem = true;
      }
    },

    attachedCallback: {
      value: function () {
        var self = this;
        var src = this.getAttribute('src');

        xhrLoader.load(src, function (textResponse) {
          self.injectMixins(textResponse);
        });
      }
    },

    /**
     * Parse data and inject <a-mixin>s as children of <a-style>.
     */
    injectMixins: {
      value: function (mssContent) {
        var self = this;

        // Parse.
        var mixins = parse(mssContent).mixins;

        // Loop over mixins.
        Object.keys(mixins).forEach(function (id) {
          var mixinEl = document.createElement('a-mixin');
          mixinEl.setAttribute('id', id);

          // Loop over components.
          Object.keys(mixins[id]).forEach(function (componentName) {
            var props = mixins[id][componentName];
            var value = props.constructor === Object ? styleStringify(props) : props;
            mixinEl.setAttribute(componentName, value);
          });

          self.appendChild(mixinEl);
        });

        ANode.prototype.load.call(self);
      }
    }
  })
});

module.exports = {
  AStyle: AStyle,
  parse: parse
};
