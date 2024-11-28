import 'package:flutter/material.dart';
import 'package:overlay_popup_dialog/overlay_popup_dialog.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'OverlayPopupDialog Playground',
      home: const HomePage(),
      theme: ThemeData(
          expansionTileTheme: ExpansionTileThemeData(
        backgroundColor: Colors.lightBlue[100],
        collapsedBackgroundColor: Colors.grey[200],
      )),
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

  List<OverlayLocation> locations = [
    OverlayLocation.bottom,
    OverlayLocation.top,
    OverlayLocation.on,
    OverlayLocation.left,
    OverlayLocation.right,
  ];

  OverlayLocation selectedLocation = OverlayLocation.bottom;

  List<AnimationDirection> directions = [
    AnimationDirection.TTB,
    AnimationDirection.BTT,
  ];

  AnimationDirection selectedDirection = AnimationDirection.TTB;

  List<int> animationSpeeds = [
    300,
    800,
    1500,
  ];

  int selectedAnimationSpeed = 300;

  bool highlightChildOnBarrier = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('OverlayPopupDialog Playground'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            ExpansionTile(
              title: Text('Overlay Location: ${selectedLocation.toString()}'),
              children: [
                for (final location in locations)
                  RadioListTile(
                    value: location,
                    groupValue: selectedLocation,
                    title: Text(location.toString()),
                    onChanged: (v) {
                      if (v != null) {
                        setState(() => selectedLocation = location);
                        if (selectedLocation == OverlayLocation.left ||
                            selectedLocation == OverlayLocation.right) {
                          setState(() {
                            selectedDirection = AnimationDirection.LTR;
                            directions = [
                              AnimationDirection.LTR,
                              AnimationDirection.RTL,
                            ];
                          });
                        } else {
                          setState(() {
                            selectedDirection = AnimationDirection.TTB;
                            directions = [
                              AnimationDirection.TTB,
                              AnimationDirection.BTT,
                            ];
                          });
                        }
                      }
                    },
                  ),
              ],
            ),
            ExpansionTile(
              title:
                  Text('Animation Direction: ${selectedDirection.toString()}'),
              children: [
                for (final direction in directions)
                  RadioListTile(
                    value: direction,
                    groupValue: selectedDirection,
                    title: Text(direction.toString()),
                    onChanged: (v) {
                      if (v != null) {
                        setState(() => selectedDirection = direction);
                      }
                    },
                  ),
              ],
            ),
            ExpansionTile(
              title: Text('Animation Speed: $selectedAnimationSpeed ms'),
              children: [
                for (final speed in animationSpeeds)
                  RadioListTile(
                    value: speed,
                    groupValue: selectedAnimationSpeed,
                    title: Text(speed.toString()),
                    onChanged: (v) {
                      if (v != null) {
                        setState(() => selectedAnimationSpeed = speed);
                      }
                    },
                  ),
              ],
            ),
            ExpansionTile(
              title:
                  Text('Highlight Child On Barrier: $highlightChildOnBarrier'),
              children: [
                SwitchListTile(
                  value: highlightChildOnBarrier,
                  onChanged: (v) {
                    setState(() => highlightChildOnBarrier = v);
                  },
                  title: Text(highlightChildOnBarrier
                      ? 'Highlight ON'
                      : 'Highlight OFF'),
                ),
              ],
            ),
            const Spacer(),
            Align(
              alignment: Alignment.center,
              child: OverlayPopupDialog(
                overlayLocation: selectedLocation,
                animationDirection: selectedDirection,
                animationDuration: Duration(
                  milliseconds: selectedAnimationSpeed,
                ),
                highlightChildOnBarrier: highlightChildOnBarrier,
                dialogChild: const Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text('Tap anywhere outside to close'),
                  ],
                ),
                child: Container(
                  height: 50,
                  width: 150,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: Colors.red,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: Colors.black, width: 1),
                  ),
                  padding: const EdgeInsets.all(4),
                  child: const Text('TAP ME'),
                ),
              ),
            ),
            const Spacer(),
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
