# UI Behaviors

* [Two-Dimensional Panning](2d-panning.md) - When a user scrolls a two-dimensional scroll container, browsers typically apply a scroll axis-locking heuristic (also known as "railing").

* [Anchor Positioning Tab Underline](anchor-positioning-tab-underline.md) - In a tab menu, provide a visual indicator showing users which tab is active by underlining the active tab item.

* [Animate Element Entry and Exit](animate-element-entry-exit.md) - In the past, CSS transitions could not animate elements when they were first added to the DOM or when their display property changed from none.

* [Animate Elements To and From Top Layer](animate-to-from-top-layer.md) - Elements that render in the "top layer" (like <dialog>, elements with the popover attribute, or tooltips) have historically been difficult to animate because they toggle between display: none and a visible state.

* [Carousel Snap Highlights](carousel-snap-highlights.md) - Scroll-state container queries allow you to style elements based on their current scroll state, such as whether an element is "stuck" through sticky positioning or "snapped" through scroll snapping.

* [Consistent Cross-Document Transitions](consistent-cross-document-transitions.md) - Cross-document view transitions animate elements between two pages during a same-origin navigation.

* [Cross-Document Transitions](cross-document-transitions.md) - Cross-document view transitions allow you to create smooth, app-like transitions between different pages of a Multi-Page Application (MPA). By default, the browser performs a cross-fade, but you can customize this to match your site's aesthetic.

* [Custom Button Actions](custom-button-actions.md) - The Invoker Commands API allows buttons to trigger actions on target elements declaratively using HTML attributes.

* [Declarative Dialog and Popover Control](declarative-dialog-popover-control.md) - Use the Invoker Commands API to toggle the visibility of <dialog> and [popover] elements directly from HTML buttons, eliminating the need for custom JavaScript event listeners.

* [Directional Navigation Transitions](directional-navigation-transitions.md) - Single Page Applications (SPAs) provide the appearance of navigation by replacing the content of the page without navigating to a new page.

* [Rearrange Items with Drag and Drop](drag-and-drop.md) - Add reordering to an existing list or row, vertical or horizontal.

* [Build a Draggable Element](drag.md) - Add dragging to an existing floating element such as a panel, palette, toolbar, inspector, or dialog. Dragging does not determine how the element is displayed, dismissed, stacked, or focused.

* [Creating a stagger animation](dynamic-sibling-animations.md) - Stagger animations provide an interesting effect where multiple ordered elements animate sequentially with a slight delay between each, rather than all animating at once.

* [Handling dynamic user-triggered changes to sort order](dynamic-sort.md) - Use this pattern when a user action reorders a list, card grid or table, with no item mid-interaction. It covers only applying the new order to the DOM (moving nodes, animating, announcing, performance), not how the order is computed or what triggers it.

* [Smoothly rearrange cards, lists, and groups of elements on add, remove, or reorder](group-element-transitions.md) - As items are added or removed from a list, or rearranged, transitions can help users maintain context.

* [Highlight Text Ranges](highlight-text-ranges.md) - The CSS Custom Highlight API lets you style arbitrary text ranges on a page without modifying the DOM structure.

* [Interactive Content Reveal](interactive-content-reveal.md) - Add performant, interactive reveal effects to your site with CSS masks and registered custom properties.

* [Interest Triggered Action Previews](interest-triggered-action-previews.md) - It can be beneficial to provide users a preview of their actions before they commit to them.

* [Show a tooltip when hovering](interest-triggered-tooltips.md) - Users expect to see additional related information without completely changing their context.

* [Light-Dismiss a Dialog](light-dismiss-a-dialog.md) - Modern modal dialogs often support "light-dismiss," allowing users to close a dialog by clicking or tapping the backdrop (the area outside the dialog). The closedby attribute provides a declarative way to enable this behavior without custom JavaScript.

* [Motion](motion.md) - Always respect reduced motion preferences. Choose between @media (prefers-reduced-motion: no-preference) and @media (prefers-reduced-motion: reduce) based on whether reduced motion removes the animation entirely or only adjusts its parameters.

* [Move DOM Element Without Losing State](move-dom-element-without-losing-state.md) - When reparenting DOM elements using traditional methods like appendChild() or insertBefore(), the browser implicitly removes the element from the DOM and then inserts it into its new location.

* [Build a Parallax Effect on Scroll](parallax-scroll-effects.md) - A parallax effect on scroll is a visual technique where different layers of content move at varying speeds as the user scrolls down a page.

* [Persistent Top Layer UI](persistent-top-layer-ui.md) - When moving an open <dialog>, popover, or fullscreen element in the DOM using traditional methods like appendChild() or insertBefore(), the browser implicitly removes the element from the DOM and re-inserts it.

* [Physics Based Easing](physics-based-easing.md) - Traditional CSS easing functions like ease-in or cubic-bezier() are limited to simple curves, making it impossible to create complex physics-based effects like bounces or springs.

* [Platform Controls Dismiss Dialog](platform-controls-dismiss-dialog.md) - When a modal dialog is open, users expect to use familiar controls to dismiss them: pressing the <kbd>Esc</kbd> key on a keyboard, using the back button or gesture on mobile platforms, or a dismiss gesture with assistive technologies.

* [Prevent the Page Underneath a Modal Dialog from Scrolling](prevent-page-scroll-under-modal-dialog.md) - When a <dialog> element is opened as a modal using showModal(), the browser promotes it to the top layer and marks the rest of the document inert. While that blocks pointer clicks and keyboard focus on the underlying page, it does not prevent scrolling.

* [Same Document Transitions](same-document-transitions.md) - Web sites often provide multiple views of an object, for instance a list of products, and then a detail page for each product.

* [Scoped Component Transitions](scoped-component-transitions.md) - Starting a view transition with document.startViewTransition() attaches the ::view-transition overlay to the :root element, which blocks pointer events on the rest of the page, prevents concurrent transitions, and obscures position.

* [Triggering Effects After Programmatic Scrolling Completes](scroll-completion-effects.md) - Element and Window scroll methods return a Promise that resolves when scrolling completes — await it instead of setTimeout or scrollend listeners before triggering post-scroll effects.

* [Add entry and exit effects to elements as they enter or exit the scrollport](scroll-entry-exit-effects.md) - Entry and exit effects are animations that are triggered when an element enters or leaves the viewport.

* [Scroll Snap Real-Time Feedback](scroll-snap-realtime-feedback.md) - Users expect immediate visual feedback when interacting with UI elements like carousels or galleries.

* [Scroll Snap State Sync](scroll-snap-state-sync.md) - Synchronizing UI state with a scrollable container's snap position traditionally required complex scroll event listeners, manual calculations of scroll offsets, and intersection observers.

* [Set a scroll target for the initial render](scroll-target-on-load.md) - The CSS property scroll-initial-target offers a declarative, CSS-only way to bring a specific descendant element into the visible area of its scroll container as soon as that container is rendered.

* [Scrollytelling](scrollytelling.md) - Scrollytelling is a popular technique used to create engaging and immersive web experiences.

* [Search hidden content](search-hidden-content.md) - Web interfaces often hide content from view to improve the user experience, save screen space, or increase page performance.

* [Sortable Table](sortable-table.md) - Use this pattern to let users sort a data table by clicking its column headers. Start from a complete, semantic <table> that is readable without JavaScript, then enhance it.

* [Spatial Navigation (Directional Keypad Focus)](spatial-navigation.md) - Directional focus navigation (using arrow keys or D-Pads) enables keyboard-only and alternative-input users to navigate interactive items based on their visual 2D layout.

* [Swipe to remove](swipe-to-remove.md) - Swipe-to-remove patterns are common in mobile applications but can be challenging to implement cleanly on the web.

* [Swipe to reveal](swipe-to-reveal.md) - Swipe-to-reveal patterns let users slide a foreground row or content pane horizontally to expose hidden UI—such as contextual action buttons (Pin, Mute, Archive, Delete) or a secondary side menu—without automatically activating any action.

<!-- vim: set ft=markdown -->
