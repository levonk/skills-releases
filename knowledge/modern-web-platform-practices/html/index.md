# HTML

* [Accessible Web Components](accessible-web-components.md) - A shadow boundary changes how semantics and ARIA work. Two failures dominate: missing semantics inside the shadow tree, and ARIA references that silently break because they cannot cross shadow roots.

* [Custom Elements](custom-elements.md) - A custom element is a class registered against a tag name via customElements.define(). Registration and basic lifecycle are well understood; the rules below target the parts routinely implemented incorrectly.

* [Form-Associated Custom Elements](form-associated-custom-elements.md) - Do not fall back to a hidden <input> to surface a custom control's value to a form.

* [HTML](html.md) - Semantic HTML discipline guide — validation, content grouping, resource prioritization, native overlays (dialog, popover), details/summary disclosures, focus visibility, media elements, and form grouping.

* [Pre-rendering custom elements](prerendering-custom-elements.md) - Pre-rendering means shipping a custom element's markup — including its shadow tree — from the server, so the component is styled and structured before any JavaScript runs.

* [Shadow DOM, Templates & Slots](shadow-dom.md) - A shadow root is an encapsulated DOM subtree attached to a host element: styles inside it do not leak out, and page styles do not leak in (except inherited properties). Templates construct the tree efficiently; slots project Light DOM content into it.

* [Styling Web Components](styling-web-components.md) - Shadow DOM is a style boundary: page rules don't reach in and component rules don't leak out, except inherited properties (including custom properties). Cross it deliberately through the channels below.

* [Web Components Orientation](web-components.md) - Web Components are Custom Elements, Shadow DOM, and HTML Templates: the platform primitives for reusable, framework-agnostic components whose markup and styles are encapsulated from the document.

<!-- vim: set ft=markdown -->
