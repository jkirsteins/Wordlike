# Deferred Audit Findings — iOS 16 Cleanup Backlog

These items were identified during the iOS 16 minimum target audit but deferred for a future bump or dedicated refactoring pass.

---

## `onChange(of:)` old form — 17 instances across 10 files

The single-argument closure form of `onChange(of:)` is deprecated in iOS 17. Not yet an issue at iOS 16, but should be migrated when bumping the deployment target to iOS 17.

---

## Replace UIKit bridges with SwiftUI-native equivalents (iOS 16+)

| UIKit bridge | SwiftUI replacement |
|---|---|
| `ActivityViewController` | `ShareLink` |
| `SheetPresentationForSwiftUI` | `.presentationDetents()` modifier |
| `UIButtonClose` | Native SwiftUI `Button` with SF Symbol (`.xmark`) |
| `ScreenshotMaker` | `ImageRenderer` |

---

## Force unwrap hardening

Locations that use `!` and could crash at runtime:

- `GameHost.swift:195,207,208,378` — `dailyState!`
- `NavigationList.swift:451` — `gameLocale(loc)!`
- `StringExtensions.swift:67` — `dateFormatter.date(from:)!`
- `ColorExtensions.swift:81` — `CIColor(color:)!`
- `MockDevice.swift:96` — `screenshot!`

---

## `@MainActor` adoption

There is currently zero usage of `@MainActor` in the codebase. All `ObservableObject` classes should be annotated to ensure UI updates always happen on the main actor.

---

## `DispatchQueue.main.async` → `@MainActor`

Explicit `DispatchQueue.main.async` calls to migrate once `@MainActor` is adopted:

- `GameHost.swift:439`
- `NavigationList.swift:83`
- `SettingsView.swift:181`
- `ScreenshotMaker.swift:39`
- `CloudStorageSync.swift:51,61`

---

## `@ObservedObject` on singleton

`NavigationList.swift:102` uses `@ObservedObject` on a singleton. This should be `@StateObject` to prevent the object from being re-created on re-render.

---

## macOS `Flag.body` recreates `NativeImage` every render

`NavigationList.swift:126-139` — the `Flag` view body creates a new `NativeImage` on every render pass. Cache or memoize the image.
