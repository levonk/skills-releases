# Chrome Extensions

* [Calling External APIs from Extensions](api-calling.md) - Ordinarily, fetch requests made by extensions follow normal CORS rules.

* [Authentication with chrome.identity](auth-identity.md) - chrome.identity OAuth — the identity permission plus oauth2 client_id manifest block, the getAuthToken flow, and the extension-ID-dependent client_id gotcha.

* [Content Scripts & DOM Manipulation](content-scripts.md) - Inject JavaScript and CSS into web pages via the manifest or chrome.scripting — isolated world, run_at timing, and the host-permission requirement.

* [Context Menus](context-menus.md) - Create chrome.contextMenus entries in the service worker's onInstalled listener — menus persist and re-creation is idempotent — and scope them with the contexts array.

* [CSP & Sandboxed Code Execution](csp-sandbox.md) - Chrome Extensions enforce a strict Content Security Policy that cannot be relaxed for extension pages (popup, side panel, options, new tab, etc.).

* [Declarative Net Request (Content Filtering)](declarative-net-request.md) - Add "declarativeNetRequestFeedback" permission to use onRuleMatchedDebug (dev only).

* [DevTools Panels](devtools.md) - The devtools page runs ONLY when DevTools is open. It's invisible — its job is to create panels.

* [Generating Extension Icons](icons.md) - If generating real icon files is impractical, omit icons and default_icon from manifest.json entirely. Chrome uses a default puzzle-piece icon. This is always better than referencing files that don't exist.

* [Media Capture (Tab & Desktop)](media-capture.md) - Prefer tabCapture when you only need the current tab — it requires no user chooser dialog and no "tabs" permission. Use desktopCapture only when the user must select what to capture.

* [Message Passing](message-passing.md) - Returning a Promise directly from the listener is now supported and cleaner than the IIFE pattern.

* [Omnibox Integration](omnibox.md) - chrome.omnibox — register an address-bar keyword, supply suggestions on onInputChanged, and dispatch the chosen result on onInputEntered.

* [Permissions](permissions.md) - Scope host_permissions to specific domains rather than <all_urls> unless the extension genuinely needs to run on every site — broad host permissions draw extra Chrome Web Store review scrutiny.

* [Popup UI](popup-ui.md) - Popup state is lost when closed. Use chrome.storage for persistence.

* [Chrome Prompt API (LanguageModel) — Extension-Specific Notes](prompt-api.md) - The LanguageModel API (Prompt API) works in all extension contexts — service worker, popup, side panel, and other extension pages — with no additional manifest permissions required.

* [Service Worker Lifetime & State Management](service-worker.md) - Chrome terminates extension service workers after ~30 seconds of inactivity. Unlike Manifest V2 persistent background pages, you CANNOT rely on in-memory state.

* [Side Panel](side-panel.md) - A side panel definition alone does NOT make it openable. You MUST provide an explicit trigger to open it. Without one of these, users have no way to access the panel.

* [Chrome Storage API](storage.md) - chrome.storage.local, .sync, and .session compared — persistence, sync, and quotas — plus the required 'storage' permission.

* [Tab Management & Groups](tab-management.md) - Query, create, move, and group tabs with chrome.tabs and tabGroups — the 'tabs' permission is required to read url, title, and favIconUrl.

* [User Scripts API](user-scripts.md) - The chrome.userScripts API lets extensions run arbitrary code provided by the user at runtime — code that cannot be shipped as part of the extension package.

<!-- vim: set ft=markdown -->
