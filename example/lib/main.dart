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
      title: 'Overlay Popup Dialog Theme Example',
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
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Overlay Popup Dialog Theme Example'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            // OverlayPopupDialog with top location.
            OverlayPopupDialog(
              overlayLocation: OverlayLocation.top,
              popupDialogTheme: PopupDialogTheme(
                padding: const EdgeInsets.all(16),
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
                  backgroundColor: AppColors.colorList[index],
                  radius: 20,
                ),
                scrollDirection: Axis.horizontal,
                itemCount: AppColors.colorList.length,
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
                        backgroundColor: AppColors.colorList[index],
                        radius: 20,
                      ),
                      itemCount: AppColors.colorList.length,
                    ),
                  ),
                ],
              ),
              child: const ContainerWidget(location: OverlayLocation.on),
            ),
            // OverlayPopupDialog with bottom location.
            OverlayPopupDialog(
              overlayLocation: OverlayLocation.bottom,
              popupDialogTheme: PopupDialogTheme(
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.5),
                  borderRadius: BorderRadius.circular(10),
                ),
                padding: const EdgeInsets.all(16),
                leftMargin: MediaQuery.of(context).size.width * 0.3,
                rightMargin: MediaQuery.of(context).size.width * 0.3,
              ),
              dialogChild: const Text(
                'This button is pressed.',
                style: TextStyle(color: Colors.white),
              ),
              child: const ContainerWidget(location: OverlayLocation.bottom),
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
