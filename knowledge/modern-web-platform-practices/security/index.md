# Security

* [Encrypt data client-side with WebCrypto](client-side-encryption.md) - Use the Web Cryptography API (crypto.subtle) to establish shared secrets over untrusted networks using quantum-resistant Key Encapsulation Mechanisms (KEMs) or classical key agreement, and encrypt sensitive data in the browser with Authenticated Encryption with Associated Data (AEAD).

* [Sign and verify data with WebCrypto](digital-signatures.md) - Use the Web Cryptography API (crypto.subtle) to sign and verify messages, tokens, or artifacts in the browser using quantum-resistant (ML-DSA) or classical ('Ed25519', 'ECDSA') asymmetric keys.

* [Local Network Access](local-network-access.md) - Local Network Access gates connections from public/local origins to private networks and loopback behind granular 'local-network' and 'loopback-network' permission prompts — secure context required, PNA preflights deprecated.

* [Passkey Authentication](passkey-authentication.md) - This guide details how to implement returning user authentication using discoverable credentials, both through explicit button triggers and seamless browser autofill suggestions (Conditional UI).

* [Passkey Conditional Create (Post-Login Promotion)](passkey-conditional-create.md) - This guide details how to automatically and silently register a passkey for a user immediately after a successful password-based sign-in, minimizing friction and boosting passkey adoption.

* [Passkey Management](passkey-management.md) - This guide details how to enable users to view, rename, and delete their registered passkeys while keeping saved credentials and user profile details synchronized between the server and the user's password managers using the Signal API.

* [Passkey Reauthentication](passkey-reauthentication.md) - This delta-focused guide details how to implement step-up authentication or re-verification for a signed-in user before they perform sensitive account changes (e.g. passwords updates, financial transfers).

* [Passkey Registration](passkey-registration.md) - This guide details how to enable users to register a passkey for their account, providing a highly secure, phishing-resistant passwordless sign-in alternative.

* [Passkeys Orientation](passkeys.md) - This guide provides high-density, action-oriented orientation for implementing secure, framework-agnostic passkey authentication and credential management in modern web applications.

* [Quick sign-ins with immediate UI mode](quick-sign-ins.md) - Navigating an unauthenticated user to a dedicated sign-in page when they click a "Sign in" link, start checkout, save an item to favorites, or reach an article paywall causes context loss and increases user drop-off.

* [Restrict outbound network connections with Connection Allowlists](restrict-outbound-connections.md) - The Connection-Allowlist HTTP response header restricts a document or worker to communicating only with an explicit list of network endpoints.

* [Sanitizing Untrusted HTML](sanitize-untrusted-html.md) - Safely displaying user-generated HTML is a common security challenge. The native Sanitizer API provides a built-in, browser-optimized way to strip dangerous content (like <script> tags or on* attributes) before it reaches the DOM.

* [Secure external subresources with Subresource Integrity, CORS, and Referrer Policy](secure-external-subresources.md) - When loading scripts, stylesheets, fonts, or images from third-party CDNs or external origins, verify their cryptographic integrity with Subresource Integrity (integrity in HTML and integrity() in CSS url()), configure cross-origin credential handling (crossorigin and cross-origin()), and restrict outgoing Referer headers (referrerpolicy and referrer-policy()).

* [Web Security](security.md) - Guidelines for implementing preventative security measures on the web safely and incrementally.

* [Prevent DOM-based XSS attacks with Trusted Types](trusted-types.md) - Trusted Types is a security feature that helps prevent DOM-based Cross-Site Scripting (DOM XSS) by requiring that data being passed into "dangerous" browser APIs (known as sinks) is first converted into a specific type, such as TrustedHTML.

* [Compare and validate web origins and sites](validate-origins.md) - While comparing event.origin against a fixed, port-normalized string literal (such as event.origin === 'https://app.example.com') works for simple allowlists, manual string comparisons and regular expressions break down when validating arbitrary URLs.

* [Verify email address ownership](verify-email-ownership.md) - When collecting an email address during sign-up, sign-in, checkout, or account recovery, verifying ownership traditionally requires sending an out-of-band one-time passcode (OTP) or magic link.

<!-- vim: set ft=markdown -->
