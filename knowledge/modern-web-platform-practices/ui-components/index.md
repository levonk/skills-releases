# UI Components

* [Accordion](accordion.md) - Build accordions from a set of adjacent details elements.

* [Build an application menu bar](app-menus.md) - An application menu bar (File, Edit, View, Help) is a row of menus that behaves as one widget: one Tab stop, ArrowLeft and ArrowRight move between menus, focusing a menu title shows its menu, and once one menu is open, pointing at another title switches to it.

* [Build breadcrumbs](breadcrumbs.md) - Breadcrumbs show where the user is in a site hierarchy and link to each ancestor page.

* [Build a Card](card.md) - A card groups one related piece of content or one choice. It is a visual pattern, not a fixed semantic or interaction model, so preserve the content's meaning and use the native interaction that matches its purpose.

* [Build a carousel](carousel.md) - Build a carousel for a finite set of related items.

* [Styling Checkboxes](checkbox.md) - Use semantic, accessible HTML with each checkbox associated with its label, either by nesting the <input> inside the <label> or by matching the label’s for attribute to the input’s id.

* [Copy button](copy-button.md) - Build a button that copies the text of another element (code block, inline value, read-only field) or the current selection.

* [Dark mode toggles](dark-mode-toggle.md) - A dark mode toggle lets users override the system color scheme for one site.

* [Dialog](dialog.md) - Use the native <dialog> element for modal and non-modal dialogs. It provides the accessibility semantics, focus handling, top-layer rendering and Esc handling that custom overlays have to rebuild by hand.

* [Build an interactive hovercard](hovercard.md) - Hovercards provide an interactive preview of content when a user expresses interest in a link through hover or focus.

* [Build a popup menu](menu.md) - This guide covers one popup menu: a list of commands or links that users move through with arrow keys.

* [Responsive Site Navigation](navbar.md) - Build a site navigation bar that uses one semantic navigation tree at every size, presents a native popover when the links do not fit, becomes an inline navigation when they do, and identifies the current page.

* [Navigation Drawer](navigation-drawer.md) - A navigation drawer is a panel that slides in from the edge of the viewport over the page content, dimming everything behind it.

* [Creating Persistent App Tours](persistent-app-tours.md) - Onboarding tours require overlays that persist while users interact with the highlighted features.

* [Creating Toast Notifications](persistent-toast-notifications.md) - Toast notifications are transient status messages.

* [Progress ring](progress-ring.md) - A progress ring (or circular progress bar) provides visual feedback on the status of a task. Unlike a linear progress bar, its circular shape is ideal for dashboards, card components, or anywhere space is constrained.

* [Build a Styled Progress Bar](progress.md) - The <progress> element is the semantic way to represent the completion progress of a task, like downloading or uploading information or completing part of a multi-step process.

* [Build a Scrollspy Navigation](scrollspy.md) - A scrollspy navigation is a common UI pattern that automatically highlights the navigation link corresponding to the section of the page currently in the viewport. This provides users with a clear sense of where they are in a long document as they scroll.

* [Loading spinner](spinner.md) - A loading spinner (or activity indicator) informs users that a process is underway when the exact duration is unknown. Unlike a progress ring, a spinner is "indeterminate" and typically uses animation to signal activity.

* [Stack Drill Down](stack-drill-down.md) - A stack drill-down is a hierarchical navigation pattern, common in mobile apps, where activating a link pushes a new full-screen view on top of the previous one.

* [Tabbed interfaces](tabs.md) - Use focusgroup's tablist behavior for roving tabindex, automatic role assignment, and arrow-key focus management instead of hand-implementing the ARIA tablist pattern; never use tabs for page navigation.

* [Build a toolbar](toolbar.md) - A toolbar groups related controls (formatting, alignment, view options) into one composite widget with a single tab stop.

<!-- vim: set ft=markdown -->
