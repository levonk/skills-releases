---
okf_version: "0.2"
---

# Modern Web Platform Practices

A compounding knowledge base of modern web platform practices ingested from GoogleChrome/modern-web-guidance — expert-curated, token-efficient guides that steer coding agents away from legacy patterns toward native, high-performance web platform solutions, plus Chrome extension and Web Store publishing references. Stewarded upstream by the Google Chrome, Microsoft Edge, Mozilla Firefox, and MDN teams.

## Concepts

* [Overview](overview.md) - Synthesis of the bundle, reading map, and upstream freshness pointer

### Accessibility

* [Accessibility index](accessibility/index.md) - 4 concepts
* [Accessibility Coding Guidelines](accessibility/accessibility.md) - This guide provides actionable DOs and DON'Ts for AI coding agents to ensure web applications are accessible to all users, including those using assistive technologies.
* [Accessible Error Announcement](accessibility/accessible-error-announcement.md) - Standard HTML5 validation provides visual feedback through :invalid or :user-invalid, but it doesn't automatically synchronize with accessibility attributes like aria-invalid.
* [Accessible generated content](accessibility/accessible-generated-content.md) - CSS-generated content needs the content property's alt-text argument for screen readers only when the text differs from the primary value and is absent from the DOM; keep meaningful text in the DOM (WCAG F87).
* [Respect Operating System Text Scale](accessibility/respect-os-text-scale.md) - Users with visual impairments often configure text scaling at the operating system level (such as Dynamic Type on iOS or Font Size scaling on Android/ChromeOS).

### Built-in AI

* [Built-in AI index](built-in-ai/index.md) - 5 concepts
* [Language Detection](built-in-ai/language-detection.md) - The Language Detector API is a client-side web API designed to identify the language of a given text string. By performing detection locally in the browser, it enhances user privacy and reduces the need for heavy external libraries or costly server-side calls.
* [Language Model](built-in-ai/language-model.md) - The Prompt API allows developers to run natural language processing tasks directly in the browser using Gemini Nano. This built-in AI approach ensures user privacy, reduces server costs, and enables offline functionality.
* [Language Model](built-in-ai/prompt-api.md) - The Prompt API allows developers to run natural language processing tasks directly in the browser using Gemini Nano. This built-in AI approach ensures user privacy, reduces server costs, and enables offline functionality.
* [Summarizer](built-in-ai/summarizer.md) - The Summarizer API allows web developers to offer local, AI-powered text distillation directly within the browser using Gemini Nano in Chrome or Phi in Edge.
* [Translator](built-in-ai/translator.md) - The Translator API allows developers to perform client-side text translation using built-in AI models in Chrome and Edge.

### CSS

* [CSS index](css/index.md) - 18 concepts
* [Animate to Intrinsic Sizes](css/animate-to-intrinsic-sizes.md) - Animating elements to dynamic sizes like block-size: auto or inline-size: max-content has historically required JavaScript or fragile "max-height" hacks.
* [Conditionally Apply CSS Based on At-Rule Support](css/atrule-support-conditionals.md) - Use @supports at-rule(@<at-rule name>) {…} to conditionally apply certain CSS rules or declarations only if a certain at-rule is supported by the browser.
* [Calculate With Intrinsic Sizes](css/calculate-with-intrinsic-sizes.md) - calc-size() is a CSS function for performing mathematical operations on intrinsic sizing keywords like auto, min-content, and fit-content.
* [Child State Based Styling](css/child-state-based-styling.md) - Historically, CSS selectors could only traverse downwards—you could style a child based on its parent, but not a parent based on its child.
* [Content Based Styling](css/content-based-styling.md) - Historically, applying different layouts to a component based on its content required either JavaScript or conditional logic in your HTML templating language to inject modifier classes (like .card--has-image or .card--text-only).
* [CSS Layouts and Responsive Design](css/css-layout.md) - Lean on the browser's layout engine when possible for better performance. Reach for intrinsic sizing, logical properties, and aspect-ratio before resorting to hardcoded dimensions or complicated media-queries.
* [CSS: Modern Architecture](css/css.md) - These guidelines provide a high-density reference for writing maintainable and standard-compliant CSS.
* [Design Token Reactivity](css/design-token-reactivity.md) - Often an author will need to make contextual changes to the design of a component.
* [Styling siblings based on count and index](css/dynamic-sibling-styling.md) - Historically, applying unique styles to each sibling in a list required complex :nth-child loops or JavaScript to inject inline styles.
* [Fluid Scaling](css/fluid-scaling.md) - Fluid scaling allows components to adjust their internal proportions (like font sizes and spacing) based on their current dimensions. This creates a more cohesive design than jumping between fixed breakpoints.
* [Individual Transform Properties](css/individual-transform-properties.md) - The transform property allows you to apply multiple transformations in a specified order, but any changes to a single transformation require re-specifying the entire transformation chain. This makes it tricky to animate or transition a single transformation.
* [Overflow Clipping Control](css/overflow-clipping-control.md) - While overflow: hidden is a "blunt instrument" that almost always clips content strictly at the padding-box, overflow: clip combined with overflow-clip-margin provides the "scalpel" for fine-grained layout control across block containers.
* [Reduce Style Repetition with CSS Functions](css/reduce-style-repetition.md) - Maintaining large stylesheets often leads to repetitive logic, especially when dealing with design system tokens like gradients or responsive layout patterns.
* [Responsive design](css/responsive-design.md) - For the layout mechanics behind responsive UI (flexbox, grid, container query units, viewport units), see css-layout.
* [Selector & @-rule Combinations](css/selector-atrule-combinations.md) - We often need to combine filtering criteria of different types, e.g. selectors + media queries, media queries + container queries, and so on.
* [Size Aware Styling](css/size-aware-styling.md) - Size-aware styling allows components to change their layout or appearance based on the space available to them, rather than the size of the whole screen.
* [Style a Form Group When a Field Is Invalid with :has()](css/style-parent-with-has.md) - Often, an error state requires styling elements outside the input itself—for example, changing the color of a parent fieldset border, highlighting the <label>, or showing a global error icon in the card header.
* [Semantic Component Adaptation](css/usage-aware-component-variations.md) - Use style queries (@container style()) to trigger contextual variations without hardcoding what produces or reacts to each context. This reduces design system coupling and improves extensibility and component encapsulation.

### Forms

* [Forms index](forms/index.md) - 19 concepts
* [Animated Select Picker](forms/animated-select-picker.md) - The customizable select API offers a declarative, CSS-driven way to animate <select> elements and their dropdown pickers.
* [Build an address form that follows best practice](forms/autofill-address-form.md) - Create a form that makes it as easy as possible for users to enter address data on desktop and mobile. Ensure the form makes the most of built-in browser features for autofill, validation and data entry constraints.
* [Customize the styling of autofilled form fields](forms/autofill-highlight-inputs.md) - Use the CSS :autofill pseudo-class to replace the browser's default highlight for autofilled <input>, <select>, and <textarea> elements.
* [Build a payment form that follows best practice](forms/autofill-payment-form.md) - Payment forms are the single most critical part of the checkout process. Poor payment form design is a common cause of shopping cart abandonment.
* [Build a sign-in form that follows best practice](forms/autofill-sign-in-form.md) - Use cross-platform browser features to build sign-in forms that are secure, accessible and easy to use.
* [Build a sign-up form that follows best practice](forms/autofill-sign-up-form.md) - Use cross-platform browser features to build sign-up forms that are secure, accessible and easy to use.
* [Brand-Consistent Forms](forms/brand-consistent-forms.md) - Customizing standard HTML form elements like checkboxes and radio buttons has historically been difficult.
* [Branded Select Styling](forms/branded-select-styling.md) - The customizable select API offers a declarative, CSS-driven way to style <select> elements to perfectly match your brand's design system.
* [Custom Select Picker Layouts](forms/custom-select-picker-layouts.md) - The CSS property appearance: base-select unlocks the ability to style a <select> element and its picker, exposed as ::picker(select), like regular HTML elements.
* [Form Fields Automatically Fit Contents](forms/form-fields-automatically-fit-contents.md) - By default, form controls like <input>, <textarea>, and <select> have fixed dimensions. Their sizes remain constant, regardless of the amount of content the user enters or selects.
* [Forms](forms/forms.md) - Forms discipline guide — semantic structure, fieldset/legend grouping, input types, autofill tokens, constraint validation, and accessible error feedback.
* [IME-safe enter-to-submit](forms/ime-safe-enter-submit.md) - Many chat interfaces submit their message when the user presses Enter in a <textarea>.
* [Required Field Feedback](forms/required-field-feedback.md) - Marking required fields with an error state immediately upon page load can be confusing. Ideally, a required field should only look "invalid" if the user has attempted to fill it out and failed.
* [Rich Media Picker (Customizable Select)](forms/rich-media-picker.md) - The native <select> element was historically difficult to style and could only contain plain text options.
* [Select Menu Interaction](forms/select-menu-interaction.md) - For mandatory dropdowns (e.g., "Choose a Country"), standard validation flags the field as invalid immediately if the default option has an empty value.
* [Brand-Consistent Range Slider](forms/slider.md) - Use a labeled <input type="range"> rather than recreating a slider with <div> elements or custom pointer handlers.
* [SMS OTP form verification](forms/sms-otp-form.md) - Delivering a one-time passcode (OTP) via SMS is a common flow for phone number verification, account recovery, step-up authentication, and payment confirmation.
* [Build Accessible Switch Controls](forms/switch.md) - Use the HTML switch attribute on <input type="checkbox" switch> with an associated <label> to build a binary on/off toggle that preserves native form submission, keyboard navigation, and screen reader semantics (see checkbox and forms).
* [Validate Input After Interaction](forms/validate-input-after-interaction.md) - Displaying validation errors the moment a user focuses on a field and starts typing is premature and distracting.

### HTML

* [HTML index](html/index.md) - 8 concepts
* [Accessible Web Components](html/accessible-web-components.md) - A shadow boundary changes how semantics and ARIA work. Two failures dominate: missing semantics inside the shadow tree, and ARIA references that silently break because they cannot cross shadow roots.
* [Custom Elements](html/custom-elements.md) - A custom element is a class registered against a tag name via customElements.define(). Registration and basic lifecycle are well understood; the rules below target the parts routinely implemented incorrectly.
* [Form-Associated Custom Elements](html/form-associated-custom-elements.md) - Do not fall back to a hidden <input> to surface a custom control's value to a form.
* [HTML](html/html.md) - Semantic HTML discipline guide — validation, content grouping, resource prioritization, native overlays (dialog, popover), details/summary disclosures, focus visibility, media elements, and form grouping.
* [Pre-rendering custom elements](html/prerendering-custom-elements.md) - Pre-rendering means shipping a custom element's markup — including its shadow tree — from the server, so the component is styled and structured before any JavaScript runs.
* [Shadow DOM, Templates & Slots](html/shadow-dom.md) - A shadow root is an encapsulated DOM subtree attached to a host element: styles inside it do not leak out, and page styles do not leak in (except inherited properties). Templates construct the tree efficiently; slots project Light DOM content into it.
* [Styling Web Components](html/styling-web-components.md) - Shadow DOM is a style boundary: page rules don't reach in and component rules don't leak out, except inherited properties (including custom properties). Cross it deliberately through the channels below.
* [Web Components Orientation](html/web-components.md) - Web Components are Custom Elements, Shadow DOM, and HTML Templates: the platform primitives for reusable, framework-agnostic components whose markup and styles are encapsulated from the document.

### JavaScript

* [JavaScript index](js/index.md) - 5 concepts
* [Calculating Event Differentials and Formatting Durations with Temporal](js/calculate-event-differentials.md) - Calculating the time elapsed or remaining between events (such as trial expirations, subscription countdowns, or SLA windows) and presenting those spans in a localized, human-readable format has historically required manual math or external libraries.
* [Capturing Location-Agnostic Data and Partial Dates with Temporal](js/capture-location-agnostic-data.md) - Recording chronological data that should remain identical regardless of the viewer's location—such as birthdates, daily alarms, credit card expirations, or monthly billing cycles—has historically been error-prone with the legacy Date object.
* [Coordinating Global Events with Temporal](js/coordinate-global-events.md) - Scheduling events across different time zones is notoriously difficult with the legacy Date object, especially around Daylight Saving Time (DST) transitions when hours can be skipped or repeated.
* [Sorting High-Precision Timestamps with Temporal.Instant](js/sort-high-precision-timestamps.md) - Log viewers, audit timelines, and telemetry UIs often ingest events whose ISO 8601 timestamps were recorded with microsecond or nanosecond precision by a server, database, or native clock (for example, 2026-04-01T12:00:00.000123456Z).
* [Supporting Global Calendar Systems with Temporal](js/support-global-calendar-systems.md) - The traditional JavaScript Date object is based on a proleptic Gregorian calendar, making it challenging to build applications for users who rely on other calendar systems, such as the Islamic (lunar), Hebrew (lunisolar), or Chinese (lunisolar) calendars.

### Performance

* [Performance index](performance/index.md) - 26 concepts
* [Debounce and batch multiple analytics events](performance/batch-analytics-events.md) - Most analytics, telemetry, and Core Web Vitals analytics data is lower priority than responding to the user, so you can safely defer sending it until the user leaves the page.
* [Break Up Long Tasks](performance/break-up-long-tasks.md) - Heavy computations or long loops can block the main thread, delaying event handlers and causing poor Interaction to Next Paint (INP) responsiveness.
* [Calculate total foreground time](performance/calculate-total-foreground-time.md) - This guide details how to accurately calculate the total time a user spends actively viewing a page.
* [Conditional Async Dependencies](performance/conditional-async-dependencies.md) - Top-level await allows modules to act as asynchronous functions, meaning they can pause module execution to await promises.
* [Defer rendering heavy content](performance/defer-rendering-heavy-content.md) - Web pages with extensive content—such as infinite scrolls, complex dashboards, or dense articles can suffer from slow initial rendering and sluggish interactions.
* [Defer Work Until Scroll Ends](performance/defer-work-until-scroll-ends.md) - Scrolling on the web should be smooth and responsive. Executing heavy tasks—such as layout recalculations, analytics data beacons tracking, or dynamic DOM updates—during scrolling can saturate the main thread, resulting in dropped frames and layout thrashing.
* [Deliver Optimized Decorative Images](performance/deliver-optimized-decorative-images.md) - Delivering optimized decorative images via CSS improves perceived performance without sacrificing visual quality.
* [Deprioritize background fetches](performance/deprioritize-background-fetches.md) - When a page performs multiple simultaneous network requests, they often compete for the same bandwidth.
* [Detect Initial Visibility State](performance/detect-initial-visibility-state.md) - Determining if a page was initially loaded in the background (e.g., opened in a new background tab) is critical for accurate performance monitoring.
* [Efficient Background Processing](performance/efficient-background-processing.md) - Pause heavy background tasks when a component is not being rendered by the browser to conserve system resources and battery life.
* [Faster SPA View Transitions via State Caching](performance/faster-spa-view-transitions.md) - Enable instant navigation between views in a Single-Page Application (SPA) by caching the rendered state of inactive views instead of destroying them.
* [Flicker-Free Client-Side A/B Testing](performance/flicker-free-client-side-ab-testing.md) - Client-side A/B testing tools work by loading a script that modifies the DOM after the browser has already begun constructing the page.
* [Reliably measure full-session analytics and telemetry](performance/full-session-analytics.md) - To reliably track analytics, Core Web Vitals, and telemetry data that covers the entirety of a user's visit to a web page (not just until page load), use the fetchLater() API.
* [Identify heavy-running JavaScript](performance/identify-heavy-scripts.md) - Heavy-running JavaScript can have a detrimental effect on both page load performance and interactivity.
* [Identify causes of poor INP](performance/identify-inp-causes.md) - Poor responsiveness to interactions leads to a poor impression of a page being slow or even completely broken.
* [Improve next page load performance](performance/improve-next-page-load-performance.md) - One of the most effective ways to improve page load performance for users navigating a site is to initiate loading the next page they're about to visit before they visit it.
* [Measure interaction and soft-navigation paint timing](performance/interaction-paint-timing.md) - Standard paint and responsiveness metrics leave a measurement gap after the initial page load.
* [Optimizing Interactions in Complex Layouts](performance/interactions-in-complex-layouts.md) - Maintain high frame rates (60FPS) and eliminate interaction latency during drag-and-drop or heavy mutations in complex, multi-column layouts like Kanban boards or massive data grids.
* [Lazy load video and audio](performance/lazy-load-video-and-audio.md) - Media elements (<video> and <audio>) and their associated resources (such as <video poster> images and preloaded metadata) consume significant network and storage bandwidth during initial page load.
* [Optimize image priority](performance/optimize-image-priority.md) - Browsers use heuristics to assign loading priorities to images, but these defaults may not always align with your page's Largest Contentful Paint (LCP).
* [Optimize preload priority](performance/optimize-preload-priority.md) - Preloading resources with <link rel="preload"> signals to the browser that a resource will be needed soon.
* [Optimize script priority](performance/optimize-script-priority.md) - Browsers assign default priorities to scripts based on where they appear in the document and whether they have attributes like async or defer.
* [Out-of-Order (OOO) HTML Streaming](performance/out-of-order-html-streaming.md) - Out-of-Order (OOO) HTML Streaming (also known as Declarative Partial Updates) is an alternative to the traditional "top-to-bottom" linear processing of HTML.
* [Performance](performance/performance.md) - The Critical Rendering Path dictates how quickly the browser converts HTML, CSS, and JavaScript into painted pixels.
* [Resolution Optimized Pseudo Elements](performance/resolution-optimized-pseudo-elements.md) - Using resolution-optimized images in CSS pseudo-elements (like ::before or ::after) allows you to add decorative icons or structural graphics without cluttering your HTML with extra DOM nodes.
* [Schedule Tasks By Priority](performance/schedule-tasks-by-priority.md) - When building complex web applications, tasks have different levels of urgency.

### Privacy

* [Privacy index](privacy/index.md) - 1 concept
* [Web Privacy Guidelines for Developers](privacy/privacy.md) - Web application developers must treat privacy as a foundational architectural requirement, not just a legal compliance checkbox.

### PWA

* [PWA index](pwa/index.md) - 2 concepts
* [Installing web applications](pwa/install-web-app.md) - Use the Web Install API to give users an explicit, in-page way to install a web application. Installation is always completed through browser-controlled consent UI; websites cannot silently install an app.
* [Migrating the Origin of an Installed Web App](pwa/migrate-web-app-origin.md) - Transferring an installed web app (PWA) to a new origin typically requires users to manually uninstall the old app and reinstall the new one.

### Security

* [Security index](security/index.md) - 17 concepts
* [Encrypt data client-side with WebCrypto](security/client-side-encryption.md) - Use the Web Cryptography API (crypto.subtle) to establish shared secrets over untrusted networks using quantum-resistant Key Encapsulation Mechanisms (KEMs) or classical key agreement, and encrypt sensitive data in the browser with Authenticated Encryption with Associated Data (AEAD).
* [Sign and verify data with WebCrypto](security/digital-signatures.md) - Use the Web Cryptography API (crypto.subtle) to sign and verify messages, tokens, or artifacts in the browser using quantum-resistant (ML-DSA) or classical ('Ed25519', 'ECDSA') asymmetric keys.
* [Local Network Access](security/local-network-access.md) - Local Network Access gates connections from public/local origins to private networks and loopback behind granular 'local-network' and 'loopback-network' permission prompts — secure context required, PNA preflights deprecated.
* [Passkey Authentication](security/passkey-authentication.md) - This guide details how to implement returning user authentication using discoverable credentials, both through explicit button triggers and seamless browser autofill suggestions (Conditional UI).
* [Passkey Conditional Create (Post-Login Promotion)](security/passkey-conditional-create.md) - This guide details how to automatically and silently register a passkey for a user immediately after a successful password-based sign-in, minimizing friction and boosting passkey adoption.
* [Passkey Management](security/passkey-management.md) - This guide details how to enable users to view, rename, and delete their registered passkeys while keeping saved credentials and user profile details synchronized between the server and the user's password managers using the Signal API.
* [Passkey Reauthentication](security/passkey-reauthentication.md) - This delta-focused guide details how to implement step-up authentication or re-verification for a signed-in user before they perform sensitive account changes (e.g. passwords updates, financial transfers).
* [Passkey Registration](security/passkey-registration.md) - This guide details how to enable users to register a passkey for their account, providing a highly secure, phishing-resistant passwordless sign-in alternative.
* [Passkeys Orientation](security/passkeys.md) - This guide provides high-density, action-oriented orientation for implementing secure, framework-agnostic passkey authentication and credential management in modern web applications.
* [Quick sign-ins with immediate UI mode](security/quick-sign-ins.md) - Navigating an unauthenticated user to a dedicated sign-in page when they click a "Sign in" link, start checkout, save an item to favorites, or reach an article paywall causes context loss and increases user drop-off.
* [Restrict outbound network connections with Connection Allowlists](security/restrict-outbound-connections.md) - The Connection-Allowlist HTTP response header restricts a document or worker to communicating only with an explicit list of network endpoints.
* [Sanitizing Untrusted HTML](security/sanitize-untrusted-html.md) - Safely displaying user-generated HTML is a common security challenge. The native Sanitizer API provides a built-in, browser-optimized way to strip dangerous content (like <script> tags or on* attributes) before it reaches the DOM.
* [Secure external subresources with Subresource Integrity, CORS, and Referrer Policy](security/secure-external-subresources.md) - When loading scripts, stylesheets, fonts, or images from third-party CDNs or external origins, verify their cryptographic integrity with Subresource Integrity (integrity in HTML and integrity() in CSS url()), configure cross-origin credential handling (crossorigin and cross-origin()), and restrict outgoing Referer headers (referrerpolicy and referrer-policy()).
* [Web Security](security/security.md) - Guidelines for implementing preventative security measures on the web safely and incrementally.
* [Prevent DOM-based XSS attacks with Trusted Types](security/trusted-types.md) - Trusted Types is a security feature that helps prevent DOM-based Cross-Site Scripting (DOM XSS) by requiring that data being passed into "dangerous" browser APIs (known as sinks) is first converted into a specific type, such as TrustedHTML.
* [Compare and validate web origins and sites](security/validate-origins.md) - While comparing event.origin against a fixed, port-normalized string literal (such as event.origin === 'https://app.example.com') works for simple allowlists, manual string comparisons and regular expressions break down when validating arbitrary URLs.
* [Verify email address ownership](security/verify-email-ownership.md) - When collecting an email address during sign-up, sign-in, checkout, or account recovery, verifying ownership traditionally requires sending an out-of-band one-time passcode (OTP) or magic link.

### UI Atoms

* [UI Atoms index](ui-atoms/index.md) - 13 concepts
* [Build Carousel Slide Effects](ui-atoms/carousel-slide-effects.md) - Carousel slide effects are a great way to add visual interest to a carousel.
* [Component-specific light/dark themes](ui-atoms/component-specific-light-dark-theme.md) - While more commonly set on the root, the color-scheme property can be set on individual elements to force them into a different color scheme from the rest of the page.
* [Using and managing icons](ui-atoms/icons.md) - Icon storage and rendering are separate choices. For example, an SVG sprite can supply an icon to the CSS icon system or be referenced with <use>.
* [Position Aware Tooltips](ui-atoms/position-aware-tooltips.md) - When building tooltips or popovers with CSS Anchor Positioning, the browser can automatically "flip" the element to a fallback position if it would otherwise overflow the viewport.
* [Pull to Reveal](ui-atoms/pull-to-reveal.md) - "Pull to reveal" is a UI pattern where content (such as a search bar or refresh control) is hidden above the top of a scrollable area on initial load, and the user can pull down (scroll up) to reveal it.
* [Responsive tables](ui-atoms/responsive-table.md) - Large data tables often become unreadable on small screens as columns overflow or shrink beyond legibility.
* [Scroll Position Aware Elements](ui-atoms/scroll-position-aware-elements.md) - Improve the user experience of floating buttons, like a "Back to Top" link, by showing them only when they are useful.
* [Build a Scroll Progress Indicator](ui-atoms/scroll-progress-indicator.md) - A scroll progress indicator is a common user interface pattern that visually communicates the user's progress through a scrollable document or container.
* [Scrollability Affordance Hints](ui-atoms/scrollability-affordance-hints.md) - Scrollability hints show users that a region has more content in a given direction, and disappear at that end of the content. There are two kinds.
* [Shrinking header on scroll](ui-atoms/shrinking-header-on-scroll.md) - A shrinking header on scroll is a common UI pattern where a fixed header element at the top of the page smoothly transitions to a smaller size as the user scrolls down.
* [Single-line text overflow](ui-atoms/single-line-overflow.md) - Text that has to stay on one line (tab and chip labels, table cells, sidebar items, file names, media titles) is often longer than its space, especially with user content and translations.
* [State-Aware Sticky Headers](ui-atoms/state-aware-sticky-headers.md) - Sticky headers are a common UI pattern, but they often need to change their appearance when they become "stuck" to maintain readability or save space.
* [Viewport-Aware Dropdowns](ui-atoms/viewport-aware-dropdowns.md) - A revealed action panel or popover button group is a useful pattern for users to access additional functionality while taking up minimal space.

### UI Behaviors

* [UI Behaviors index](ui-behaviors/index.md) - 40 concepts
* [Two-Dimensional Panning](ui-behaviors/2d-panning.md) - When a user scrolls a two-dimensional scroll container, browsers typically apply a scroll axis-locking heuristic (also known as "railing").
* [Anchor Positioning Tab Underline](ui-behaviors/anchor-positioning-tab-underline.md) - In a tab menu, provide a visual indicator showing users which tab is active by underlining the active tab item.
* [Animate Element Entry and Exit](ui-behaviors/animate-element-entry-exit.md) - In the past, CSS transitions could not animate elements when they were first added to the DOM or when their display property changed from none.
* [Animate Elements To and From Top Layer](ui-behaviors/animate-to-from-top-layer.md) - Elements that render in the "top layer" (like <dialog>, elements with the popover attribute, or tooltips) have historically been difficult to animate because they toggle between display: none and a visible state.
* [Carousel Snap Highlights](ui-behaviors/carousel-snap-highlights.md) - Scroll-state container queries allow you to style elements based on their current scroll state, such as whether an element is "stuck" through sticky positioning or "snapped" through scroll snapping.
* [Consistent Cross-Document Transitions](ui-behaviors/consistent-cross-document-transitions.md) - Cross-document view transitions animate elements between two pages during a same-origin navigation.
* [Cross-Document Transitions](ui-behaviors/cross-document-transitions.md) - Cross-document view transitions allow you to create smooth, app-like transitions between different pages of a Multi-Page Application (MPA). By default, the browser performs a cross-fade, but you can customize this to match your site's aesthetic.
* [Custom Button Actions](ui-behaviors/custom-button-actions.md) - The Invoker Commands API allows buttons to trigger actions on target elements declaratively using HTML attributes.
* [Declarative Dialog and Popover Control](ui-behaviors/declarative-dialog-popover-control.md) - Use the Invoker Commands API to toggle the visibility of <dialog> and [popover] elements directly from HTML buttons, eliminating the need for custom JavaScript event listeners.
* [Directional Navigation Transitions](ui-behaviors/directional-navigation-transitions.md) - Single Page Applications (SPAs) provide the appearance of navigation by replacing the content of the page without navigating to a new page.
* [Rearrange Items with Drag and Drop](ui-behaviors/drag-and-drop.md) - Add reordering to an existing list or row, vertical or horizontal.
* [Build a Draggable Element](ui-behaviors/drag.md) - Add dragging to an existing floating element such as a panel, palette, toolbar, inspector, or dialog. Dragging does not determine how the element is displayed, dismissed, stacked, or focused.
* [Creating a stagger animation](ui-behaviors/dynamic-sibling-animations.md) - Stagger animations provide an interesting effect where multiple ordered elements animate sequentially with a slight delay between each, rather than all animating at once.
* [Handling dynamic user-triggered changes to sort order](ui-behaviors/dynamic-sort.md) - Use this pattern when a user action reorders a list, card grid or table, with no item mid-interaction. It covers only applying the new order to the DOM (moving nodes, animating, announcing, performance), not how the order is computed or what triggers it.
* [Smoothly rearrange cards, lists, and groups of elements on add, remove, or reorder](ui-behaviors/group-element-transitions.md) - As items are added or removed from a list, or rearranged, transitions can help users maintain context.
* [Highlight Text Ranges](ui-behaviors/highlight-text-ranges.md) - The CSS Custom Highlight API lets you style arbitrary text ranges on a page without modifying the DOM structure.
* [Interactive Content Reveal](ui-behaviors/interactive-content-reveal.md) - Add performant, interactive reveal effects to your site with CSS masks and registered custom properties.
* [Interest Triggered Action Previews](ui-behaviors/interest-triggered-action-previews.md) - It can be beneficial to provide users a preview of their actions before they commit to them.
* [Show a tooltip when hovering](ui-behaviors/interest-triggered-tooltips.md) - Users expect to see additional related information without completely changing their context.
* [Light-Dismiss a Dialog](ui-behaviors/light-dismiss-a-dialog.md) - Modern modal dialogs often support "light-dismiss," allowing users to close a dialog by clicking or tapping the backdrop (the area outside the dialog). The closedby attribute provides a declarative way to enable this behavior without custom JavaScript.
* [Motion](ui-behaviors/motion.md) - Always respect reduced motion preferences. Choose between @media (prefers-reduced-motion: no-preference) and @media (prefers-reduced-motion: reduce) based on whether reduced motion removes the animation entirely or only adjusts its parameters.
* [Move DOM Element Without Losing State](ui-behaviors/move-dom-element-without-losing-state.md) - When reparenting DOM elements using traditional methods like appendChild() or insertBefore(), the browser implicitly removes the element from the DOM and then inserts it into its new location.
* [Build a Parallax Effect on Scroll](ui-behaviors/parallax-scroll-effects.md) - A parallax effect on scroll is a visual technique where different layers of content move at varying speeds as the user scrolls down a page.
* [Persistent Top Layer UI](ui-behaviors/persistent-top-layer-ui.md) - When moving an open <dialog>, popover, or fullscreen element in the DOM using traditional methods like appendChild() or insertBefore(), the browser implicitly removes the element from the DOM and re-inserts it.
* [Physics Based Easing](ui-behaviors/physics-based-easing.md) - Traditional CSS easing functions like ease-in or cubic-bezier() are limited to simple curves, making it impossible to create complex physics-based effects like bounces or springs.
* [Platform Controls Dismiss Dialog](ui-behaviors/platform-controls-dismiss-dialog.md) - When a modal dialog is open, users expect to use familiar controls to dismiss them: pressing the <kbd>Esc</kbd> key on a keyboard, using the back button or gesture on mobile platforms, or a dismiss gesture with assistive technologies.
* [Prevent the Page Underneath a Modal Dialog from Scrolling](ui-behaviors/prevent-page-scroll-under-modal-dialog.md) - When a <dialog> element is opened as a modal using showModal(), the browser promotes it to the top layer and marks the rest of the document inert. While that blocks pointer clicks and keyboard focus on the underlying page, it does not prevent scrolling.
* [Same Document Transitions](ui-behaviors/same-document-transitions.md) - Web sites often provide multiple views of an object, for instance a list of products, and then a detail page for each product.
* [Scoped Component Transitions](ui-behaviors/scoped-component-transitions.md) - Starting a view transition with document.startViewTransition() attaches the ::view-transition overlay to the :root element, which blocks pointer events on the rest of the page, prevents concurrent transitions, and obscures position.
* [Triggering Effects After Programmatic Scrolling Completes](ui-behaviors/scroll-completion-effects.md) - Element and Window scroll methods return a Promise that resolves when scrolling completes — await it instead of setTimeout or scrollend listeners before triggering post-scroll effects.
* [Add entry and exit effects to elements as they enter or exit the scrollport](ui-behaviors/scroll-entry-exit-effects.md) - Entry and exit effects are animations that are triggered when an element enters or leaves the viewport.
* [Scroll Snap Real-Time Feedback](ui-behaviors/scroll-snap-realtime-feedback.md) - Users expect immediate visual feedback when interacting with UI elements like carousels or galleries.
* [Scroll Snap State Sync](ui-behaviors/scroll-snap-state-sync.md) - Synchronizing UI state with a scrollable container's snap position traditionally required complex scroll event listeners, manual calculations of scroll offsets, and intersection observers.
* [Set a scroll target for the initial render](ui-behaviors/scroll-target-on-load.md) - The CSS property scroll-initial-target offers a declarative, CSS-only way to bring a specific descendant element into the visible area of its scroll container as soon as that container is rendered.
* [Scrollytelling](ui-behaviors/scrollytelling.md) - Scrollytelling is a popular technique used to create engaging and immersive web experiences.
* [Search hidden content](ui-behaviors/search-hidden-content.md) - Web interfaces often hide content from view to improve the user experience, save screen space, or increase page performance.
* [Sortable Table](ui-behaviors/sortable-table.md) - Use this pattern to let users sort a data table by clicking its column headers. Start from a complete, semantic <table> that is readable without JavaScript, then enhance it.
* [Spatial Navigation (Directional Keypad Focus)](ui-behaviors/spatial-navigation.md) - Directional focus navigation (using arrow keys or D-Pads) enables keyboard-only and alternative-input users to navigate interactive items based on their visual 2D layout.
* [Swipe to remove](ui-behaviors/swipe-to-remove.md) - Swipe-to-remove patterns are common in mobile applications but can be challenging to implement cleanly on the web.
* [Swipe to reveal](ui-behaviors/swipe-to-reveal.md) - Swipe-to-reveal patterns let users slide a foreground row or content pane horizontally to expose hidden UI—such as contextual action buttons (Pin, Mute, Archive, Delete) or a secondary side menu—without automatically activating any action.

### UI Components

* [UI Components index](ui-components/index.md) - 22 concepts
* [Accordion](ui-components/accordion.md) - Build accordions from a set of adjacent details elements.
* [Build an application menu bar](ui-components/app-menus.md) - An application menu bar (File, Edit, View, Help) is a row of menus that behaves as one widget: one Tab stop, ArrowLeft and ArrowRight move between menus, focusing a menu title shows its menu, and once one menu is open, pointing at another title switches to it.
* [Build breadcrumbs](ui-components/breadcrumbs.md) - Breadcrumbs show where the user is in a site hierarchy and link to each ancestor page.
* [Build a Card](ui-components/card.md) - A card groups one related piece of content or one choice. It is a visual pattern, not a fixed semantic or interaction model, so preserve the content's meaning and use the native interaction that matches its purpose.
* [Build a carousel](ui-components/carousel.md) - Build a carousel for a finite set of related items.
* [Styling Checkboxes](ui-components/checkbox.md) - Use semantic, accessible HTML with each checkbox associated with its label, either by nesting the <input> inside the <label> or by matching the label’s for attribute to the input’s id.
* [Copy button](ui-components/copy-button.md) - Build a button that copies the text of another element (code block, inline value, read-only field) or the current selection.
* [Dark mode toggles](ui-components/dark-mode-toggle.md) - A dark mode toggle lets users override the system color scheme for one site.
* [Dialog](ui-components/dialog.md) - Use the native <dialog> element for modal and non-modal dialogs. It provides the accessibility semantics, focus handling, top-layer rendering and Esc handling that custom overlays have to rebuild by hand.
* [Build an interactive hovercard](ui-components/hovercard.md) - Hovercards provide an interactive preview of content when a user expresses interest in a link through hover or focus.
* [Build a popup menu](ui-components/menu.md) - This guide covers one popup menu: a list of commands or links that users move through with arrow keys.
* [Responsive Site Navigation](ui-components/navbar.md) - Build a site navigation bar that uses one semantic navigation tree at every size, presents a native popover when the links do not fit, becomes an inline navigation when they do, and identifies the current page.
* [Navigation Drawer](ui-components/navigation-drawer.md) - A navigation drawer is a panel that slides in from the edge of the viewport over the page content, dimming everything behind it.
* [Creating Persistent App Tours](ui-components/persistent-app-tours.md) - Onboarding tours require overlays that persist while users interact with the highlighted features.
* [Creating Toast Notifications](ui-components/persistent-toast-notifications.md) - Toast notifications are transient status messages.
* [Progress ring](ui-components/progress-ring.md) - A progress ring (or circular progress bar) provides visual feedback on the status of a task. Unlike a linear progress bar, its circular shape is ideal for dashboards, card components, or anywhere space is constrained.
* [Build a Styled Progress Bar](ui-components/progress.md) - The <progress> element is the semantic way to represent the completion progress of a task, like downloading or uploading information or completing part of a multi-step process.
* [Build a Scrollspy Navigation](ui-components/scrollspy.md) - A scrollspy navigation is a common UI pattern that automatically highlights the navigation link corresponding to the section of the page currently in the viewport. This provides users with a clear sense of where they are in a long document as they scroll.
* [Loading spinner](ui-components/spinner.md) - A loading spinner (or activity indicator) informs users that a process is underway when the exact duration is unknown. Unlike a progress ring, a spinner is "indeterminate" and typically uses animation to signal activity.
* [Stack Drill Down](ui-components/stack-drill-down.md) - A stack drill-down is a hierarchical navigation pattern, common in mobile apps, where activating a link pushes a new full-screen view on top of the previous one.
* [Tabbed interfaces](ui-components/tabs.md) - Use focusgroup's tablist behavior for roving tabindex, automatic role assignment, and arrow-key focus management instead of hand-implementing the ARIA tablist pattern; never use tabs for page navigation.
* [Build a toolbar](ui-components/toolbar.md) - A toolbar groups related controls (formatting, alignment, view options) into one composite widget with a single tab stop.

### User Experience

* [User Experience index](user-experience/index.md) - 3 concepts
* [Maximize content and reduce noise](user-experience/content-first-noise-reduction.md) - Users come for the content. Keep the page frame small, move it out of the way while users read, and show secondary content only when asked.
* [Adapt to the form factor](user-experience/form-factor-adaptation.md) - The same interface runs on phones, laptops, and foldables, with touch, mouse, or keyboard. Size controls for the input, let components adapt to their container, and keep text and controls clear of system UI.
* [Implement natural interactions](user-experience/natural-interactions.md) - Interfaces feel natural when every input gets an immediate response, motion behaves like a physical object, content follows the user's finger, and nothing depends on a mouse.

### Visual Design

* [Visual Design index](visual-design/index.md) - 22 concepts
* [Adapt scrollbar to high-contrast preferences](visual-design/adapt-scrollbar-to-contrast-preferences.md) - Users who enable high-contrast modes in their operating system or browser expect UI elements (like scrollbars) to be extremely legible, often relying on stark foreground-background separation rather than subtle grays or theme colors.
* [Apply WebGL shaders to HTML content](visual-design/apply-webgl-shaders.md) - WebGL shaders provide powerful GPU-accelerated visual effects, enabling advanced capabilities like dynamic ripple distortions, lighting models, color grading, and custom vertex transformations.
* [Theming browser-generated UI](visual-design/browser-ui-theming.md) - Most browser-generated UI can be customized to some extent using CSS. Even if it requires modern features, it degrades gracefully in older browsers, and thus often does not require a polyfill or fallback.
* [Color](visual-design/color.md) - Don't use color alone to indicate the presence of a user interface component or its state: Use iconography and/or shape to help differentiate. Do not denote success/errors ONLY with color. Use icons or text (WCAG 1.4.1 Use of Color).
* [Complex Shapes](visual-design/complex-shapes.md) - To clip elements to complex, free-form shapes like brush strokes or organic textures, use CSS Masking (mask-image).
* [Ensure text readability with dynamic background colors](visual-design/contrast-color.md) - When building reusable UI components (like badges, buttons, headers, or footers) or supporting customizable themes, ensuring text remains readable against a variable background color can be challenging.
* [Custom text decorations](visual-design/custom-text-decorations.md) - Use the native text-decoration properties to style underlines, overlines, and strikethroughs, instead of faking them with borders, background gradients, or pseudo-elements.
* [Customize the color or thickness of a scrollbar](visual-design/customize-scrollbar-color-and-thickness.md) - You can customize the appearance of scrollbars using the standard CSS properties scrollbar-color and scrollbar-width.
* [Dark mode](visual-design/dark-mode.md) - The color-scheme property indicates which color schemes (such as light or dark) your page supports.
* [Equal-Width Text Lines](visual-design/equal-width-text-lines.md) - Poster-style lockups where each line is scaled so it spans the container's full width can create visually striking headings. Using text-fit, the browser scales each line during layout, so it stays correct on resize, copy changes, and font load.
* [Export HTML content from canvas](visual-design/export-html-media-from-canvas.md) - Web applications frequently need to capture and export rich HTML content—such as customized dashboards, styled documents, or interactive charts—as static images or video recordings.
* [Expose canvas content to browser features](visual-design/expose-canvas-content-to-browser-features.md) - Regular <canvas> content is not exposed to browser features such as screen readers, indexing, translation tools, accessibility assistive tools, find-in-page, print, etc.
* [Improve Text Layout and Legibility](visual-design/improve-text-layout-and-legibility.md) - The layout of text, particularly at the ends of lines and ends of paragraphs, can impact the legibility and aesthetic appeal of a page. CSS provides several text wrapping options that can improve specific use cases.
* [Enable interactive HTML content in 3D scenes](visual-design/interactive-content-in-3d-scenes.md) - The HTML-in-Canvas API allows rendering real DOM directly inside a canvas element.
* [Precise Text Alignment](visual-design/precise-text-alignment.md) - Browsers automatically add extra whitespace above and below text characters to accommodate line-height and font-specific metrics like ascenders and descenders.
* [Shaped Cutouts](visual-design/shaped-cutouts.md) - CSS Masking allows you to clip an element to a custom shape, such as adding a notch to a card or creating a shaped border. When combining shapes for complex layouts, choose your masking strategy based on the type of content the element contains.
* [Soft Edge Content Fade](visual-design/soft-edge-content-fade.md) - To apply a transparency gradient to the edges of a container (e.g., to indicate more content is available to scroll or to fade out text), use CSS Masking with a linear gradient.
* [Typography](visual-design/typography.md) - Use unitless line-height, rem-based font-size, and an 80-character measure; never fix text container heights so WCAG text-spacing and 200% zoom keep working.
* [Visual effects](visual-design/visual-effects.md) - Use in oklch or in oklab to explicitly specify the interpolation color space for gradients or color-mix().
* [Visually Stable Font Fallbacks](visual-design/visually-stable-font-fallbacks.md) - When web fonts load, they often replace a fallback font that has different dimensions, even if both are set to the same font-size.
* [Visually Stable Mixed Fonts](visual-design/visually-stable-mixed-fonts.md) - When mixing different font families, for instance when inserting inline code snippets, or switching out font families for different themes, differences in "x-height" (the height of lowercase letters) can make one font appear much smaller or larger than the other font.
* [Visually Texture Content](visual-design/visually-texture-content.md) - To apply realistic weathering or texture patterns (like grunge, noise, or paper texture) to an element, use CSS Masking (mask-image) with a repeating texture image.

### WebAssembly

* [WebAssembly index](wasm/index.md) - 1 concept
* [Compiling C and C++ to WebAssembly with Emscripten](wasm/cpp-on-the-web.md) - Use Emscripten (emcc and em++) to compile C and C++ into high-performance WebAssembly (Wasm) modules for the browser.

### WebMCP

* [WebMCP index](webmcp/index.md) - 3 concepts
* [Agentic Forms](webmcp/agentic-forms.md) - The Declarative API transforms standard HTML <form> elements into WebMCP tools via attributes. The browser synthesizes a JSON Schema from the form inputs and handles agent interactions.
* [Agentic JavaScript Tools](webmcp/agentic-javascript-tools.md) - The Imperative API uses document.modelContext.registerTool() to programmatically define JavaScript tools. This is ideal for Single Page Applications (SPAs) where tools need to be added or removed based on the current route or user state.
* [WebMCP](webmcp/webmcp.md) - WebMCP is a browser-native JavaScript API that allows web pages to expose their client-side functionality as structured "tools" to AI agents, browser assistants, and assistive technologies.

### Chrome Extensions

* [Chrome Extensions index](chrome-extensions/index.md) - 19 concepts
* [Calling External APIs from Extensions](chrome-extensions/api-calling.md) - Ordinarily, fetch requests made by extensions follow normal CORS rules.
* [Authentication with chrome.identity](chrome-extensions/auth-identity.md) - chrome.identity OAuth — the identity permission plus oauth2 client_id manifest block, the getAuthToken flow, and the extension-ID-dependent client_id gotcha.
* [Content Scripts & DOM Manipulation](chrome-extensions/content-scripts.md) - Inject JavaScript and CSS into web pages via the manifest or chrome.scripting — isolated world, run_at timing, and the host-permission requirement.
* [Context Menus](chrome-extensions/context-menus.md) - Create chrome.contextMenus entries in the service worker's onInstalled listener — menus persist and re-creation is idempotent — and scope them with the contexts array.
* [CSP & Sandboxed Code Execution](chrome-extensions/csp-sandbox.md) - Chrome Extensions enforce a strict Content Security Policy that cannot be relaxed for extension pages (popup, side panel, options, new tab, etc.).
* [Declarative Net Request (Content Filtering)](chrome-extensions/declarative-net-request.md) - Add "declarativeNetRequestFeedback" permission to use onRuleMatchedDebug (dev only).
* [DevTools Panels](chrome-extensions/devtools.md) - The devtools page runs ONLY when DevTools is open. It's invisible — its job is to create panels.
* [Generating Extension Icons](chrome-extensions/icons.md) - If generating real icon files is impractical, omit icons and default_icon from manifest.json entirely. Chrome uses a default puzzle-piece icon. This is always better than referencing files that don't exist.
* [Media Capture (Tab & Desktop)](chrome-extensions/media-capture.md) - Prefer tabCapture when you only need the current tab — it requires no user chooser dialog and no "tabs" permission. Use desktopCapture only when the user must select what to capture.
* [Message Passing](chrome-extensions/message-passing.md) - Returning a Promise directly from the listener is now supported and cleaner than the IIFE pattern.
* [Omnibox Integration](chrome-extensions/omnibox.md) - chrome.omnibox — register an address-bar keyword, supply suggestions on onInputChanged, and dispatch the chosen result on onInputEntered.
* [Permissions](chrome-extensions/permissions.md) - Scope host_permissions to specific domains rather than <all_urls> unless the extension genuinely needs to run on every site — broad host permissions draw extra Chrome Web Store review scrutiny.
* [Popup UI](chrome-extensions/popup-ui.md) - Popup state is lost when closed. Use chrome.storage for persistence.
* [Chrome Prompt API (LanguageModel) — Extension-Specific Notes](chrome-extensions/prompt-api.md) - The LanguageModel API (Prompt API) works in all extension contexts — service worker, popup, side panel, and other extension pages — with no additional manifest permissions required.
* [Service Worker Lifetime & State Management](chrome-extensions/service-worker.md) - Chrome terminates extension service workers after ~30 seconds of inactivity. Unlike Manifest V2 persistent background pages, you CANNOT rely on in-memory state.
* [Side Panel](chrome-extensions/side-panel.md) - A side panel definition alone does NOT make it openable. You MUST provide an explicit trigger to open it. Without one of these, users have no way to access the panel.
* [Chrome Storage API](chrome-extensions/storage.md) - chrome.storage.local, .sync, and .session compared — persistence, sync, and quotas — plus the required 'storage' permission.
* [Tab Management & Groups](chrome-extensions/tab-management.md) - Query, create, move, and group tabs with chrome.tabs and tabGroups — the 'tabs' permission is required to read url, title, and favIconUrl.
* [User Scripts API](chrome-extensions/user-scripts.md) - The chrome.userScripts API lets extensions run arbitrary code provided by the user at runtime — code that cannot be shipped as part of the extension package.

### Chrome Web Store

* [Chrome Web Store index](chrome-webstore/index.md) - 4 concepts
* [CHROMEWEBSTORE.md Template](chrome-webstore/chromewebstore-template.md) - Copy this template into the project root as CHROMEWEBSTORE.md and fill in each section. Fields marked [REQUIRED] must be completed before submission. Fields marked [RECOMMENDED] are optional but improve listing quality and approval odds.
* [Privacy Policy Guidance](chrome-webstore/privacy-policy.md) - A privacy policy URL is required when an extension handles user data or sensitive permissions; covers hosting options and what the policy must contain.
* [Pre-Publish Review Checklist](chrome-webstore/review-checklist.md) - Run through this checklist before every submission to the Chrome Web Store. Each item corresponds to a common rejection reason or publishing failure.
* [Store Listing Tips & Common Rejections](chrome-webstore/store-listing.md) - Chrome Web Store listing copy that survives review — 132-character short-description rules, keyword use, and the common rejection reasons.

<!-- vim: set ft=markdown -->
