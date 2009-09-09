/*global $$,$,$w,Ajax,Effect,Element,Prototype,BILEXICON */
/*jslint browser: true, white: true, undef: true, plusplus: true, bitwise: true, newcap: true */

/* ------------------------------------------------------------------------
 * default value as hint
 * ------------------------------------------------------------------------ */
(function () {
  var methods = {
    defaultValueActsAsHint: function (element) {
      element = $(element);
      element._default = element.value;

      return element.observe('focus', function () {
        if (element._default != element.value) {
          return;
        }
        element.removeClassName('hint').value = '';
      }).observe('blur', function () {
        if (element.value.strip() !== '') {
          return;
        }
        element.addClassName('hint').value = element._default;
      }).addClassName('hint');
    }
  };

  $w('input textarea').each(function (tag) {
    Element.addMethods(tag, methods);
  });
})();

/* ------------------------------------------------------------------------
 * visibility methods
 * ------------------------------------------------------------------------ */
(function () {
  Element.addMethods({
    setVisibility: function (element) {
      element.setStyle({ visibility: "visible"});
    },
    removeVisibility: function (element) {
      element.setStyle({ visibility: "hidden"});
    }
  });
})();

/* ------------------------------------------------------------------------
 * Special FX
 * ------------------------------------------------------------------------ */
Effect.SelfHealingFade = function (element) {
  element = $(element);
  return new Effect.Parallel(
    [
      new Effect.Fade(element,  { sync: true }),
      new Effect.BlindUp(element, { sync: true })
    ],
    arguments[1] || { duration: 0.1 }
  );
};

Effect.SelfHealingAppear = function (element) {
  element = $(element);
  return new Effect.Parallel(
    [
      new Effect.Appear(element,  { sync: true }),
      new Effect.BlindDown(element, { sync: true })
    ],
    arguments[1] || { duration: 0.25 }
  );
};