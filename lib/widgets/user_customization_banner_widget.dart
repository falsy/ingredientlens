import 'package:flutter/material.dart';
import '../utils/theme.dart';

class UserCustomizationBannerWidget extends StatelessWidget {
  final VoidCallback onTap;

  const UserCustomizationBannerWidget({
    super.key,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // 상단 구분선
        Container(
          width: double.infinity,
          height: 6,
          color: AppTheme.dividerColor,
        ),
        const SizedBox(height: 20),
        
        Container(
          margin: const EdgeInsets.symmetric(horizontal: 18),
          child: GestureDetector(
            onTap: onTap,
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: AppTheme.cardBoxShadow,
              ),
          child: Row(
            children: [
              // 프로필 아이콘
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: AppTheme.primaryColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Image.asset(
                    'assets/images/profile.webp',
                    width: 48,
                    height: 48,
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              const SizedBox(width: 16),
              
              // 텍스트 내용
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '사용자 정의',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: AppTheme.blackColor,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '사용자 정보를 추가하면 AI가 맞춤형 분석을 제공합니다.',
                      style: TextStyle(
                        fontSize: 13,
                        color: AppTheme.gray600,
                        fontWeight: FontWeight.w400,
                        height: 1.3,
                      ),
                    ),
                  ],
                ),
              ),
              
              // 화살표 아이콘
              Icon(
                Icons.chevron_right,
                color: AppTheme.gray600,
                size: 24,
              ),
            ],
          ),
        ),
      ),
    ),
    ],
    );
  }
}