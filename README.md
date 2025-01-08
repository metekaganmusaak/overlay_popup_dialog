# Overlay Popup Dialog Widget

The OverlayPopupDialog widget is a widget that displays an animated and smooth overlay relative to the clicked widget, positioning it above, below, left, right or on top of it.


[You can test this package on web by clicking here!](https://metekaganmusaak.github.io/packages/overlay_popup_dialog)

![opd](https://github.com/user-attachments/assets/c436caa9-265a-49e7-b45f-e2077eec7b95)

## Features

- Show overlay dialog on; top, bottom, left, right or on the tapped widget.
- Customize overlay dialog as you wish.
- Use controller to call open and close overlay functions.
- Controller animation directions like top to bottom, left to right etc.
- Show highlighted button when overlay open.

## Getting started

In the `pubspec.yaml` of your flutter project, add the following dependency:

```yaml
dependencies:
  overlay_popup_dialog: ^latest
```

Import these:

```dart
import 'package:overlay_popup_dialog/overlay_popup_dialog.dart';
```

## Usage

Create OverlayPopupDialogController and initialize it.

```dart
late final OverlayPopupDialogController _overlayController;

@override
void initState() {
  super.initState();
  _overlayController = OverlayPopupDialogController();
}

@override
void dispose() {
  _overlayController.dispose();
  super.dispose();
}
```

Then wrap your widget with OverlayPopupDialog like below.

```dart
 OverlayPopupDialog(
   controller = _overlayController,
   highlightChildOnBarrier = false,
   scaleBegin = 0.1,
   triggerWithLongPress = true,
   highlightBorderRadius = const BorderRadius.all(
     Radius.circular(16),
   ),
   highlightPadding = 4,
   overlayLocation = OverlayLocation.top,
   animationDuration = const Duration(seconds: 1),
   dialogChild = Container(
     margin: const EdgeInsets.all(8),
     decoration: BoxDecoration(
       color: Theme.of(context).dialogBackgroundColor,
       borderRadius: BorderRadius.circular(16),
     ),
     child: Column(
       mainAxisSize: MainAxisSize.min,
       spacing: 8,
       children: [
         const SizedBox(height: 16),
         Text(
           'Filter Categories',
           style: Theme.of(context).textTheme.titleLarge,
         ),
         Wrap(
           spacing: 8,
           runSpacing: 8,
           children: [
             ...categories.map(
               (category) => ChoiceChip(
                 label: Text(category.name),
                 selected: category.isSelected,
                 onSelected: (value) {
                   setState(() {
                     category.isSelected = value;
                     if (!selectedCategories.contains(category)) {
                       selectedCategories.add(category);
                     } else {
                       selectedCategories.remove(category);
                     }
                   });
                 },
               ),
             ),
           ],
         ),
         ...selectedCategories
             .map((category) => Text(category.name)),
         const SizedBox(height: 16)
       ],
     ),
   ),
   child = OutlinedButton(
     onPressed: () {
       _overlayController.show();
     },
     child: Text(selectedCategories.isEmpty
         ? 'Filter Categories'
         : 'Filtered Categories (${selectedCategories.length})'),
   ),
 )
```

That's it. You don't need to create a controller. But if you want to trigger dialog opening with custom callbacks,
you can use it. ⚠️ IMPORTANT: If you assigned a controller to OverlayPopupDialog widget, you must use this controller's
functions to open/close dialog. Otherwise it won't work.

Also you can check whole example code here:
[OverlayPopupDialog Github Link](https://github.com/metekaganmusaak/overlay_popup_dialog/blob/main/example/lib/main.dart)

## Additional information

Package's repo: <https://github.com/metekaganmusaak/overlay_popup_dialog>
