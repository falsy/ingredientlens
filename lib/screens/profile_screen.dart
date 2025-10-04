import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:ingredient_lens/l10n/app_localizations.dart';
import '../utils/theme.dart';
import 'user_preference_detail_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return _buildContent(context);
  }

  Widget _buildContent(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [AppTheme.gradientStart, AppTheme.gradientEnd],
          ),
        ),
        child: Column(
          children: [
            SafeArea(
              bottom: false,
              child: AppBar(
                title: Text(
                  AppLocalizations.of(context)!.user_info,
                  style: const TextStyle(
                    color: AppTheme.blackColor,
                    fontSize: AppTheme.appBarTitleFontSize,
                    fontWeight: AppTheme.appBarTitleFontWeight,
                    letterSpacing: 0.4,
                  ),
                ),
                backgroundColor: Colors.transparent,
                elevation: 0,
                centerTitle: true,
                systemOverlayStyle: const SystemUiOverlayStyle(
                  statusBarColor: Colors.transparent,
                  statusBarIconBrightness: Brightness.dark,
                  statusBarBrightness: Brightness.light,
                  systemNavigationBarColor: Colors.transparent,
                  systemNavigationBarIconBrightness: Brightness.dark,
                ),
                leading: IconButton(
                  icon: Transform.rotate(
                    angle: 3.141592653589793, // 180도 회전
                    child: Image.asset(
                      'assets/images/icons/right-arrow.webp',
                      width: 16,
                      height: 16,
                      fit: BoxFit.contain,
                    ),
                  ),
                  onPressed: () => Navigator.pop(context),
                ),
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 12),
                    _buildPreferenceItem(
                      iconPath: 'assets/images/icons/weight.webp',
                      title: AppLocalizations.of(context)!.physical_info,
                      category: 'physical_info',
                    ),
                    const SizedBox(height: 2),
                    _buildPreferenceItem(
                      iconPath: 'assets/images/icons/religion.webp',
                      title: AppLocalizations.of(context)!.religion,
                      category: 'religion',
                    ),
                    const SizedBox(height: 2),
                    _buildPreferenceItem(
                      iconPath: 'assets/images/icons/skin.webp',
                      title: AppLocalizations.of(context)!.skin,
                      category: 'skin',
                    ),
                    const SizedBox(height: 2),
                    _buildPreferenceItem(
                      iconPath: 'assets/images/icons/allergy.webp',
                      title: AppLocalizations.of(context)!.allergy,
                      category: 'allergy',
                    ),
                    const SizedBox(height: 2),
                    _buildPreferenceItem(
                      iconPath: 'assets/images/icons/restrictions.webp',
                      title: AppLocalizations.of(context)!.diet,
                      category: 'diet',
                    ),
                    const SizedBox(height: 2),
                    _buildPreferenceItem(
                      iconPath: 'assets/images/icons/health.webp',
                      title: AppLocalizations.of(context)!.health,
                      category: 'health',
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPreferenceItem({
    required String iconPath,
    required String title,
    required String category,
  }) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => UserPreferenceDetailScreen(
              category: category,
              categoryTitle: title,
            ),
          ),
        );
      },
      child: Container(
        margin: const EdgeInsets.only(left: 20, right: 20, bottom: 12),
        child: Row(
          children: [
            // 아이콘 컨테이너
            Container(
              width: 48,
              height: 48,
              // decoration: BoxDecoration(
              //   color: AppTheme.gray100,
              //   borderRadius: BorderRadius.circular(10),
              // ),
              child: Center(
                child: Image.asset(
                  iconPath,
                  width: 28,
                  height: 28,
                  fit: BoxFit.contain,
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                title,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w500,
                  color: Color.fromARGB(180, 0, 0, 0),
                  height: 1.3,
                ),
              ),
            ),
            ColorFiltered(
              colorFilter: const ColorFilter.mode(
                AppTheme.gray600,
                BlendMode.srcIn,
              ),
              child: Image.asset(
                'assets/images/icons/right-arrow.webp',
                width: 12,
                height: 12,
                fit: BoxFit.contain,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
