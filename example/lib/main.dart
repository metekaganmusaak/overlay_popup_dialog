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
              animationDirection: AnimationDirection.topToBottom,
              animationDuration: const Duration(milliseconds: 700),
              barrierDismissible: true,
              highlightChildOnBarrier: true,
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
            const OverlayPopupDialog(
              overlayLocation: OverlayLocation.on,
              dialogChild: ColoredBox(
                color: Colors.blueGrey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text('Select a color'),
                  ],
                ),
              ),
              child: ContainerWidget(location: OverlayLocation.on),
            ),
            // OverlayPopupDialog with bottom location.
            OverlayPopupDialog(
              controller: _overlayController,
              barrierDismissible: false,
              animationDirection: AnimationDirection.leftToRight,
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
            const OverlayPopupDialog(
              overlayLocation: OverlayLocation.left,
              animationDirection: AnimationDirection.rightToLeft,
              animationDuration: Duration(seconds: 1),
              popupDialogTheme: PopupDialogTheme(
                rightMargin: 500,
                leftMargin: 50,
              ),
              dialogChild: Text('Hello! there brow'),
              child: Text('Tap me to open on left'),
            ),
            const OverlayPopupDialog(
              overlayLocation: OverlayLocation.right,
              animationDirection: AnimationDirection.bottomToTop,
              animationDuration: Duration(seconds: 1),
              popupDialogTheme: PopupDialogTheme(
                rightMargin: 10,
              ),
              dialogChild: Text('Hello!'),
              child: Text('Tap me to open on right'),
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
          OverlayLocation.left => Colors.red,
          OverlayLocation.right => Colors.green,
        },
        borderRadius: BorderRadius.circular(16),
      ),
      child: Text(switch (location) {
        OverlayLocation.bottom => '$text BOTTOM',
        OverlayLocation.top => '$text TOP',
        OverlayLocation.on => '$text CENTER',
        OverlayLocation.left => '$text LEFT',
        OverlayLocation.right => '$text RIGHT',
      }),
    );
  }
}
