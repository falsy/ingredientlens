import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../l10n/app_localizations.dart';
import '../utils/theme.dart';

class HomeFooterWidget extends StatelessWidget {
  const HomeFooterWidget({super.key});

  Future<void> _launchPrivacyPolicy(BuildContext context) async {
    final Uri url = Uri.parse('https://falsy.me/ingredientlens/privacy.html');
    if (!await launchUrl(url, mode: LaunchMode.externalApplication)) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).clearSnackBars();
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
        ScaffoldMessenger.of(context).clearSnackBars();
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
    return Column(
      children: [
        Container(
          width: double.infinity,
          padding:
              const EdgeInsets.only(top: 21, bottom: 38, left: 20, right: 20),
          decoration: BoxDecoration(
            border: Border(
              top: BorderSide(
                color: AppTheme.cardBorderColor.withOpacity(0.2),
                width: 1,
              ),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  GestureDetector(
                    onTap: () => _launchPrivacyPolicy(context),
                    child: Text(
                      AppLocalizations.of(context)!.privacy_policy,
                      style: const TextStyle(
                        color: Color.fromARGB(200, 0, 0, 0),
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  const SizedBox(width: 6),
                  const Text(
                    ' | ',
                    style: TextStyle(
                      color: AppTheme.gray400,
                      fontSize: 10,
                      fontWeight: FontWeight.w300,
                    ),
                  ),
                  const SizedBox(width: 6),
                  GestureDetector(
                    onTap: () => _launchTermsOfService(context),
                    child: Text(
                      AppLocalizations.of(context)!.terms_of_service,
                      style: const TextStyle(
                        color: Color.fromARGB(160, 0, 0, 0),
                        fontSize: 14,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }
}
