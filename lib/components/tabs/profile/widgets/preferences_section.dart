import 'package:flutter/material.dart';
import '../../../../utils/localization.dart';
import '../../../../utils/user_data.dart';
import '../../../../utils/theme_manager.dart';

class PreferencesSection extends StatelessWidget {
  final String selectedLanguage;
  final Function(String) onLanguageChanged;
  final bool isDark;

  const PreferencesSection({
    super.key,
    required this.selectedLanguage,
    required this.onLanguageChanged,
    required this.isDark,
  });

  Widget _buildSectionTitle(String title, {required BuildContext context}) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 10),
      child: Align(
        alignment: Alignment.centerLeft,
        child: Text(
          title,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.bold,
            color: Colors.grey.shade500,
          ),
        ),
      ),
    );
  }

  Widget _buildSettingsCard(BuildContext context, List<Widget> children) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 25),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(children: children),
    );
  }

  Widget _buildLanguageDropdown(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      child: Row(
        children: [
          Icon(Icons.translate, size: 22, color: Colors.blueGrey.shade400),
          const SizedBox(width: 15),
          Expanded(
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                value: selectedLanguage,
                isExpanded: true,
                items: ["Khmer", "English", "Chinese", "Vietnamese"]
                    .map(
                      (lang) =>
                          DropdownMenuItem(value: lang, child: Text(lang)),
                    )
                    .toList(),
                onChanged: (value) {
                  if (value != null) {
                    onLanguageChanged(value);
                    UserData.saveLanguage(value);
                  }
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _buildSectionTitle(
          Localization.text(selectedLanguage, 'preferences'),
          context: context,
        ),
        _buildSettingsCard(context, [
          _buildLanguageDropdown(context),
          const Divider(height: 1),
          SwitchListTile.adaptive(
            secondary: Icon(
              Icons.dark_mode_outlined,
              color: Colors.blueGrey.shade400,
            ),
            title: Text(
              Localization.text(selectedLanguage, 'Dark Mode'),
              style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
            ),
            value: isDark,
            activeColor: Colors.tealAccent,
            onChanged: (bool value) => ThemeManager.toggleTheme(value),
          ),
        ]),
      ],
    );
  }
}
