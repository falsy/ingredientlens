import 'package:flutter/material.dart';
// import 'package:ingredient_lens/l10n/app_localizations.dart';
import '../utils/theme.dart';

class TabHeaderWidget extends StatefulWidget {
  final String title;
  final bool showNotificationButton;

  const TabHeaderWidget({
    super.key,
    required this.title,
    this.showNotificationButton = true,
  });

  @override
  State<TabHeaderWidget> createState() => _TabHeaderWidgetState();
}

class _TabHeaderWidgetState extends State<TabHeaderWidget> {
  final LayerLink _layerLink = LayerLink();
  OverlayEntry? _overlayEntry;
  bool _isTooltipShowing = false;

  void _showNotificationTooltip() {
    // if (_isTooltipShowing) {
    //   _hideNotificationTooltip();
    //   return;
    // }

    // _overlayEntry = _createOverlayEntry();
    // Overlay.of(context).insert(_overlayEntry!);
    // setState(() {
    //   _isTooltipShowing = true;
    // });
  }

  void _hideNotificationTooltip() {
    if (_overlayEntry != null) {
      _overlayEntry!.remove();
      _overlayEntry = null;
      setState(() {
        _isTooltipShowing = false;
      });
    }
  }

  // OverlayEntry _createOverlayEntry() {
  //   final renderBox = context.findRenderObject() as RenderBox;
  //   final size = renderBox.size;
  //   final offset = renderBox.localToGlobal(Offset.zero);

  //   return OverlayEntry(
  //     builder: (context) => Positioned(
  //       top: offset.dy + size.height + 8,
  //       right: 16,
  //       child: Material(
  //         elevation: 8,
  //         borderRadius: BorderRadius.circular(12),
  //         child: Container(
  //           width: 200,
  //           padding: const EdgeInsets.all(16),
  //           decoration: BoxDecoration(
  //             color: AppTheme.backgroundColor,
  //             borderRadius: BorderRadius.circular(12),
  //             border: Border.all(
  //               color: AppTheme.gray300,
  //               width: 1,
  //             ),
  //           ),
  //           child: Column(
  //             mainAxisSize: MainAxisSize.min,
  //             children: [
  //               Text(
  //                 AppLocalizations.of(context)!.no_notifications,
  //                 style: const TextStyle(
  //                   fontSize: 13,
  //                   color: AppTheme.gray600,
  //                 ),
  //                 textAlign: TextAlign.center,
  //               ),
  //             ],
  //           ),
  //         ),
  //       ),
  //     ),
  //   );
  // }

  @override
  void dispose() {
    _hideNotificationTooltip();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 60,
      padding: const EdgeInsets.symmetric(horizontal: 20),
      decoration: const BoxDecoration(
        color: AppTheme.backgroundColor,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            widget.title,
            style: const TextStyle(
              fontSize: AppTheme.appBarTitleFontSize,
              fontWeight: AppTheme.appBarTitleFontWeight,
              color: AppTheme.blackColor,
            ),
          ),
          if (widget.showNotificationButton)
            CompositedTransformTarget(
              link: _layerLink,
              child: GestureDetector(
                onTap: _showNotificationTooltip,
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: _isTooltipShowing
                        ? AppTheme.gray100
                        : Colors.transparent,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: ColorFiltered(
                    colorFilter: ColorFilter.mode(
                      _isTooltipShowing
                          ? AppTheme.primaryColor
                          : const Color.fromARGB(160, 0, 0, 0),
                      BlendMode.srcIn,
                    ),
                    child: Image.asset(
                      'assets/images/icons/bell.webp',
                      width: 20,
                      height: 20,
                      fit: BoxFit.contain,
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
