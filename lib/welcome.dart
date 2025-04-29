import 'dart:io';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mediconnect/provider/local_provider.dart';
import 'package:mediconnect/provider/theme_provider.dart';
import 'package:provider/provider.dart';

class WelcomPage extends StatefulWidget {
  const WelcomPage({super.key});

  @override
  State<WelcomPage> createState() => _ClientProfilPageState();
}

class _ClientProfilPageState extends State<WelcomPage> {
  final ImagePicker _picker = ImagePicker();
  User? user;
  File? userImage;
  String? photoUrl;
  String displayName = 'Utilisateur';
  String email = '';
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final localeProvider = Provider.of<LocaleProvider>(context);
    final themeProvider = Provider.of<ThemeProvider>(context);
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: AppBar(
        title: Text(localeProvider.getTranslation('Profil')),
        actions: [
          IconButton(
            icon: Icon(
              isDarkMode ? Icons.light_mode : Icons.dark_mode,
              color: isDarkMode ? Colors.amber : Colors.indigo,
            ),
            onPressed: () => themeProvider.toggleTheme(context),
          ),
        ],
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              localeProvider.getTranslation("Bienvenu"),
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 100,),
            _buildOptionsList(context),
          ],
        ),
      ),
    );
  }

  Widget _buildOptionsList(BuildContext context) {
    final localeProvider = Provider.of<LocaleProvider>(context);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        children: [
          _buildOptionTile(
            context: context,
            icon: Iconsax.language_square,
            label: localeProvider.getTranslation("Langue"),
            iconColor: Colors.green,
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  localeProvider.getLanguageName(
                    localeProvider.locale.languageCode,
                  ),
                  style: TextStyle(color: Colors.grey.shade600, fontSize: 16),
                ),
                const SizedBox(width: 8),
                const Icon(Icons.arrow_forward_ios, size: 16),
              ],
            ),
            onTap: () => _showLanguageDialog(context),
          ),
        ],
      ),
    );
  }

  void _showLanguageDialog(BuildContext context) {
    final localeProvider = Provider.of<LocaleProvider>(context, listen: false);

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(localeProvider.getTranslation('Choisir une langue')),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildLanguageOption(context, 'fr', 'Français'),
              _buildLanguageOption(context, 'en', 'English'),
              _buildLanguageOption(context, 'es', 'Spanish'),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(localeProvider.getTranslation('Annuler')),
            ),
          ],
        );
      },
    );
  }

  Widget _buildLanguageOption(
    BuildContext context,
    String languageCode,
    String languageName,
  ) {
    final localeProvider = Provider.of<LocaleProvider>(context);
    final isSelected = localeProvider.locale.languageCode == languageCode;

    return ListTile(
      title: Text(languageName),
      trailing:
          isSelected
              ? Icon(Icons.check, color: Theme.of(context).colorScheme.primary)
              : null,
      onTap: () {
        localeProvider.setLocale(Locale(languageCode));
        Navigator.pop(context);
      },
    );
  }

  Widget _buildOptionTile({
    required BuildContext context,
    required IconData icon,
    required String label,
    required Color iconColor,
    required VoidCallback onTap,
    Widget? trailing,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Container(
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.primary,
          borderRadius: BorderRadius.circular(12),
        ),
        child: ListTile(
          leading: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: iconColor.withOpacity(0.2),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: iconColor, size: 24),
          ),
          title: Text(
            label,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
          ),
          trailing: trailing ?? const Icon(Icons.arrow_forward_ios, size: 16),
          onTap: onTap,
        ),
      ),
    );
  }
}
