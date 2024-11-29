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
          scaffoldBackgroundColor: Colors.white,
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
                highlightChildOnBarrier: highlightChildOnBarrier,
                dialogChild: Container(
                  height: kToolbarHeight,
                  width: MediaQuery.of(context).size.width,
                  color: Colors.blue[100],
                  child: Row(
                    children: [
                      Expanded(
                        child: ListView.builder(
                          itemCount: 100,
                          itemBuilder: (BuildContext context, int index) {
                            return Text('Item $index');
                          },
                          scrollDirection: Axis.horizontal,
                        ),
                      ),
                    ],
                  ),
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
