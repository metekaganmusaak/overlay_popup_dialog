# Overlay Popup Dialog Widget

The OverlayPopupDialog widget is a widget that displays an animated and smooth overlay relative to the clicked widget, positioning it above, below, or on top of it.

You can test it out on web here => [OverlayPopupDialog Playground](https://metekaganmusaak.github.io/packages/overlay_popup_dialog)

![OverlayPopupDialogWidget](https://github.com/user-attachments/assets/1db05766-d025-46c3-bf72-8ad1c8a9f025)

## Features

- Show overlay dialog on; top, bottom or on the tapped widget.
- Customize overlay dialog as you wish.
- Use controller to call open and close overlay functions.

## Getting started

In the `pubspec.yaml` of your flutter project, add the following dependency:

```yaml
dependencies:
  overlay_popup_dialog: ^0.0.1
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
  barrierDismissible = false,
  overlayLocation = OverlayLocation.bottom,
  popupDialogTheme = PopupDialogTheme(
    decoration: BoxDecoration(
      color: Colors.blueGrey.shade100,
      borderRadius: BorderRadius.circular(10),
    ),
    padding: const EdgeInsets.all(16),
    leftMargin: 50,
    rightMargin: 50,
  ),
  dialogChild = TextButton(
    onPressed: () {
      _overlayController.close();
    },
    child: const Text('Press me to close the dialog'),
  ),
  child = TextButton(
    onPressed: () {
      _overlayController.show();
    },
    child: const Text('Show on bottom'),
  ),
),
```

That's it. You don't need to create a controller. But be sure that your child widget doesn't have
any onTap callback functions.

```dart
import 'package:flutter/material.dart';
import 'package:overlay_popup_dialog/overlay_popup_dialog.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      title: 'OverlayPopupDialog Playground',
      home: HomePage(),
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
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

  final _colorList = [
    Colors.red,
    Colors.green,
    Colors.blue,
    Colors.yellow,
    Colors.purple,
    Colors.orange,
    Colors.pink,
    Colors.teal,
    Colors.indigo,
    Colors.cyan,
    Colors.lime,
    Colors.amber,
    Colors.deepOrange,
    Colors.lightBlue,
    Colors.lightGreen,
    Colors.deepPurple,
    Colors.brown,
    Colors.grey,
    Colors.blueGrey,
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('OverlayPopupDialog Playground'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            // OverlayPopupDialog with top location.
            OverlayPopupDialog(
              overlayLocation: OverlayLocation.top,
              barrierDismissible: true,
              popupDialogTheme: PopupDialogTheme(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: Colors.blue.shade100,
                  borderRadius: BorderRadius.circular(10),
                ),
                height: 60,
                leftMargin: 16,
                rightMargin: 16,
              ),
              dialogChild: ListView.separated(
                padding: EdgeInsets.zero,
                separatorBuilder: (context, index) => const SizedBox(width: 4),
                itemBuilder: (context, index) => CircleAvatar(
                  backgroundColor: _colorList[index],
                  radius: 20,
                ),
                scrollDirection: Axis.horizontal,
                itemCount: _colorList.length,
              ),
              child: const ContainerWidget(location: OverlayLocation.top),
            ),
            // OverlayPopupDialog with on location.
            OverlayPopupDialog(
              overlayLocation: OverlayLocation.on,
              popupDialogTheme: const PopupDialogTheme(
                padding: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                height: 400,
              ),
              dialogChild: Column(
                children: [
                  Text(
                    'Select a color',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const Divider(),
                  Expanded(
                    child: ListView.separated(
                      padding: EdgeInsets.zero,
                      separatorBuilder: (context, index) =>
                          const SizedBox(height: 4),
                      itemBuilder: (context, index) => CircleAvatar(
                        backgroundColor: _colorList[index],
                        radius: 20,
                      ),
                      itemCount: _colorList.length,
                    ),
                  ),
                ],
              ),
              child: const ContainerWidget(location: OverlayLocation.on),
            ),
            // OverlayPopupDialog with bottom location.
            OverlayPopupDialog(
              controller: _overlayController,
              barrierDismissible: false,
              overlayLocation: OverlayLocation.bottom,
              popupDialogTheme: PopupDialogTheme(
                decoration: BoxDecoration(
                  color: Colors.blueGrey.shade100,
                  borderRadius: BorderRadius.circular(10),
                ),
                padding: const EdgeInsets.all(16),
                leftMargin: 50,
                rightMargin: 50,
              ),
              dialogChild: TextButton(
                onPressed: () {
                  _overlayController.close();
                },
                child: const Text('Press me to close the dialog'),
              ),
              child: TextButton(
                onPressed: () {
                  _overlayController.show();
                },
                child: const Text('Show on bottom'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class ContainerWidget extends StatelessWidget {
  const ContainerWidget({super.key, required this.location});

  final OverlayLocation location;
  final String text = "Tap me to open on: ";

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 50,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: switch (location) {
          OverlayLocation.bottom => Colors.lime,
          OverlayLocation.top => Colors.blue,
          OverlayLocation.on => Colors.cyan,
        },
        borderRadius: BorderRadius.circular(16),
      ),
      child: Text(switch (location) {
        OverlayLocation.bottom => '$text BOTTOM',
        OverlayLocation.top => '$text TOP',
        OverlayLocation.on => '$text CENTER',
      }),
    );
  }
}
```

Also you can check whole example code here:
[https://github.com/metekaganmusaak/overlay_popup_dialog/blob/main/example/lib/main.dart](https://github.com/metekaganmusaak/overlay_popup_dialog/blob/main/example/lib/main.dart)

## Additional information

Package's repo: <https://github.com/metekaganmusaak/overlay_popup_dialog>
