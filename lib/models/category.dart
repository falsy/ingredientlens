class Category {
  final String id;
  final String nameKey;
  final String iconPath;

  const Category({
    required this.id,
    required this.nameKey,
    required this.iconPath,
  });
}

const List<Category> categories = [
  Category(
    id: 'food',
    nameKey: 'food',
    iconPath: 'assets/icons/food.svg',
  ),
  Category(
    id: 'cosmetics',
    nameKey: 'cosmetics',
    iconPath: 'assets/icons/cosmetics.svg',
  ),
  Category(
    id: 'medicine',
    nameKey: 'medicine',
    iconPath: 'assets/icons/medicine.svg',
  ),
  Category(
    id: 'baby_products',
    nameKey: 'baby_products',
    iconPath: 'assets/icons/baby.svg',
  ),
  Category(
    id: 'pet_products',
    nameKey: 'pet_products',
    iconPath: 'assets/icons/pets.svg',
  ),
];
