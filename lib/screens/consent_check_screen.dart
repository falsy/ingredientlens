import 'package:flutter/material.dart';
import '../services/consent_service.dart';
import 'home_screen.dart';
import 'consent_required_screen.dart';

class ConsentCheckScreen extends StatefulWidget {
  const ConsentCheckScreen({super.key});

  @override
  State<ConsentCheckScreen> createState() => _ConsentCheckScreenState();
}

class _ConsentCheckScreenState extends State<ConsentCheckScreen> {
  @override
  void initState() {
    super.initState();
    _checkConsentStatus();
  }

  void _checkConsentStatus() async {
    // 서비스 이용 가능한지 확인
    final canUseService = await ConsentService().canUseService();
    
    if (mounted) {
      if (canUseService) {
        // 동의가 필요없거나 이미 동의한 경우 홈 화면으로
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => const HomeScreen()),
        );
      } else {
        // 동의가 필요한 경우 동의 화면으로
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => const ConsentRequiredScreen()),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // 로딩 화면
    return const Scaffold(
      body: Center(
        child: CircularProgressIndicator(),
      ),
    );
  }
}