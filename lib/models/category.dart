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
    iconPath: 'assets/images/food.webp',
  ),
  Category(
    id: 'cosmetics',
    nameKey: 'cosmetics',
    iconPath: 'assets/images/cosmetics.webp',
  ),
  Category(
    id: 'medicine',
    nameKey: 'medicine',
    iconPath: 'assets/images/medicines.webp',
  ),
  Category(
    id: 'household_products',
    nameKey: 'household_products',
    iconPath: 'assets/images/household.webp',
  ),
  Category(
    id: 'baby_products',
    nameKey: 'baby_products',
    iconPath: 'assets/images/baby.webp',
  ),
  Category(
    id: 'pet_products',
    nameKey: 'pet_products',
    iconPath: 'assets/images/pet.webp',
  ),
];

const List<Category> nutritionCategories = [
  Category(
    id: 'processed_food',
    nameKey: 'processed_food',
    iconPath: 'assets/images/processed_food.webp',
  ),
  Category(
    id: 'dessert',
    nameKey: 'dessert',
    iconPath: 'assets/images/dessert.webp',
  ),
  Category(
    id: 'beverages',
    nameKey: 'beverages',
    iconPath: 'assets/images/beverages.webp',
  ),
];
