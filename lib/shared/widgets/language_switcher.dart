import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/text_styles.dart';
import '../../core/constants/app_languages.dart';
import '../../features/profile/presentation/bloc/language_bloc.dart';

class LanguageSwitcher extends StatelessWidget {
  final bool showDropdown;

  const LanguageSwitcher({
    super.key,
    this.showDropdown = true,
  });

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<LanguageBloc, LanguageState>(
      builder: (context, state) {
        final currentCode =
            state is LanguageLoaded ? state.languageCode : AppLanguages.english;
        final currentLabel = AppLanguages.languageCodes[currentCode] ?? 'EN';

        if (!showDropdown) {
          // Simple text display (for header) - NOW WITH TAP HANDLER
          return GestureDetector(
            onTap: () => _showLanguageDialog(context),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                border: Border.all(color: AppColors.border),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.language,
                      size: 18, color: AppColors.textSecondary),
                  const SizedBox(width: 4),
                  Text(
                    currentLabel,
                    style: AppTextStyles.bodyMedium.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(width: 4),
                  const Icon(Icons.keyboard_arrow_down,
                      size: 14, color: AppColors.primary),
                ],
              ),
            ),
          );
        }

        // Dropdown for settings screen
        return DropdownButtonHideUnderline(
          child: DropdownButton<String>(
            value: currentCode,
            icon: const Icon(Icons.keyboard_arrow_down,
                size: 16, color: AppColors.primary),
            style: AppTextStyles.bodyMedium,
            items: AppLanguages.languageNames.entries.map((entry) {
              return DropdownMenuItem<String>(
                value: entry.key,
                child: Text(entry.value),
              );
            }).toList(),
            onChanged: (String? newValue) {
              if (newValue != null) {
                context.read<LanguageBloc>().add(
                      ChangeLanguageEvent(languageCode: newValue),
                    );
              }
            },
          ),
        );
      },
    );
  }

  // Show language selection dialog/bottom sheet
  void _showLanguageDialog(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Padding(
                padding: const EdgeInsets.all(16),
                child: Text(
                  'Select Language',
                  style: AppTextStyles.h3,
                ),
              ),
              const Divider(height: 1),
              ...AppLanguages.languageNames.entries.map((entry) {
                return ListTile(
                  leading: Radio<String>(
                    value: entry.key,
                    groupValue: BlocProvider.of<LanguageBloc>(context).state
                            is LanguageLoaded
                        ? (BlocProvider.of<LanguageBloc>(context).state
                                as LanguageLoaded)
                            .languageCode
                        : AppLanguages.english,
                    onChanged: (value) {
                      if (value != null) {
                        context.read<LanguageBloc>().add(
                              ChangeLanguageEvent(languageCode: value),
                            );
                        Navigator.pop(context);
                      }
                    },
                  ),
                  title: Text(entry.value),
                  trailing: entry.key == 'ar'
                      ? const Text('العربية',
                          style: TextStyle(fontFamily: 'Tajawal'))
                      : null,
                  onTap: () {
                    context.read<LanguageBloc>().add(
                          ChangeLanguageEvent(languageCode: entry.key),
                        );
                    Navigator.pop(context);
                  },
                );
              }),
              const SizedBox(height: 16),
            ],
          ),
        );
      },
    );
  }
}
