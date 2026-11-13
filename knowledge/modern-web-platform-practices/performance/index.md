# Performance

* [Debounce and batch multiple analytics events](batch-analytics-events.md) - Most analytics, telemetry, and Core Web Vitals analytics data is lower priority than responding to the user, so you can safely defer sending it until the user leaves the page.

* [Break Up Long Tasks](break-up-long-tasks.md) - Heavy computations or long loops can block the main thread, delaying event handlers and causing poor Interaction to Next Paint (INP) responsiveness.

* [Calculate total foreground time](calculate-total-foreground-time.md) - This guide details how to accurately calculate the total time a user spends actively viewing a page.

* [Conditional Async Dependencies](conditional-async-dependencies.md) - Top-level await allows modules to act as asynchronous functions, meaning they can pause module execution to await promises.

* [Defer rendering heavy content](defer-rendering-heavy-content.md) - Web pages with extensive content—such as infinite scrolls, complex dashboards, or dense articles can suffer from slow initial rendering and sluggish interactions.

* [Defer Work Until Scroll Ends](defer-work-until-scroll-ends.md) - Scrolling on the web should be smooth and responsive. Executing heavy tasks—such as layout recalculations, analytics data beacons tracking, or dynamic DOM updates—during scrolling can saturate the main thread, resulting in dropped frames and layout thrashing.

* [Deliver Optimized Decorative Images](deliver-optimized-decorative-images.md) - Delivering optimized decorative images via CSS improves perceived performance without sacrificing visual quality.

* [Deprioritize background fetches](deprioritize-background-fetches.md) - When a page performs multiple simultaneous network requests, they often compete for the same bandwidth.

* [Detect Initial Visibility State](detect-initial-visibility-state.md) - Determining if a page was initially loaded in the background (e.g., opened in a new background tab) is critical for accurate performance monitoring.

* [Efficient Background Processing](efficient-background-processing.md) - Pause heavy background tasks when a component is not being rendered by the browser to conserve system resources and battery life.

* [Faster SPA View Transitions via State Caching](faster-spa-view-transitions.md) - Enable instant navigation between views in a Single-Page Application (SPA) by caching the rendered state of inactive views instead of destroying them.

* [Flicker-Free Client-Side A/B Testing](flicker-free-client-side-ab-testing.md) - Client-side A/B testing tools work by loading a script that modifies the DOM after the browser has already begun constructing the page.

* [Reliably measure full-session analytics and telemetry](full-session-analytics.md) - To reliably track analytics, Core Web Vitals, and telemetry data that covers the entirety of a user's visit to a web page (not just until page load), use the fetchLater() API.

* [Identify heavy-running JavaScript](identify-heavy-scripts.md) - Heavy-running JavaScript can have a detrimental effect on both page load performance and interactivity.

* [Identify causes of poor INP](identify-inp-causes.md) - Poor responsiveness to interactions leads to a poor impression of a page being slow or even completely broken.

* [Improve next page load performance](improve-next-page-load-performance.md) - One of the most effective ways to improve page load performance for users navigating a site is to initiate loading the next page they're about to visit before they visit it.

* [Measure interaction and soft-navigation paint timing](interaction-paint-timing.md) - Standard paint and responsiveness metrics leave a measurement gap after the initial page load.

* [Optimizing Interactions in Complex Layouts](interactions-in-complex-layouts.md) - Maintain high frame rates (60FPS) and eliminate interaction latency during drag-and-drop or heavy mutations in complex, multi-column layouts like Kanban boards or massive data grids.

* [Lazy load video and audio](lazy-load-video-and-audio.md) - Media elements (<video> and <audio>) and their associated resources (such as <video poster> images and preloaded metadata) consume significant network and storage bandwidth during initial page load.

* [Optimize image priority](optimize-image-priority.md) - Browsers use heuristics to assign loading priorities to images, but these defaults may not always align with your page's Largest Contentful Paint (LCP).

* [Optimize preload priority](optimize-preload-priority.md) - Preloading resources with <link rel="preload"> signals to the browser that a resource will be needed soon.

* [Optimize script priority](optimize-script-priority.md) - Browsers assign default priorities to scripts based on where they appear in the document and whether they have attributes like async or defer.

* [Out-of-Order (OOO) HTML Streaming](out-of-order-html-streaming.md) - Out-of-Order (OOO) HTML Streaming (also known as Declarative Partial Updates) is an alternative to the traditional "top-to-bottom" linear processing of HTML.

* [Performance](performance.md) - The Critical Rendering Path dictates how quickly the browser converts HTML, CSS, and JavaScript into painted pixels.

* [Resolution Optimized Pseudo Elements](resolution-optimized-pseudo-elements.md) - Using resolution-optimized images in CSS pseudo-elements (like ::before or ::after) allows you to add decorative icons or structural graphics without cluttering your HTML with extra DOM nodes.

* [Schedule Tasks By Priority](schedule-tasks-by-priority.md) - When building complex web applications, tasks have different levels of urgency.

<!-- vim: set ft=markdown -->
