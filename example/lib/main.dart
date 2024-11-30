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
          crossAxisAlignment: CrossAxisAlignment.center,
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
            OverlayPopupDialog(
              overlayLocation: selectedLocation,
              animationDirection: selectedDirection,
              highlightChildOnBarrier: highlightChildOnBarrier,
              dialogChild: const _DialogWidget(onClose: null),
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.blue[200],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Text('No Controller & Not Tappable Child'),
              ),
            ),
            const SizedBox(height: 16),
            // No Controller & Tappable Child
            Align(
              alignment: Alignment.center,
              child: OverlayPopupDialog(
                overlayLocation: selectedLocation,
                animationDirection: selectedDirection,
                highlightChildOnBarrier: highlightChildOnBarrier,
                dialogChild: const _DialogWidget(onClose: null),
                child: ElevatedButton(
                  onPressed: () {
                    debugPrint('Tapped');
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
                animationDirection: selectedDirection,
                highlightChildOnBarrier: highlightChildOnBarrier,
                dialogChild: _DialogWidget(onClose: _overlayController.close),
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
            Center(
              child: OverlayPopupDialog(
                controller: _overlayController2,
                overlayLocation: selectedLocation,
                leftGap: 0,
                animationDirection: selectedDirection,
                highlightChildOnBarrier: highlightChildOnBarrier,
                dialogChild: _DialogWidget(onClose: _overlayController2.close),
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

class _DialogWidget extends StatelessWidget {
  final VoidCallback? onClose;

  const _DialogWidget({
    super.key,
    required this.onClose,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        color: Colors.blue[100],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'Dialog Title',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const Divider(),
          Text(
            'Lorem ipsum dolor sit amet, consectetur adipiscing elit. Lorem ipsum dolor sit amet, consectetur adipiscing elit. Lorem ipsum dolor sit amet, consectetur adipiscing elit. Lorem ipsum dolor sit amet, consectetur adipiscing elit. Lorem ipsum dolor sit amet, consectetur adipiscing elit. Lorem ipsum dolor sit amet, consectetur adipiscing elit.',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          const SizedBox(height: 16),
          if (onClose != null)
            Align(
              alignment: Alignment.bottomRight,
              child: ElevatedButton(
                onPressed: onClose,
                child: const Text('Close'),
              ),
            ),
        ],
      ),
    );
  }
}
