# KeyStats Development Notes

## Build & Run
- Use Xcode to build and run the project
- Do not run `xcodebuild` from command line

## UI Guidance
- Ensure all UI colors adapt to dark mode (prefer dynamic colors + `resolvedCGColor`/`resolvedColor`)

## Recent Changes

### Menu Bar Icon Highlight State
Added focus/highlight state for the menu bar icon when popover is open (similar to WiFi icon behavior).

Changes in `MenuBarController.swift`:
1. `MenuBarController` now inherits from `NSObject` and conforms to `NSPopoverDelegate`
2. Added `isHighlighted` property to `MenuBarStatusView`
3. Added `draw(_:)` method to render rounded highlight background when active
4. Set `popover.delegate = self` and implemented `popoverDidClose(_:)` to reset highlight
5. Toggle `isHighlighted` in `showPopover()` and `closePopover()` methods
