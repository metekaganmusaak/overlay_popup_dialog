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

class CategoryModel {
  final String name;
  final IconData icon;
  bool isSelected;

  CategoryModel({
    required this.name,
    required this.icon,
    this.isSelected = false,
  });
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

  bool isTapped = false;

  final List<CategoryModel> categories = [
    CategoryModel(name: 'All', icon: Icons.all_inclusive),
    CategoryModel(name: 'Food', icon: Icons.fastfood),
    CategoryModel(name: 'Drink', icon: Icons.local_drink),
    CategoryModel(name: 'Dessert', icon: Icons.icecream),
  ];

  List<CategoryModel> selectedCategories = [];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('OverlayPopupDialog Playground'),
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Align(
            alignment: Alignment.center,
            child: OverlayPopupDialog(
              highlightChildOnBarrier: true,
              highlightBorderRadius:
                  const BorderRadius.all(Radius.circular(16)),
              highlightPadding: 4,
              overlayLocation: OverlayLocation.top,
              animationDirection: AnimationDirection.TTB,
              animationDuration: const Duration(seconds: 1),
              animationType: AnimationType.fade,
              dialogChild: Container(
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
              child: OutlinedButton(
                onPressed: () {},
                child: Text(selectedCategories.isEmpty
                    ? 'Filter Categories'
                    : 'Filtered Categories (${selectedCategories.length})'),
              ),
            ),
          ),
          ...selectedCategories.map((category) => Text(category.name)),
        ],
      ),
    );
  }
}
