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
      title: 'Overlay Popup Dialog Theme Example',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Overlay Popup Dialog Theme Example'),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: <Widget>[
              OverlayPopupDialog(
                overlayLocation: OverlayLocation.top,
                showCloseIcon: true,
                popupDialogTheme: PopupDialogTheme(
                  padding: const EdgeInsets.all(4),
                  height: 100,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                dialogChild: ListView.separated(
                  padding: EdgeInsets.zero,
                  separatorBuilder: (context, index) =>
                      const SizedBox(width: 4),
                  itemBuilder: (context, index) => CircleAvatar(
                    backgroundColor: AppColors.colorList[index],
                    radius: 20,
                  ),
                  scrollDirection: Axis.horizontal,
                  itemCount: AppColors.colorList.length,
                ),
                child: const ContainerWidget(location: OverlayLocation.top),
              ),
              OverlayPopupDialog(
                overlayLocation: OverlayLocation.on,
                showCloseIcon: true,
                popupDialogTheme: const PopupDialogTheme(
                  closeIcon: Icons.remove_red_eye_outlined,
                  closeIconColor: Colors.black,
                  padding: EdgeInsets.symmetric(horizontal: 16),
                  height: 200,
                ),
                dialogChild: ListView.builder(
                  itemCount: 100,
                  itemBuilder: (BuildContext context, int index) {
                    return ListTile(
                      title: Text('Item ${index + 1}'),
                    );
                  },
                ),
                child: const ContainerWidget(location: OverlayLocation.on),
              ),
              OverlayPopupDialog(
                overlayLocation: OverlayLocation.bottom,
                showCloseIcon: false,
                popupDialogTheme: PopupDialogTheme(
                  closeIcon: Icons.remove_red_eye_outlined,
                  closeIconColor: Colors.black,
                  padding: const EdgeInsets.all(4),
                  height: null,
                  decoration: BoxDecoration(
                    color: Colors.deepOrangeAccent.shade100,
                  ),
                ),
                dialogChild: Wrap(
                  children: [
                    for (var i = 0; i < AppColors.colorList.length; i++)
                      CircleAvatar(
                        backgroundColor: AppColors.colorList[i],
                        radius: 20,
                      ),
                  ],
                ),
                child: const ContainerWidget(location: OverlayLocation.bottom),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class ContainerWidget extends StatelessWidget {
  const ContainerWidget({super.key, required this.location});

  final OverlayLocation location;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 30,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: switch (location) {
          OverlayLocation.bottom => Colors.lime,
          OverlayLocation.top => Colors.blue,
          OverlayLocation.on => Colors.cyan,
        },
        borderRadius: BorderRadius.circular(10),
      ),
      child: Text(location.name),
    );
  }
}

class AppColors {
  static const colorList = [
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
}
