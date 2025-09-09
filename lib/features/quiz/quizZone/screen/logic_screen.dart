import 'package:flutter/material.dart';
import '../widget/category_grid.dart';

class LogicScreen extends StatelessWidget {
  const LogicScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return CategoryGrid(
      title: "Tư duy Logic",
      items: [
        CategoryItem(title: "Logic 1", icon: Icons.lightbulb),
        CategoryItem(title: "Logic 2", icon: Icons.psychology),
        CategoryItem(title: "Logic 3", icon: Icons.memory, isLocked: true),
        CategoryItem(title: "Sudoku", icon: Icons.grid_4x4),
      ],
    );
  }
}