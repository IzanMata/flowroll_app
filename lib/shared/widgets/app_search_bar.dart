import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_strings.dart';
import '../../core/theme/app_text_styles.dart';

class AppSearchBar extends StatefulWidget {
  const AppSearchBar({
    super.key,
    this.onChanged,
    this.hintText = AppStrings.search,
    this.controller,
  });

  final ValueChanged<String>? onChanged;
  final String hintText;
  final TextEditingController? controller;

  @override
  State<AppSearchBar> createState() => _AppSearchBarState();
}

class _AppSearchBarState extends State<AppSearchBar> {
  late final TextEditingController _controller;
  bool _hasText = false;
  bool _isFocused = false;

  @override
  void initState() {
    super.initState();
    _controller = widget.controller ?? TextEditingController();
    _controller.addListener(_onTextChanged);
  }

  void _onTextChanged() {
    final hasText = _controller.text.isNotEmpty;
    if (hasText != _hasText) setState(() => _hasText = hasText);
    widget.onChanged?.call(_controller.text);
  }

  @override
  void dispose() {
    if (widget.controller == null) _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final borderColor = _isFocused
        ? (isDark ? AppColors.primary : AppColors.primaryLight)
        : (isDark ? AppColors.surfaceBorder : AppColors.lightSurfaceBorder);
    final bgColor = isDark ? AppColors.surfaceVariant : AppColors.lightSurfaceVariant;

    return Focus(
      onFocusChange: (focused) => setState(() => _isFocused = focused),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        height: 48,
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: borderColor,
            width: _isFocused ? 1.5 : 1,
          ),
        ),
        child: TextField(
          controller: _controller,
          style: AppTextStyles.bodyMedium(
            color: isDark ? AppColors.onSurface : AppColors.lightOnSurface,
          ),
          decoration: InputDecoration(
            hintText: widget.hintText,
            hintStyle: AppTextStyles.bodyMedium(color: AppColors.muted),
            prefixIcon: Icon(
              Icons.search_rounded,
              color: _isFocused
                  ? (isDark ? AppColors.primary : AppColors.primaryLight)
                  : AppColors.muted,
              size: 20,
            ),
            suffixIcon: _hasText
                ? IconButton(
                    icon: const Icon(Icons.close_rounded, size: 18),
                    color: AppColors.muted,
                    onPressed: () {
                      _controller.clear();
                      widget.onChanged?.call('');
                    },
                  )
                : null,
            border: InputBorder.none,
            enabledBorder: InputBorder.none,
            focusedBorder: InputBorder.none,
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            isDense: true,
          ),
        ),
      ),
    );
  }
}
