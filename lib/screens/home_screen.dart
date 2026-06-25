import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:audioplayers/audioplayers.dart';
import 'campaign_level_screen.dart';
import 'settings_screen.dart';
import 'juz_selection_screen.dart';
import 'kuis_juz_selection_screen.dart';
import 'leaderboard_screen.dart';
import 'hafalan_screen.dart';
import '../main.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with WidgetsBindingObserver {
  int hsTebakSurah = 0;
  int hsTebakAyat = 0;
  int _selectedIndex = 0;
  String namaUser = "Guest";
  String avatarUser = "assets/avatar/user.png";
  int levelSelesai = 0;
  bool _isNavigating = false;

  final AudioPlayer _bgmPlayer = AudioPlayer();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _loadData();
    _initBGM();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _bgmPlayer.dispose();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    if (state == AppLifecycleState.paused || state == AppLifecycleState.inactive) {
      _bgmPlayer.pause();
    } else if (state == AppLifecycleState.resumed) {
      if (bgmNotifier.value && !_isNavigating) _bgmPlayer.resume();
    }
  }

  void _initBGM() async {
    await _bgmPlayer.setReleaseMode(ReleaseMode.loop);
    SharedPreferences prefs = await SharedPreferences.getInstance();
    bgmNotifier.value = prefs.getBool('bgm_on') ?? true;
    sfxNotifier.value = prefs.getBool('sfx_on') ?? true;

    if (bgmNotifier.value && !_isNavigating) {
      await _bgmPlayer.play(AssetSource('audio/homescreen.wav'));
    }

    bgmNotifier.addListener(() {
      if (bgmNotifier.value && !_isNavigating) _bgmPlayer.resume();
      else _bgmPlayer.pause();
    });
  }

  void _playSFX(String path) async {
    if (!sfxNotifier.value) return;
    final player = AudioPlayer();
    await player.play(AssetSource(path));
    player.onPlayerComplete.listen((_) => player.dispose());
  }

  Future<void> _loadData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String> completed = prefs.getStringList('completed_levels') ?? [];

    List<String> allLevelTitles = [];
    allLevelTitles.addAll(CampaignLevelScreen.levelsMudah.map((e) => e['judul'].toString()));
    allLevelTitles.addAll(CampaignLevelScreen.levelsMedium.map((e) => e['judul'].toString()));
    allLevelTitles.addAll(CampaignLevelScreen.levelsSulit.map((e) => e['judul'].toString()));

    List<String> validCompleted = completed.where((lvl) => allLevelTitles.contains(lvl)).toList();

    setState(() {
      namaUser = prefs.getString('nama_user') ?? "Guest";
      avatarUser = prefs.getString('avatar_user') ?? 'assets/avatar/user.png';

      levelSelesai = validCompleted.length;
      hsTebakSurah = prefs.getInt('highscore_tebak_surah') ?? 0;
      hsTebakAyat = prefs.getInt('highscore_tebak_ayat') ?? 0;
    });
  }

  void _tampilkanDialogPilihKuis() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        backgroundColor: Theme.of(context).brightness == Brightness.dark ? const Color(0xFF11325A) : Colors.white,
        title: const Text('Pilih Tipe Kuis 🧠', textAlign: TextAlign.center, style: TextStyle(fontWeight: FontWeight.bold)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.amber.shade700,
                minimumSize: const Size(double.infinity, 50),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
              ),
              onPressed: () {
                _isNavigating = true;
                _bgmPlayer.pause();
                Navigator.pop(context);
                Navigator.push(context, MaterialPageRoute(builder: (context) => const KuisJuzSelectionScreen(tipeKuis: 'tebak_surah')))
                    .then((_) {
                  _isNavigating = false;
                  if (bgmNotifier.value) _bgmPlayer.resume();
                  _loadData();
                });
              },
              child: const Text('Tebak Surah', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
            ),
            const SizedBox(height: 15),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue.shade700,
                minimumSize: const Size(double.infinity, 50),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
              ),
              onPressed: () {
                _isNavigating = true;
                _bgmPlayer.pause();
                Navigator.pop(context);
                Navigator.push(context, MaterialPageRoute(builder: (context) => const KuisJuzSelectionScreen(tipeKuis: 'tebak_ayat')))
                    .then((_) {
                  _isNavigating = false;
                  if (bgmNotifier.value) _bgmPlayer.resume();
                  _loadData();
                });
              },
              child: const Text('Tebak Ayat', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDashboard(bool isDarkMode, Color bgColor, Color textColor) {
    int totalLevelDynamic = CampaignLevelScreen.totalSemuaLevel;
    double progressValue = totalLevelDynamic > 0 ? (levelSelesai / totalLevelDynamic).clamp(0.0, 1.0) : 0.0;

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        toolbarHeight: 80,
        title: Row(
          children: [
            Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                color: Colors.amber.shade100,
                shape: BoxShape.circle,
                border: Border.all(color: Colors.amber.shade600, width: 2),
              ),
              child: Padding(
                padding: const EdgeInsets.all(4.0),
                child: Image.asset(avatarUser),
              ),
            ),
            const SizedBox(width: 15),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Assalamualaikum,', style: TextStyle(fontSize: 12, color: textColor.withOpacity(0.7))),
                Text(namaUser, style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: textColor)),
              ],
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: Image.asset(
              isDarkMode ? 'assets/icons/dark_mode.png' : 'assets/icons/light_mode.png',
              width: 30, height: 30,
            ),
            onPressed: () {
              _playSFX('audio/click.wav');
              themeNotifier.value = isDarkMode ? ThemeMode.light : ThemeMode.dark;
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(gradient: const LinearGradient(colors: [Colors.amberAccent, Colors.orangeAccent]), borderRadius: BorderRadius.circular(20)),
              child: Row(
                children: [
                  const Expanded(child: Text('Teruslah belajar\ndan menghafal!', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black87))),
                  Image.asset('assets/icons/alquran.png', width: 60, height: 60),
                ],
              ),
            ),
            const SizedBox(height: 25),
            Text('Pilih Mode Permainan', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: textColor)),
            const SizedBox(height: 15),
            GridView.count(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisCount: 2,
              crossAxisSpacing: 15,
              mainAxisSpacing: 15,
              childAspectRatio: 1.2,
              children: [
                GestureDetector(
                  onTap: () async {
                    _playSFX('audio/click.wav');
                    _isNavigating = true;
                    _bgmPlayer.pause();
                    await Navigator.push(context, MaterialPageRoute(builder: (context) => const JuzSelectionScreen()));
                    _isNavigating = false;
                    if (bgmNotifier.value) _bgmPlayer.resume();
                    _loadData();
                  },
                  child: _buildModeCard('Sambung Ayat', 'Petualangan', Colors.green.shade600, 'assets/icons/game_mode.png'),
                ),
                GestureDetector(
                  onTap: () {
                    _playSFX('audio/click.wav');
                    _tampilkanDialogPilihKuis();
                  },
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.amber.shade600,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 5, offset: Offset(0, 5))],
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Image.asset('assets/icons/help.png', width: 45),
                        const SizedBox(height: 5),
                        const Text('Tebak Ayat', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18)),
                        const Text('Mode Tanpa Batas', style: TextStyle(color: Colors.white70, fontSize: 12)),
                        const SizedBox(height: 5),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(color: Colors.black26, borderRadius: BorderRadius.circular(10)),
                          child: Text(
                              '🏆 Surah: $hsTebakSurah | Ayat: $hsTebakAyat',
                              style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold)
                          ),
                        )
                      ],
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 25),
            Text('Progress Petualangan Hafalan', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: textColor)),
            const SizedBox(height: 15),
            GestureDetector(
              onTap: () {
                _playSFX('audio/click.wav');
                setState(() => _selectedIndex = 1);
              },
              child: Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                    color: isDarkMode ? const Color(0xFF11325A) : Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10)]
                ),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Level Diselesaikan', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: textColor)),
                        Text('${(progressValue * 100).toInt()}%', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: textColor)),
                      ],
                    ),
                    const SizedBox(height: 10),
                    LinearProgressIndicator(
                      value: progressValue,
                      backgroundColor: Colors.grey.shade300,
                      color: Colors.green,
                      minHeight: 10,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    const SizedBox(height: 10),
                    Align(
                        alignment: Alignment.centerRight,
                        child: Text('$levelSelesai / $totalLevelDynamic Level', style: TextStyle(color: Colors.amber.shade700, fontWeight: FontWeight.bold, fontSize: 12))
                    ),
                  ],
                ),
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget _buildModeCard(String title, String subtitle, Color color, String iconPath) {
    return Container(
      decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(20)),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Image.asset(iconPath, width: 45, height: 45),
          const SizedBox(height: 10),
          Text(title, style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white, fontSize: 16)),
          Text(subtitle, style: const TextStyle(color: Colors.white70, fontSize: 12)),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    bool isDarkMode = Theme.of(context).brightness == Brightness.dark;
    Color bgColor = isDarkMode ? const Color(0xFF0A2647) : Colors.grey.shade100;
    Color textColor = isDarkMode ? Colors.white : Colors.black87;

    final List<Widget> pages = [
      _buildDashboard(isDarkMode, bgColor, textColor),
      const HafalanScreen(),
      const LeaderboardScreen(),
      const SettingsScreen(),
    ];

    return Scaffold(
      body: pages[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: (index) {
          _playSFX('audio/click.wav');

          if (index == 0) {
            _loadData();
          }
          setState(() => _selectedIndex = index);
        },
        type: BottomNavigationBarType.fixed,
        backgroundColor: isDarkMode ? const Color(0xFF0A2647) : Colors.white,
        selectedItemColor: Colors.amber,
        unselectedItemColor: Colors.grey,
        showUnselectedLabels: true,
        items: [
          BottomNavigationBarItem(
            icon: Image.asset('assets/icons/home.png', width: 25, height: 25, opacity: const AlwaysStoppedAnimation(0.5)),
            activeIcon: Image.asset('assets/icons/home.png', width: 28, height: 28),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Image.asset('assets/icons/alquran.png', width: 25, height: 25, opacity: const AlwaysStoppedAnimation(0.5)),
            activeIcon: Image.asset('assets/icons/alquran.png', width: 28, height: 28),
            label: 'Hafalan',
          ),
          BottomNavigationBarItem(
            icon: Image.asset('assets/icons/trophy.png', width: 25, height: 25, opacity: const AlwaysStoppedAnimation(0.5)),
            activeIcon: Image.asset('assets/icons/trophy.png', width: 28, height: 28),
            label: 'Peringkat',
          ),
          BottomNavigationBarItem(
            icon: Image.asset('assets/icons/setting.png', width: 25, height: 25, opacity: const AlwaysStoppedAnimation(0.5)),
            activeIcon: Image.asset('assets/icons/setting.png', width: 28, height: 28),
            label: 'Settings',
          ),
        ],
      ),
    );
  }
}