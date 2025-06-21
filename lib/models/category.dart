import 'package:flutter/material.dart';

class Category {
  final String id;
  final String nameKey;
  final IconData icon;
  
  const Category({
    required this.id,
    required this.nameKey,
    required this.icon,
  });
}

const List<Category> categories = [
  Category(
    id: 'food',
    nameKey: 'food',
    icon: Icons.restaurant,
  ),
  Category(
    id: 'cosmetics',
    nameKey: 'cosmetics',
    icon: Icons.face,
  ),
  Category(
    id: 'baby_products',
    nameKey: 'baby_products',
    icon: Icons.child_care,
  ),
  Category(
    id: 'pet_products',
    nameKey: 'pet_products',
    icon: Icons.pets,
  ),
  Category(
    id: 'health_supplements',
    nameKey: 'health_supplements',
    icon: Icons.medication,
  ),
];