import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'home_screen.dart';
import 'register_screen.dart';
import 'forgot_password_screen.dart';
import 'campaign_level_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _isObscured = true;

  Future<void> _loginReal() async {
    String email = _emailController.text;
    String password = _passwordController.text;

    if (email.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Isi dulu email sama passwordnya!')),
      );
      return;
    }

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(child: CircularProgressIndicator()),
    );

    try {
      var url = Uri.parse('https://hafizlab.my.id/api/login.php');
      var response = await http.post(url, body: {"email": email, "password": password});

      if (mounted) Navigator.pop(context);

      if (response.statusCode == 200) {
        try {
          var data = json.decode(response.body);
          if (data['status'] == 'success') {
            SharedPreferences prefs = await SharedPreferences.getInstance();
            await prefs.setString('id_user', data['data']['id_user'].toString());
            await prefs.setString('nama_user', data['data']['nama']);

            if (data['data']['avatar'] != null) {
              await prefs.setString('avatar_user', data['data']['avatar']);
            }

            try {
              var syncUrl = Uri.parse('https://hafizlab.my.id/api/sync_user_data.php');
              var syncResponse = await http.post(syncUrl, body: {"id_user": data['data']['id_user'].toString()});

              if (syncResponse.statusCode == 200) {
                var syncData = json.decode(syncResponse.body);
                if (syncData['status'] == 'success') {

                  var userData = syncData['user_data'];
                  if (userData != null) {
                    if (userData['avatar'] != null && userData['avatar'].toString().isNotEmpty) {
                      await prefs.setString('avatar_user', userData['avatar']);
                    }
                    await prefs.setInt('highscore_tebak_surah', int.tryParse(userData['highscore_tebak_surah'].toString()) ?? 0);
                    await prefs.setInt('highscore_tebak_ayat', int.tryParse(userData['highscore_tebak_ayat'].toString()) ?? 0);
                  }

                  List<dynamic> progressList = syncData['progress'] ?? [];
                  List<String> completedLevels = [];

                  List<String> validTitles = [
                    ...CampaignLevelScreen.levelsMudah.map((e) => e['judul'].toString()),
                    ...CampaignLevelScreen.levelsMedium.map((e) => e['judul'].toString()),
                    ...CampaignLevelScreen.levelsSulit.map((e) => e['judul'].toString()),
                  ];

                  for (var p in progressList) {
                    String dbLevelName = p['nama_level'].toString();
                    int skor = int.tryParse(p['skor'].toString()) ?? 0;

                    int starsEarned = 0;
                    if (skor >= 100 || skor == 3) starsEarned = 3;
                    else if (skor >= 60 || skor == 2) starsEarned = 2;
                    else if (skor > 0 || skor == 1) starsEarned = 1;

                    if (starsEarned > 0) {
                      String matchedTitle = dbLevelName;
                      String cleanDb = dbLevelName.replaceAll(RegExp(r'[^a-zA-Z0-9]'), '').toLowerCase();

                      for (String valid in validTitles) {
                        String cleanValid = valid.replaceAll(RegExp(r'[^a-zA-Z0-9]'), '').toLowerCase();
                        if (cleanDb.isNotEmpty && (cleanDb == cleanValid || cleanValid.contains(cleanDb) || cleanDb.contains(cleanValid))) {
                          matchedTitle = valid;
                          break;
                        }
                      }

                      if (!completedLevels.contains(matchedTitle)) {
                        completedLevels.add(matchedTitle);
                      }
                      await prefs.setInt('stars_$matchedTitle', starsEarned);
                    }
                  }
                  await prefs.setStringList('completed_levels', completedLevels);
                }
              }
            } catch (e) {}

            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(data['message']), backgroundColor: Colors.green),
              );
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => const HomeScreen()),
              );
            }
          } else {
            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(data['message']), backgroundColor: Colors.red),
              );
            }
          }
        } catch (e) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Error response dari server!')),
            );
          }
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Server Error!')),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Gagal nyambung ke server: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    bool isDarkMode = Theme.of(context).brightness == Brightness.dark;
    Color cardColor = isDarkMode ? const Color(0xFF11325A).withOpacity(0.95) : Colors.white.withOpacity(0.95);
    Color textColor = isDarkMode ? Colors.white : Colors.black87;
    Color hintColor = isDarkMode ? Colors.white54 : Colors.grey;
    Color borderColor = isDarkMode ? Colors.white24 : Colors.grey.shade400;

    return Scaffold(
      resizeToAvoidBottomInset: true,
      backgroundColor: Colors.transparent,
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/images/splash.jpeg'),
            fit: BoxFit.cover,
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              Expanded(
                flex: 4,
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const SizedBox(height: 20),
                      Image.asset('assets/images/hafizlab_text.png', height: 60),
                      const SizedBox(height: 10),
                      const Text(
                        'Selamat Datang!',
                        style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600, color: Colors.amber),
                      ),
                      const SizedBox(height: 15),
                      Image.asset('assets/images/hafiz_standing.png', height: 240),
                    ],
                  ),
                ),
              ),
              Expanded(
                flex: 5,
                child: Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: cardColor,
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(30),
                      topRight: Radius.circular(30),
                    ),
                  ),
                  child: SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        TextField(
                          controller: _emailController,
                          style: TextStyle(color: textColor),
                          decoration: InputDecoration(
                            prefixIcon: Icon(Icons.email_outlined, color: hintColor),
                            hintText: 'Email Terdaftar',
                            hintStyle: TextStyle(color: hintColor),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(15),
                              borderSide: BorderSide(color: borderColor),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(15),
                              borderSide: const BorderSide(color: Colors.amber, width: 2),
                            ),
                          ),
                        ),
                        const SizedBox(height: 15),
                        TextField(
                          controller: _passwordController,
                          obscureText: _isObscured,
                          style: TextStyle(color: textColor),
                          decoration: InputDecoration(
                            prefixIcon: Icon(Icons.lock_outline, color: hintColor),
                            suffixIcon: IconButton(
                              icon: Icon(
                                _isObscured ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                                color: hintColor,
                              ),
                              onPressed: () {
                                setState(() {
                                  _isObscured = !_isObscured;
                                });
                              },
                            ),
                            hintText: 'Kata Sandi',
                            hintStyle: TextStyle(color: hintColor),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(15),
                              borderSide: BorderSide(color: borderColor),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(15),
                              borderSide: const BorderSide(color: Colors.amber, width: 2),
                            ),
                          ),
                        ),
                        Align(
                          alignment: Alignment.centerRight,
                          child: TextButton(
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(builder: (context) => const ForgotPasswordScreen()),
                              );
                            },
                            child: Text('Lupa Kata Sandi?', style: TextStyle(color: hintColor)),
                          ),
                        ),
                        ElevatedButton(
                          onPressed: _loginReal,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.green,
                            padding: const EdgeInsets.symmetric(vertical: 15),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                          ),
                          child: const Text(
                            'Masuk',
                            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
                          ),
                        ),
                        const SizedBox(height: 30),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text('Belum punya akun? ', style: TextStyle(color: textColor)),
                            GestureDetector(
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(builder: (context) => const RegisterScreen()),
                                );
                              },
                              child: const Text(
                                'Daftar di sini',
                                style: TextStyle(fontWeight: FontWeight.bold, color: Colors.green),
                              ),
                            ),
                          ],
                        )
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}