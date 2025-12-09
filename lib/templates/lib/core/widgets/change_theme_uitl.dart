import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:{{project_name}}/app/theme/cubit/theme_cubit.dart';
import 'package:{{project_name}}/core/utils/responsive/responsive.dart';

class ChangeThemeUtil {
  ChangeThemeUtil._();

  static void showThemeChooser({
    required BuildContext context,
    required bool isMobile,
  }) {
    showCupertinoModalPopup(
      context: context,
      builder: (_) {
        return BlocBuilder<ThemeCubit, ThemeState>(
          builder: (context, state) {
            // Local temp selection (not applied yet)
            ThemeMode tempMode = state.mode;

            return SizedBox(
              width: isMobile ? 100.pw : 65.pw,
              child: StatefulBuilder(
                builder: (context, setState) {
                  return CupertinoActionSheet(
                    title: Padding(
                      padding: EdgeInsets.symmetric(vertical: 16.r),
                      child: const Text(
                        'Select Theme Mode',
                        style: TextStyle(fontWeight: FontWeight.w600),
                      ),
                    ),
                    message: Padding(
                      padding: EdgeInsets.only(bottom: 10.r),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          _themeOption(
                            context: context,
                            isMobile: isMobile,
                            title: "System",
                            icon: CupertinoIcons.settings,
                            isSelected: tempMode == ThemeMode.system,
                            onTap: () {
                              setState(() {
                                tempMode = ThemeMode.system;
                              });
                            },
                          ),
                          _themeOption(
                            context: context,
                            isMobile: isMobile,
                            title: "Light",
                            icon: FontAwesomeIcons.sun,
                            isSelected: tempMode == ThemeMode.light,
                            onTap: () {
                              setState(() {
                                tempMode = ThemeMode.light;
                              });
                            },
                          ),
                          _themeOption(
                            context: context,
                            isMobile: isMobile,
                            title: "Dark",
                            icon: FontAwesomeIcons.moon,
                            isSelected: tempMode == ThemeMode.dark,
                            onTap: () {
                              setState(() {
                                tempMode = ThemeMode.dark;
                              });
                            },
                          ),
                        ],
                      ),
                    ),
                    actions: [
                      CupertinoActionSheetAction(
                        onPressed: () {
                          context.read<ThemeCubit>().changeMode(tempMode);
                          Navigator.pop(context);
                        },
                        isDefaultAction: true,
                        child: const Text('Change Theme'),
                      ),
                    ],
                    cancelButton: CupertinoActionSheetAction(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('Cancel'),
                    ),
                  );
                },
              ),
            );
          },
        );
      },
    );
  }

  static Widget _themeOption({
    required BuildContext context,
    required bool isMobile,
    required String title,
    required IconData icon,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            padding: EdgeInsets.all(16.r),
            decoration: BoxDecoration(
              color: isSelected
                  ? Theme.of(context).colorScheme.primary
                  : Theme.of(context).colorScheme.tertiary.withAlpha(40),
              borderRadius: BorderRadius.circular((isMobile ? 12 : 8).r),
              border: Border.all(
                width: isMobile ? 0.5.r : 0.3.r,
                color: Theme.of(context).colorScheme.primary.withAlpha(120),
              ),
            ),
            child: Icon(
              icon,
              size: 20.sp,
              color: isSelected ? Colors.white : null,
            ),
          ),
          SizedBox(height: 6.r),
          Text(
            title,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color:
                      isSelected ? Theme.of(context).colorScheme.primary : null,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                ),
          ),
        ],
      ),
    );
  }
}
