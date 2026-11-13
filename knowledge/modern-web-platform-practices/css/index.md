# CSS

* [Animate to Intrinsic Sizes](animate-to-intrinsic-sizes.md) - Animating elements to dynamic sizes like block-size: auto or inline-size: max-content has historically required JavaScript or fragile "max-height" hacks.

* [Conditionally Apply CSS Based on At-Rule Support](atrule-support-conditionals.md) - Use @supports at-rule(@<at-rule name>) {…} to conditionally apply certain CSS rules or declarations only if a certain at-rule is supported by the browser.

* [Calculate With Intrinsic Sizes](calculate-with-intrinsic-sizes.md) - calc-size() is a CSS function for performing mathematical operations on intrinsic sizing keywords like auto, min-content, and fit-content.

* [Child State Based Styling](child-state-based-styling.md) - Historically, CSS selectors could only traverse downwards—you could style a child based on its parent, but not a parent based on its child.

* [Content Based Styling](content-based-styling.md) - Historically, applying different layouts to a component based on its content required either JavaScript or conditional logic in your HTML templating language to inject modifier classes (like .card--has-image or .card--text-only).

* [CSS Layouts and Responsive Design](css-layout.md) - Lean on the browser's layout engine when possible for better performance. Reach for intrinsic sizing, logical properties, and aspect-ratio before resorting to hardcoded dimensions or complicated media-queries.

* [CSS: Modern Architecture](css.md) - These guidelines provide a high-density reference for writing maintainable and standard-compliant CSS.

* [Design Token Reactivity](design-token-reactivity.md) - Often an author will need to make contextual changes to the design of a component.

* [Styling siblings based on count and index](dynamic-sibling-styling.md) - Historically, applying unique styles to each sibling in a list required complex :nth-child loops or JavaScript to inject inline styles.

* [Fluid Scaling](fluid-scaling.md) - Fluid scaling allows components to adjust their internal proportions (like font sizes and spacing) based on their current dimensions. This creates a more cohesive design than jumping between fixed breakpoints.

* [Individual Transform Properties](individual-transform-properties.md) - The transform property allows you to apply multiple transformations in a specified order, but any changes to a single transformation require re-specifying the entire transformation chain. This makes it tricky to animate or transition a single transformation.

* [Overflow Clipping Control](overflow-clipping-control.md) - While overflow: hidden is a "blunt instrument" that almost always clips content strictly at the padding-box, overflow: clip combined with overflow-clip-margin provides the "scalpel" for fine-grained layout control across block containers.

* [Reduce Style Repetition with CSS Functions](reduce-style-repetition.md) - Maintaining large stylesheets often leads to repetitive logic, especially when dealing with design system tokens like gradients or responsive layout patterns.

* [Responsive design](responsive-design.md) - For the layout mechanics behind responsive UI (flexbox, grid, container query units, viewport units), see css-layout.

* [Selector & @-rule Combinations](selector-atrule-combinations.md) - We often need to combine filtering criteria of different types, e.g. selectors + media queries, media queries + container queries, and so on.

* [Size Aware Styling](size-aware-styling.md) - Size-aware styling allows components to change their layout or appearance based on the space available to them, rather than the size of the whole screen.

* [Style a Form Group When a Field Is Invalid with :has()](style-parent-with-has.md) - Often, an error state requires styling elements outside the input itself—for example, changing the color of a parent fieldset border, highlighting the <label>, or showing a global error icon in the card header.

* [Semantic Component Adaptation](usage-aware-component-variations.md) - Use style queries (@container style()) to trigger contextual variations without hardcoding what produces or reacts to each context. This reduces design system coupling and improves extensibility and component encapsulation.

<!-- vim: set ft=markdown -->
