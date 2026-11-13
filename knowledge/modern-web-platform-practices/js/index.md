# JavaScript

* [Calculating Event Differentials and Formatting Durations with Temporal](calculate-event-differentials.md) - Calculating the time elapsed or remaining between events (such as trial expirations, subscription countdowns, or SLA windows) and presenting those spans in a localized, human-readable format has historically required manual math or external libraries.

* [Capturing Location-Agnostic Data and Partial Dates with Temporal](capture-location-agnostic-data.md) - Recording chronological data that should remain identical regardless of the viewer's location—such as birthdates, daily alarms, credit card expirations, or monthly billing cycles—has historically been error-prone with the legacy Date object.

* [Coordinating Global Events with Temporal](coordinate-global-events.md) - Scheduling events across different time zones is notoriously difficult with the legacy Date object, especially around Daylight Saving Time (DST) transitions when hours can be skipped or repeated.

* [Sorting High-Precision Timestamps with Temporal.Instant](sort-high-precision-timestamps.md) - Log viewers, audit timelines, and telemetry UIs often ingest events whose ISO 8601 timestamps were recorded with microsecond or nanosecond precision by a server, database, or native clock (for example, 2026-04-01T12:00:00.000123456Z).

* [Supporting Global Calendar Systems with Temporal](support-global-calendar-systems.md) - The traditional JavaScript Date object is based on a proleptic Gregorian calendar, making it challenging to build applications for users who rely on other calendar systems, such as the Islamic (lunar), Hebrew (lunisolar), or Chinese (lunisolar) calendars.

<!-- vim: set ft=markdown -->
