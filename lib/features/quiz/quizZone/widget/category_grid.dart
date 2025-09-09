import 'package:flutter/material.dart';
import 'package:logi_neko/shared/color/app_color.dart';

class CategoryItem {
  final String title;
  final IconData icon;
  final bool isLocked;

  CategoryItem({
    required this.title,
    required this.icon,
    this.isLocked = false,
  });
}

class CategoryGrid extends StatelessWidget {
  final String title;
  final List<CategoryItem> items;

  const CategoryGrid({
    super.key,
    required this.title,
    required this.items,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body:  Container(
          width: double.infinity,
          decoration: const BoxDecoration(
            gradient: AppColors.primaryGradient,
          ),
        child: SafeArea(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    TextButton.icon(
                      style: TextButton.styleFrom(
                        backgroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                          side: const BorderSide(color: Colors.black),
                        ),
                      ),
                      onPressed: () => Navigator.pop(context),
                      icon: const Icon(Icons.arrow_back, color: Colors.black),
                      label: const Text("Quay lại",
                          style: TextStyle(color: Colors.black)),
                    ),
                    Row(
                      children: [
                        _topButton("Phụ huynh", Icons.family_restroom,
                            purple: true),
                        const SizedBox(width: 8),
                        _topButton("Premium", Icons.star,
                            orange: true, vip: true),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 12),

              Text(
                title,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 20),

              Expanded(
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: items
                        .map((item) => _buildItemCard(context, item))
                        .toList(),
                  ),
                ),
              ),
            ],
          ),

        ),
        ),
    );
  }

  Widget _buildItemCard(BuildContext context, CategoryItem item) {
    return Container(
      width: 140,
      height: 160,
      margin: const EdgeInsets.only(right: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Stack(
        children: [
          Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Icon(item.icon, size: 60, color: Colors.blueAccent),
                const SizedBox(height: 12),
                Text(
                  item.title,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          if (item.isLocked)
            Positioned.fill(
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.6),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: const Center(
                  child: Icon(Icons.lock, color: Colors.white, size: 40),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _topButton(String text, IconData icon,
      {bool purple = false, bool orange = false, bool vip = false}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: purple
            ? Colors.purple.shade100
            : orange
            ? Colors.orange
            : Colors.white,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: [
          Icon(icon, size: 16, color: orange ? Colors.white : Colors.black),
          const SizedBox(width: 4),
          Text(
            text,
            style: TextStyle(
              fontSize: 13,
              color: orange ? Colors.white : Colors.black,
            ),
          ),
        ],
      ),
    );
  }
}
