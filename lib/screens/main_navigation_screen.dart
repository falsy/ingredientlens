import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';
import '../widgets/bottom_navigation_widget.dart';
import 'home_screen.dart';
import 'nutrition_analysis_screen.dart';
import 'calorie_analysis_screen.dart';
import 'menu_screen.dart';

// 커스텀 ScrollPhysics - 수직 스크롤을 우선시하고 빠른 전환
class CustomPageScrollPhysics extends PageScrollPhysics {
  const CustomPageScrollPhysics({ScrollPhysics? parent})
      : super(parent: parent);

  @override
  CustomPageScrollPhysics applyTo(ScrollPhysics? ancestor) {
    return CustomPageScrollPhysics(parent: buildParent(ancestor));
  }
  
  @override
  SpringDescription get spring => const SpringDescription(
    mass: 0.2,      // 더 가벼운 질량으로 더 빠른 반응
    stiffness: 400,  // 더 높은 강성으로 더 빠른 스냅
    damping: 35,     // 적절한 감쇠로 바운스 없이
  );
  
  @override
  double get minFlingVelocity => 500.0; // 기본값은 50.0 - 더 강한 스와이프 필요
  
  @override
  double get dragStartDistanceMotionThreshold => 30.0; // 기본값은 3.5
}

class MainNavigationScreen extends StatefulWidget {
  const MainNavigationScreen({Key? key}) : super(key: key);

  @override
  State<MainNavigationScreen> createState() => _MainNavigationScreenState();
}

class _MainNavigationScreenState extends State<MainNavigationScreen> {
  int _currentIndex = 0;
  late PageController _pageController;
  
  // 각 화면의 ScrollController
  final List<ScrollController> _scrollControllers = [
    ScrollController(),
    ScrollController(),
    ScrollController(),
    ScrollController(),
  ];

  late final List<Widget> _screens;

  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: _currentIndex);
    
    // ScrollController를 각 화면에 전달
    _screens = [
      HomeScreen(scrollController: _scrollControllers[0]),
      NutritionAnalysisScreen(scrollController: _scrollControllers[1]),
      CalorieAnalysisScreen(scrollController: _scrollControllers[2]),
      MenuScreen(scrollController: _scrollControllers[3]),
    ];
  }
  
  @override
  void dispose() {
    _pageController.dispose();
    // ScrollController 정리
    for (var controller in _scrollControllers) {
      controller.dispose();
    }
    super.dispose();
  }

  void _onTabTapped(int index) {
    // 같은 탭을 다시 누른 경우 스크롤을 최상단으로
    if (_currentIndex == index) {
      _scrollControllers[index].animateTo(
        0,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    } else {
      // 다른 탭으로 이동하는 경우 PageView 애니메이션 사용
      _pageController.animateToPage(
        index,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOutQuart,
      );
      // 새로운 탭의 스크롤을 최상단으로
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (_scrollControllers[index].hasClients) {
          _scrollControllers[index].jumpTo(0);
        }
      });
    }
  }
  
  void _onPageChanged(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: PageView(
        controller: _pageController,
        onPageChanged: _onPageChanged,
        physics: const CustomPageScrollPhysics(),
        pageSnapping: true,
        children: _screens,
      ),
      bottomNavigationBar: BottomNavigationWidget(
        currentIndex: _currentIndex,
        onTap: _onTabTapped,
      ),
    );
  }
}
