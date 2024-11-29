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
  late final OverlayPopupDialogController _overlayController2;

  @override
  void initState() {
    super.initState();
    _overlayController = OverlayPopupDialogController();
    _overlayController2 = OverlayPopupDialogController();
  }

  @override
  void dispose() {
    _overlayController.dispose();
    _overlayController2.dispose();
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
      body: SingleChildScrollView(
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
                    dense: true,
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
                    dense: true,
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
                  dense: true,
                  onChanged: (v) {
                    setState(() => highlightChildOnBarrier = v);
                  },
                  title: Text(highlightChildOnBarrier
                      ? 'Highlight ON'
                      : 'Highlight OFF'),
                ),
              ],
            ),

            const SizedBox(height: 64),
            // No Controller & Not Tappable Child
            Align(
              alignment: Alignment.center,
              child: OverlayPopupDialog(
                overlayLocation: selectedLocation,
                leftGap: 0,
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
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.blue[200],
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Text('No Controller & Not Tappable Child'),
                ),
              ),
            ),
            const SizedBox(height: 16),
            // No Controller & Tappable Child
            Align(
              alignment: Alignment.center,
              child: OverlayPopupDialog(
                overlayLocation: selectedLocation,
                leftGap: 0,
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
                child: ElevatedButton(
                  onPressed: () {
                    print('Worked...');
                  },
                  child: const Text('No Controller & Tappable Child '),
                ),
              ),
            ),
            const SizedBox(height: 16),
            // With Controller & Not Tappable Child
            Align(
              alignment: Alignment.center,
              child: OverlayPopupDialog(
                controller: _overlayController,
                overlayLocation: selectedLocation,
                leftGap: 0,
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
                child: InkWell(
                  onTap: () {
                    _overlayController.show();
                  },
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.blue[200],
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Text('With Controller & Not Tappable Child'),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),
            // With Controller & Tappable Child
            Align(
              alignment: Alignment.center,
              child: OverlayPopupDialog(
                controller: _overlayController2,
                overlayLocation: selectedLocation,
                leftGap: 0,
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
                child: ElevatedButton(
                  onPressed: () {
                    _overlayController2.show();
                  },
                  child: const Text('With Controller & Tappable Child '),
                ),
              ),
            ),
            const SizedBox(height: 64),
          ],
        ),
      ),
    );
  }
}
