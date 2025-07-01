import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../utils/theme.dart';

class HomeFooterWidget extends StatelessWidget {
  const HomeFooterWidget({super.key});

  Future<void> _launchPrivacyPolicy(BuildContext context) async {
    final Uri url = Uri.parse('https://falsy.me/ingredientlens/privacy.html');
    if (!await launchUrl(url, mode: LaunchMode.externalApplication)) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Could not open Privacy Policy'),
            backgroundColor: AppTheme.negativeColor,
          ),
        );
      }
    }
  }

  Future<void> _launchTermsOfService(BuildContext context) async {
    final Uri url = Uri.parse('https://falsy.me/ingredientlens/terms.html');
    if (!await launchUrl(url, mode: LaunchMode.externalApplication)) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Could not open Terms of Service'),
            backgroundColor: AppTheme.negativeColor,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.only(top: 12, bottom: 28, left: 14, right: 14),
      decoration: const BoxDecoration(
        border: Border(
          top: BorderSide(
            color: Color(0xFFEEEEEE),
            width: 1,
          ),
        ),
      ),
      child: Center(
        child: Container(
          constraints: const BoxConstraints(maxWidth: 340),
          padding: const EdgeInsets.symmetric(horizontal: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Row(
                children: [
                  const Text(
                    'ⓒ falsy',
                    style: TextStyle(
                      color: AppTheme.gray400,
                      fontSize: 12,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                  const SizedBox(width: 4),
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 6),
                    child: Text(
                      '|',
                      style: TextStyle(
                        color: AppTheme.gray200,
                        fontSize: 8,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  ),

                  GestureDetector(
                    onTap: () => _launchPrivacyPolicy(context),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          vertical: 8, horizontal: 4),
                      child: const Text(
                        'Privacy Policy',
                        style: TextStyle(
                          color: AppTheme.gray400,
                          fontSize: 12,
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                    ),
                  ),

                  // Separator
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 6),
                    child: Text(
                      '|',
                      style: TextStyle(
                        color: AppTheme.gray200,
                        fontSize: 8,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  ),

                  GestureDetector(
                    onTap: () => _launchTermsOfService(context),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          vertical: 8, horizontal: 4),
                      child: const Text(
                        'Terms of Service',
                        style: TextStyle(
                          color: AppTheme.gray400,
                          fontSize: 12,
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
