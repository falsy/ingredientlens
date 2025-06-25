import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/foundation.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import 'dart:io';
import '../utils/theme.dart';
import '../services/localization_service.dart';
import 'custom_camera_screen.dart';
import 'image_crop_screen.dart';

class ImageSourceScreen extends StatefulWidget {
  final String category;
  final bool isCompareMode;
  final Function(File)? onImageSelected;

  const ImageSourceScreen({
    super.key,
    required this.category,
    this.isCompareMode = false,
    this.onImageSelected,
  });

  @override
  State<ImageSourceScreen> createState() => _ImageSourceScreenState();
}

class _ImageSourceScreenState extends State<ImageSourceScreen> {
  final ImagePicker _picker = ImagePicker();
  File? _selectedImage;
  bool _isLoading = false;

  Future<void> _requestCameraPermission() async {
    try {
      // iOS 시뮬레이터에서는 카메라가 없으므로 직접 카메라 사용을 시도
      if (kDebugMode) print('Attempting to open camera...');
      _openCustomCamera();
    } catch (e) {
      if (kDebugMode) print('Error opening camera: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Camera error: $e'),
          backgroundColor: AppTheme.negativeColor,
        ),
      );
    }
  }

  void _showPermissionDialog() {
    // 다이얼로그 표시 전에 상태바와 네비게이션 바를 검정으로 변경
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Colors.black,
        statusBarIconBrightness: Brightness.light,
        statusBarBrightness: Brightness.dark,
        systemNavigationBarColor: Colors.black,
        systemNavigationBarIconBrightness: Brightness.light,
      ),
    );

    showDialog(
      context: context,
      barrierDismissible: false,
      barrierColor: Colors.black.withOpacity(0.8),
      builder: (BuildContext context) {
        return WillPopScope(
          onWillPop: () async {
            // 다이얼로그가 닫힐 때 원래 색상으로 복원
            SystemChrome.setSystemUIOverlayStyle(
              const SystemUiOverlayStyle(
                statusBarColor: AppTheme.backgroundColor,
                statusBarIconBrightness: Brightness.dark,
                statusBarBrightness: Brightness.light,
                systemNavigationBarColor: AppTheme.backgroundColor,
                systemNavigationBarIconBrightness: Brightness.dark,
              ),
            );
            return true;
          },
          child: AlertDialog(
            title: Text(AppLocalizations.of(context)!.translate('camera')),
            content: Text(AppLocalizations.of(context)!
                .translate('camera_permission_needed')),
            actions: [
              TextButton(
                onPressed: () {
                  // 원래 색상으로 복원 후 다이얼로그 닫기
                  SystemChrome.setSystemUIOverlayStyle(
                    const SystemUiOverlayStyle(
                      statusBarColor: AppTheme.backgroundColor,
                      statusBarIconBrightness: Brightness.dark,
                      statusBarBrightness: Brightness.light,
                      systemNavigationBarColor: AppTheme.backgroundColor,
                      systemNavigationBarIconBrightness: Brightness.dark,
                    ),
                  );
                  Navigator.pop(context);
                },
                child: Text(AppLocalizations.of(context)!.translate('cancel')),
              ),
              TextButton(
                onPressed: () {
                  // 원래 색상으로 복원 후 다이얼로그 닫기
                  SystemChrome.setSystemUIOverlayStyle(
                    const SystemUiOverlayStyle(
                      statusBarColor: AppTheme.backgroundColor,
                      statusBarIconBrightness: Brightness.dark,
                      statusBarBrightness: Brightness.light,
                      systemNavigationBarColor: AppTheme.backgroundColor,
                      systemNavigationBarIconBrightness: Brightness.dark,
                    ),
                  );
                  Navigator.pop(context);
                  openAppSettings();
                },
                child:
                    Text(AppLocalizations.of(context)!.translate('settings')),
              ),
            ],
          ),
        );
      },
    );
  }

  void _openCustomCamera() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => CustomCameraScreen(
          category: widget.category,
          isCompareMode: widget.isCompareMode,
          onImageSelected: widget.onImageSelected,
        ),
      ),
    );
  }

  Future<void> _takePhoto() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final XFile? photo = await _picker.pickImage(
        source: ImageSource.camera,
        maxWidth: 1920,
        maxHeight: 1920,
        imageQuality: 85,
      );

      if (photo != null) {
        setState(() {
          _selectedImage = File(photo.path);
        });

        // 사진을 촬영했다면 다음 단계로 진행
        _proceedToNextStep();
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(AppLocalizations.of(context)!
              .translate('photo_error', {'error': e.toString()})),
          backgroundColor: AppTheme.negativeColor,
        ),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _pickImageFromGallery() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1920,
        maxHeight: 1920,
        imageQuality: 85,
      );

      if (image != null) {
        // 갤러리에서 선택한 이미지를 크롭 화면으로 전달
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ImageCropScreen(
              imagePath: image.path,
              category: widget.category,
              isCompareMode: widget.isCompareMode,
              onImageSelected: widget.onImageSelected,
            ),
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(AppLocalizations.of(context)!
              .translate('photo_error', {'error': e.toString()})),
          backgroundColor: AppTheme.negativeColor,
        ),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _proceedToNextStep() {
    // 다이얼로그 표시 전에 상태바와 네비게이션 바를 검정으로 변경
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Colors.black,
        statusBarIconBrightness: Brightness.light,
        statusBarBrightness: Brightness.dark,
        systemNavigationBarColor: Colors.black,
        systemNavigationBarIconBrightness: Brightness.light,
      ),
    );

    // 임시로 간단한 결과 표시
    showDialog(
      context: context,
      barrierDismissible: false,
      barrierColor: Colors.black.withOpacity(0.8),
      builder: (BuildContext context) {
        return WillPopScope(
          onWillPop: () async {
            // 다이얼로그가 닫힐 때 원래 색상으로 복원
            SystemChrome.setSystemUIOverlayStyle(
              const SystemUiOverlayStyle(
                statusBarColor: AppTheme.backgroundColor,
                statusBarIconBrightness: Brightness.dark,
                statusBarBrightness: Brightness.light,
                systemNavigationBarColor: AppTheme.backgroundColor,
                systemNavigationBarIconBrightness: Brightness.dark,
              ),
            );
            return true;
          },
          child: AlertDialog(
            backgroundColor: AppTheme.backgroundColor,
            title: Text(
              AppLocalizations.of(context)!.translate('photo_taken'),
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: AppTheme.primaryGreen,
              ),
              textAlign: TextAlign.center,
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (_selectedImage != null)
                  ConstrainedBox(
                    constraints: const BoxConstraints(
                      maxHeight: 200,
                    ),
                    child: Container(
                      decoration: BoxDecoration(
                        border: Border.all(color: AppTheme.gray300),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: Image.file(
                          _selectedImage!,
                          fit: BoxFit.contain,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () {
                  // 원래 색상으로 복원 후 다이얼로그 닫기
                  SystemChrome.setSystemUIOverlayStyle(
                    const SystemUiOverlayStyle(
                      statusBarColor: AppTheme.backgroundColor,
                      statusBarIconBrightness: Brightness.dark,
                      statusBarBrightness: Brightness.light,
                      systemNavigationBarColor: AppTheme.backgroundColor,
                      systemNavigationBarIconBrightness: Brightness.dark,
                    ),
                  );
                  Navigator.pop(context); // 다이얼로그 닫기
                },
                child: Text(
                  AppLocalizations.of(context)!.translate('cancel'),
                  style: TextStyle(
                    color: AppTheme.gray500,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              ElevatedButton(
                onPressed: () {
                  // 원래 색상으로 복원 후 다이얼로그 닫기
                  SystemChrome.setSystemUIOverlayStyle(
                    const SystemUiOverlayStyle(
                      statusBarColor: AppTheme.backgroundColor,
                      statusBarIconBrightness: Brightness.dark,
                      statusBarBrightness: Brightness.light,
                      systemNavigationBarColor: AppTheme.backgroundColor,
                      systemNavigationBarIconBrightness: Brightness.dark,
                    ),
                  );
                  Navigator.pop(context); // 다이얼로그 닫기
                  Navigator.pop(context); // 이미지 소스 화면 닫기
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primaryGreen,
                  foregroundColor: AppTheme.whiteColor,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: Text(
                  AppLocalizations.of(context)!.translate('confirm'),
                  style: TextStyle(
                    fontWeight: FontWeight.w300,
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    // 이미지 소스 선택 화면에서 상태바와 네비게이션 바 색상 설정
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: AppTheme.backgroundColor,
        statusBarIconBrightness: Brightness.dark,
        statusBarBrightness: Brightness.light,
        systemNavigationBarColor: AppTheme.backgroundColor,
        systemNavigationBarIconBrightness: Brightness.dark,
      ),
    );

    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppBar(
        title: Text(
          AppLocalizations.of(context)!
              .translate('ingredient_photography')
              .toUpperCase(),
          style: TextStyle(
            color: AppTheme.primaryGreen,
            fontSize: 18,
            fontWeight: FontWeight.w800,
            letterSpacing: 0.4,
          ),
        ),
        backgroundColor: AppTheme.backgroundColor,
        elevation: 0,
        centerTitle: false,
        systemOverlayStyle: const SystemUiOverlayStyle(
          statusBarColor: AppTheme.backgroundColor,
          statusBarIconBrightness: Brightness.dark,
          statusBarBrightness: Brightness.light,
          systemNavigationBarColor: AppTheme.backgroundColor,
          systemNavigationBarIconBrightness: Brightness.dark,
        ),
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: AppTheme.primaryGreen, size: 24),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: SafeArea(
              child: Center(
                child: Container(
                  constraints: const BoxConstraints(maxWidth: 380),
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        AppLocalizations.of(context)!.translate(
                            'take_photo_of_ingredients', {
                          'category': AppLocalizations.of(context)!
                              .translate(widget.category)
                        }),
                        style: TextStyle(
                          color: AppTheme.primaryGreen,
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 36),

                      // 버튼들
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            // 갤러리 버튼 (왼쪽으로 이동)
                            Expanded(
                              child: AspectRatio(
                                aspectRatio: 1,
                                child: InkWell(
                                  onTap:
                                      _isLoading ? null : _pickImageFromGallery,
                                  borderRadius: BorderRadius.circular(20),
                                  child: Container(
                                    decoration: BoxDecoration(
                                      color: AppTheme.whiteColor,
                                      border: Border.all(
                                        color: AppTheme.primaryGreen,
                                        width: 2,
                                      ),
                                      borderRadius: BorderRadius.circular(20),
                                      boxShadow: [
                                        BoxShadow(
                                          color: AppTheme.cardShadow
                                              .withOpacity(0.08),
                                          blurRadius: 15,
                                          offset: const Offset(0, 5),
                                        ),
                                      ],
                                    ),
                                    child: Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        if (_isLoading)
                                          const CircularProgressIndicator(
                                            color: AppTheme.primaryGreen,
                                          )
                                        else
                                          const Icon(
                                            Icons.photo_library,
                                            size: 40,
                                            color: AppTheme.primaryGreen,
                                          ),
                                        const SizedBox(height: 8),
                                        Text(
                                          _isLoading
                                              ? AppLocalizations.of(context)!
                                                  .translate('loading')
                                              : AppLocalizations.of(context)!
                                                  .translate('gallery'),
                                          style: TextStyle(
                                            color: AppTheme.primaryGreen,
                                            fontSize: 12,
                                            fontWeight: FontWeight.w600,
                                          ),
                                          textAlign: TextAlign.center,
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 20),
                            // 카메라 버튼 (오른쪽으로 이동)
                            Expanded(
                              child: AspectRatio(
                                aspectRatio: 1,
                                child: InkWell(
                                  onTap: _isLoading
                                      ? null
                                      : () async {
                                          if (kDebugMode) print('Camera button tapped');
                                          await _requestCameraPermission();
                                        },
                                  borderRadius: BorderRadius.circular(20),
                                  child: Container(
                                    decoration: BoxDecoration(
                                      color: AppTheme.whiteColor,
                                      border: Border.all(
                                        color: AppTheme.primaryGreen,
                                        width: 2,
                                      ),
                                      borderRadius: BorderRadius.circular(20),
                                      boxShadow: [
                                        BoxShadow(
                                          color: AppTheme.cardShadow
                                              .withOpacity(0.08),
                                          blurRadius: 15,
                                          offset: const Offset(0, 5),
                                        ),
                                      ],
                                    ),
                                    child: Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        if (_isLoading)
                                          const CircularProgressIndicator(
                                            color: AppTheme.primaryGreen,
                                          )
                                        else
                                          const Icon(
                                            Icons.camera,
                                            size: 40,
                                            color: AppTheme.primaryGreen,
                                          ),
                                        const SizedBox(height: 8),
                                        Text(
                                          _isLoading
                                              ? AppLocalizations.of(context)!
                                                  .translate('taking_photo')
                                              : AppLocalizations.of(context)!
                                                  .translate('camera'),
                                          style: TextStyle(
                                            color: AppTheme.primaryGreen,
                                            fontSize: 14,
                                            fontWeight: FontWeight.w600,
                                          ),
                                          textAlign: TextAlign.center,
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          // 하단 안내 메시지
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            color: AppTheme.backgroundColor,
            child: Text(
              AppLocalizations.of(context)!.translate('ai_disclaimer'),
              style: TextStyle(
                fontSize: 12,
                color: AppTheme.gray700,
                height: 1.5,
              ),
              textAlign: TextAlign.center,
            ),
          ),
          // 안드로이드 시스템 네비게이션 바 영역 고려
          SizedBox(height: MediaQuery.of(context).viewPadding.bottom),
        ],
      ),
    );
  }
}
