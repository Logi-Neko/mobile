import 'package:flutter/material.dart';
import '../widget/category_grid.dart';

class SituationScreen extends StatelessWidget {
  const SituationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return CategoryGrid(
      title: "Xử lí tình huống",
      items: [
        CategoryItem(title: "Tình huống tại nhà", icon: Icons.home),
        CategoryItem(title: "Tình huống tại trường", icon: Icons.school),
        CategoryItem(title: "Tình huống ngoài xã hội", icon: Icons.groups),
      ],
    );
  }
}
