# Changelog

## 2.0.0

### Breaking Changes

- Removed `leftGap`, `rightGap`, `topGap`, and `bottomGap` properties in favor of a single `padding` property using `EdgeInsets`
- Changed default `overlayLocation` from `OverlayLocation.bottom` to `OverlayLocation.auto`
- Changed default `highlightPadding` from `4.0` to `0.0`
- Removed `AnimationDirection` enum in favor of using `overlayLocation` for determining slide direction

### Features

- Added `auto` option to `OverlayLocation` for automatic positioning based on available space
- Added predefined animation curves with `OverlayAnimationCurves`
- Added predefined animation durations with `OverlayAnimationDurations`

### Performance Improvements

- Added `RepaintBoundary` for better rendering performance
- Optimized barrier rebuilds with cached color values
- Improved scroll detection logic
- Added size change detection to prevent unnecessary rebuilds

### Documentation

- Added comprehensive documentation for all public APIs
- Added detailed examples in doc comments
- Improved property descriptions
- Added usage examples for common scenarios
- Updated trigger behavior documentation for controller usage
- Removed withOpacity() function to toValues() function

### Bug Fixes

- Fixed scroll detection interfering with overlay trigger
- Fixed overlay positioning when using `OverlayLocation.on`
- Fixed long press timer not being cancelled properly
- Fixed overlay dialog size depending on the child widget size

### Code Quality

- Added assertions for property validation
- Improved error handling in overlay operations
- Enhanced code organization and readability
- Added type safety improvements

## 1.0.1

- Changes in documentation.

## 0.1.5

- With this update, all OverlayLocation properties can now be used in conjunction with all AnimationDirection properties.
- It is now possible to define a curve and animation duration for animations.
- The barrier color can be customized.

## 0.1.1

- Fixed overlay width issues on OverlayLocation.on, bottom and top positions.
- Minor changes in codebase.

## 0.1.0

- Fixed some known bugs.
- Animation direction feature added. You can control sliding animation of your overlay popup dialog.
- Added highlighting tapped child widget when overlay opened.
- Added new playground example to see changes more precisely.

## 0.0.3

- Web playground link added in README file.

## 0.0.2

- README changes.

## 0.0.1

- Initial version of the OverlayPopupDialog widget.
