import 'package:flutter/material.dart';
import '../utils/theme.dart';
import '../l10n/app_localizations.dart';

class BottomNavigationWidget extends StatelessWidget {
  final int currentIndex;
  final Function(int) onTap;

  const BottomNavigationWidget({
    Key? key,
    required this.currentIndex,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Container(
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 8,
              offset: const Offset(0, -2),
              spreadRadius: 0,
            ),
          ],
        ),
        child: SafeArea(
          child: Container(
            height: 64,
            padding: const EdgeInsets.symmetric(horizontal: 6),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildNavItem(
                  context,
                  iconPath: 'assets/images/icons/ingredient.webp',
                  label: l10n.ingredients_short,
                  index: 0,
                ),
                _buildNavItem(
                  context,
                  iconPath: 'assets/images/icons/nutritional.webp',
                  label: l10n.nutrition_short,
                  index: 1,
                ),
                _buildNavItem(
                  context,
                  iconPath: 'assets/images/icons/kcal.webp',
                  label: l10n.calorie_short,
                  index: 2,
                ),
                _buildNavItem(
                  context,
                  iconPath: 'assets/images/icons/menu.webp',
                  label: l10n.menu,
                  index: 3,
                ),
              ],
            ),
          ),
        ));
  }

  Widget _buildNavItem(
    BuildContext context, {
    required String iconPath,
    required String label,
    required int index,
  }) {
    final isSelected = currentIndex == index;
    final color =
        isSelected ? AppTheme.primaryColor : const Color.fromARGB(160, 0, 0, 0);

    return Expanded(
      child: GestureDetector(
        onTap: () => onTap(index),
        behavior: HitTestBehavior.opaque,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            ColorFiltered(
              colorFilter: ColorFilter.mode(
                color,
                BlendMode.srcIn,
              ),
              child: Image.asset(
                iconPath,
                width: 20,
                height: 20,
                fit: BoxFit.contain,
              ),
            ),
            const SizedBox(height: 3),
            Text(
              label,
              style: TextStyle(
                color: color,
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}
