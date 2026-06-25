import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'login_screen.dart';
import 'forgot_password_screen.dart';
import 'about_app_screen.dart';
import 'privacy_policy_screen.dart';
import 'edit_profile_screen.dart';
import '../main.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    bool isDarkMode = Theme.of(context).brightness == Brightness.dark;
    Color textColor = isDarkMode ? Colors.white : Colors.black87;
    Color bgColor = isDarkMode ? const Color(0xFF0A2647) : Colors.white;
    Color headerColor = const Color(0xFF1B5E20);

    return Scaffold(
      backgroundColor: headerColor,
      appBar: AppBar(
        title: const Text('Pengaturan', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        backgroundColor: headerColor,
        elevation: 0,
        centerTitle: true,
        automaticallyImplyLeading: false,
      ),
      body: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: const BorderRadius.only(topLeft: Radius.circular(30), topRight: Radius.circular(30)),
        ),
        child: ListView(
          padding: const EdgeInsets.all(25),
          children: [
            const Text("Akun", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            const SizedBox(height: 10),
            _buildListTile(
              'Profil Saya',
              'assets/icons/profil.png',
              textColor,
              trailing: const Icon(Icons.chevron_right, color: Colors.grey),
              onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const EditProfileScreen())),
            ),
            _buildListTile(
              'Ubah Kata Sandi',
              'assets/icons/password.png',
              textColor,
              trailing: const Icon(Icons.chevron_right, color: Colors.grey),
              onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const ForgotPasswordScreen())),
            ),
            const SizedBox(height: 25),
            const Text("Pengaturan", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            const SizedBox(height: 10),
            ValueListenableBuilder<bool>(
              valueListenable: sfxNotifier,
              builder: (context, isSfxOn, child) {
                return _buildListTile(
                  'Suara',
                  isSfxOn ? 'assets/icons/volume_on.png' : 'assets/icons/volume_off.png',
                  textColor,
                  trailing: Switch(
                    value: isSfxOn,
                    activeColor: Colors.green,
                    onChanged: (val) async {
                      sfxNotifier.value = val;
                      SharedPreferences prefs = await SharedPreferences.getInstance();
                      await prefs.setBool('sfx_on', val);
                    },
                  ),
                );
              },
            ),
            ValueListenableBuilder<bool>(
              valueListenable: bgmNotifier,
              builder: (context, isBgmOn, child) {
                return _buildListTile(
                  'Musik',
                  isBgmOn ? 'assets/icons/music_on.png' : 'assets/icons/music_off.png',
                  textColor,
                  trailing: Switch(
                    value: isBgmOn,
                    activeColor: Colors.green,
                    onChanged: (val) async {
                      bgmNotifier.value = val;
                      SharedPreferences prefs = await SharedPreferences.getInstance();
                      await prefs.setBool('bgm_on', val);
                    },
                  ),
                );
              },
            ),
            _buildListTile(
              'Bahasa',
              'assets/icons/language.png',
              textColor,
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text('Indonesia', style: TextStyle(color: Colors.grey.shade600, fontSize: 13)),
                  const SizedBox(width: 5),
                  const Icon(Icons.chevron_right, color: Colors.grey),
                ],
              ),
              onTap: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Saat ini hanya mendukung Bahasa Indonesia! 🇮🇩')),
                );
              },
            ),
            _buildListTile(
              'Tentang Aplikasi',
              'assets/icons/about.png',
              textColor,
              trailing: const Icon(Icons.chevron_right, color: Colors.grey),
              onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const AboutAppScreen())),
            ),
            _buildListTile(
              'Kebijakan Privasi',
              'assets/icons/privacy_policy.png',
              textColor,
              trailing: const Icon(Icons.chevron_right, color: Colors.grey),
              onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const PrivacyPolicyScreen())),
            ),
            _buildListTile(
              'Bantuan',
              'assets/icons/help.png',
              textColor,
              trailing: const Icon(Icons.chevron_right, color: Colors.grey),
              onTap: () => ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Hubungi admin: haidarkadafi78@gmail.com')),
              ),
            ),
            const SizedBox(height: 40),
            OutlinedButton(
              onPressed: () async {
                SharedPreferences prefs = await SharedPreferences.getInstance();

                await prefs.remove('id_user');
                await prefs.remove('nama_user');
                await prefs.remove('avatar_user');
                await prefs.remove('completed_levels');
                await prefs.remove('highscore_tebak_surah');
                await prefs.remove('highscore_tebak_ayat');

                Set<String> keys = prefs.getKeys();
                for (String key in keys) {
                  if (key.startsWith('stars_')) {
                    await prefs.remove(key);
                  }
                }

                if (context.mounted) {
                  Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(builder: (context) => const LoginScreen()),
                    (Route<dynamic> route) => false,
                  );
                }
              },
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 15),
                side: BorderSide(color: Colors.grey.shade300, width: 1.5),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                backgroundColor: isDarkMode ? const Color(0xFF11325A) : Colors.grey.shade50,
              ),
              child: const Text('Keluar', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.red)),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildListTile(String title, String iconPath, Color textColor, {Widget? trailing, VoidCallback? onTap}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: ListTile(
        contentPadding: EdgeInsets.zero,
        leading: Image.asset(iconPath, width: 28, height: 28),
        title: Text(title, style: TextStyle(color: textColor, fontWeight: FontWeight.w500, fontSize: 15)),
        trailing: trailing,
        onTap: onTap,
      ),
    );
  }
}