# Visual Design

* [Adapt scrollbar to high-contrast preferences](adapt-scrollbar-to-contrast-preferences.md) - Users who enable high-contrast modes in their operating system or browser expect UI elements (like scrollbars) to be extremely legible, often relying on stark foreground-background separation rather than subtle grays or theme colors.

* [Apply WebGL shaders to HTML content](apply-webgl-shaders.md) - WebGL shaders provide powerful GPU-accelerated visual effects, enabling advanced capabilities like dynamic ripple distortions, lighting models, color grading, and custom vertex transformations.

* [Theming browser-generated UI](browser-ui-theming.md) - Most browser-generated UI can be customized to some extent using CSS. Even if it requires modern features, it degrades gracefully in older browsers, and thus often does not require a polyfill or fallback.

* [Color](color.md) - Don't use color alone to indicate the presence of a user interface component or its state: Use iconography and/or shape to help differentiate. Do not denote success/errors ONLY with color. Use icons or text (WCAG 1.4.1 Use of Color).

* [Complex Shapes](complex-shapes.md) - To clip elements to complex, free-form shapes like brush strokes or organic textures, use CSS Masking (mask-image).

* [Ensure text readability with dynamic background colors](contrast-color.md) - When building reusable UI components (like badges, buttons, headers, or footers) or supporting customizable themes, ensuring text remains readable against a variable background color can be challenging.

* [Custom text decorations](custom-text-decorations.md) - Use the native text-decoration properties to style underlines, overlines, and strikethroughs, instead of faking them with borders, background gradients, or pseudo-elements.

* [Customize the color or thickness of a scrollbar](customize-scrollbar-color-and-thickness.md) - You can customize the appearance of scrollbars using the standard CSS properties scrollbar-color and scrollbar-width.

* [Dark mode](dark-mode.md) - The color-scheme property indicates which color schemes (such as light or dark) your page supports.

* [Equal-Width Text Lines](equal-width-text-lines.md) - Poster-style lockups where each line is scaled so it spans the container's full width can create visually striking headings. Using text-fit, the browser scales each line during layout, so it stays correct on resize, copy changes, and font load.

* [Export HTML content from canvas](export-html-media-from-canvas.md) - Web applications frequently need to capture and export rich HTML content—such as customized dashboards, styled documents, or interactive charts—as static images or video recordings.

* [Expose canvas content to browser features](expose-canvas-content-to-browser-features.md) - Regular <canvas> content is not exposed to browser features such as screen readers, indexing, translation tools, accessibility assistive tools, find-in-page, print, etc.

* [Improve Text Layout and Legibility](improve-text-layout-and-legibility.md) - The layout of text, particularly at the ends of lines and ends of paragraphs, can impact the legibility and aesthetic appeal of a page. CSS provides several text wrapping options that can improve specific use cases.

* [Enable interactive HTML content in 3D scenes](interactive-content-in-3d-scenes.md) - The HTML-in-Canvas API allows rendering real DOM directly inside a canvas element.

* [Precise Text Alignment](precise-text-alignment.md) - Browsers automatically add extra whitespace above and below text characters to accommodate line-height and font-specific metrics like ascenders and descenders.

* [Shaped Cutouts](shaped-cutouts.md) - CSS Masking allows you to clip an element to a custom shape, such as adding a notch to a card or creating a shaped border. When combining shapes for complex layouts, choose your masking strategy based on the type of content the element contains.

* [Soft Edge Content Fade](soft-edge-content-fade.md) - To apply a transparency gradient to the edges of a container (e.g., to indicate more content is available to scroll or to fade out text), use CSS Masking with a linear gradient.

* [Typography](typography.md) - Use unitless line-height, rem-based font-size, and an 80-character measure; never fix text container heights so WCAG text-spacing and 200% zoom keep working.

* [Visual effects](visual-effects.md) - Use in oklch or in oklab to explicitly specify the interpolation color space for gradients or color-mix().

* [Visually Stable Font Fallbacks](visually-stable-font-fallbacks.md) - When web fonts load, they often replace a fallback font that has different dimensions, even if both are set to the same font-size.

* [Visually Stable Mixed Fonts](visually-stable-mixed-fonts.md) - When mixing different font families, for instance when inserting inline code snippets, or switching out font families for different themes, differences in "x-height" (the height of lowercase letters) can make one font appear much smaller or larger than the other font.

* [Visually Texture Content](visually-texture-content.md) - To apply realistic weathering or texture patterns (like grunge, noise, or paper texture) to an element, use CSS Masking (mask-image) with a repeating texture image.

<!-- vim: set ft=markdown -->
