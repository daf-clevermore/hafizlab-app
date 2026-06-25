import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:audioplayers/audioplayers.dart';
import 'gameplay_screen.dart';

class CampaignLevelScreen extends StatefulWidget {
  final int juzId;

  const CampaignLevelScreen({super.key, required this.juzId});

  static final List<Map<String, dynamic>> levelsMudah = [
    {"judul": "1. An-Nas", "deskripsi": "Perlindungan dari godaan", "tipe": "normal", "konfigurasi": [{"idSurah": 114, "startAyat": 1, "endAyat": 6}]},
    {"judul": "2. Al-Falaq", "deskripsi": "Perlindungan waktu subuh", "tipe": "normal", "konfigurasi": [{"idSurah": 113, "startAyat": 1, "endAyat": 5}]},
    {"judul": "3. Al-Ikhlas", "deskripsi": "Keesaan Allah", "tipe": "normal", "konfigurasi": [{"idSurah": 112, "startAyat": 1, "endAyat": 4}]},
    {"judul": "4. Al-Lahab", "deskripsi": "Gejolak api", "tipe": "normal", "konfigurasi": [{"idSurah": 111, "startAyat": 1, "endAyat": 5}]},
    {"judul": "5. An-Nasr", "deskripsi": "Pertolongan Allah", "tipe": "normal", "konfigurasi": [{"idSurah": 110, "startAyat": 1, "endAyat": 3}]},
    {"judul": "6. Al-Kafirun", "deskripsi": "Orang-orang kafir", "tipe": "normal", "konfigurasi": [{"idSurah": 109, "startAyat": 1, "endAyat": 6}]},
    {
      "judul": "UJIAN TAHAP 1 (JUZ 30)",
      "deskripsi": "Evaluasi Surah 1 sampai 6",
      "tipe": "ujian_tahap",
      "req_bintang": 12,
      "konfigurasi": [
        {"idSurah": 114, "startAyat": 1, "endAyat": 6},
        {"idSurah": 113, "startAyat": 1, "endAyat": 5},
        {"idSurah": 112, "startAyat": 1, "endAyat": 4},
        {"idSurah": 111, "startAyat": 1, "endAyat": 5},
        {"idSurah": 110, "startAyat": 1, "endAyat": 3},
        {"idSurah": 109, "startAyat": 1, "endAyat": 6},
      ]
    },
    {"judul": "7. Al-Kautsar", "deskripsi": "Nikmat yang banyak", "tipe": "normal", "konfigurasi": [{"idSurah": 108, "startAyat": 1, "endAyat": 3}]},
    {"judul": "8. Al-Ma'un", "deskripsi": "Barang-barang berguna", "tipe": "normal", "konfigurasi": [{"idSurah": 107, "startAyat": 1, "endAyat": 7}]},
    {"judul": "9. Quraisy", "deskripsi": "Suku Quraisy", "tipe": "normal", "konfigurasi": [{"idSurah": 106, "startAyat": 1, "endAyat": 4}]},
    {"judul": "10. Al-Fil", "deskripsi": "Pasukan gajah", "tipe": "normal", "konfigurasi": [{"idSurah": 105, "startAyat": 1, "endAyat": 5}]},
    {"judul": "11. Al-Humazah", "deskripsi": "Pengumpat", "tipe": "normal", "konfigurasi": [{"idSurah": 104, "startAyat": 1, "endAyat": 9}]},
    {"judul": "12. Al-'Asr", "deskripsi": "Demi masa", "tipe": "normal", "konfigurasi": [{"idSurah": 103, "startAyat": 1, "endAyat": 3}]},
    {
      "judul": "UJIAN TAHAP 2 (JUZ 30)",
      "deskripsi": "Evaluasi Surah 7 sampai 12",
      "tipe": "ujian_tahap",
      "req_bintang": 24,
      "konfigurasi": [
        {"idSurah": 108, "startAyat": 1, "endAyat": 3},
        {"idSurah": 107, "startAyat": 1, "endAyat": 7},
        {"idSurah": 106, "startAyat": 1, "endAyat": 4},
        {"idSurah": 105, "startAyat": 1, "endAyat": 5},
        {"idSurah": 104, "startAyat": 1, "endAyat": 9},
        {"idSurah": 103, "startAyat": 1, "endAyat": 3},
      ]
    },
    {
      "judul": "UJIAN AKBAR: MUDAH (JUZ 30)",
      "deskripsi": "15 Soal Acak Kategori Mudah",
      "tipe": "ujian_akbar",
      "req_bintang": 30,
      "isRandom": true,
      "maxSoal": 15,
      "timeLimit": 180,
      "konfigurasi": [
        {"idSurah": 114, "startAyat": 1, "endAyat": 6},
        {"idSurah": 113, "startAyat": 1, "endAyat": 5},
        {"idSurah": 112, "startAyat": 1, "endAyat": 4},
        {"idSurah": 111, "startAyat": 1, "endAyat": 5},
        {"idSurah": 110, "startAyat": 1, "endAyat": 3},
        {"idSurah": 109, "startAyat": 1, "endAyat": 6},
        {"idSurah": 108, "startAyat": 1, "endAyat": 3},
        {"idSurah": 107, "startAyat": 1, "endAyat": 7},
        {"idSurah": 106, "startAyat": 1, "endAyat": 4},
        {"idSurah": 105, "startAyat": 1, "endAyat": 5},
        {"idSurah": 104, "startAyat": 1, "endAyat": 9},
        {"idSurah": 103, "startAyat": 1, "endAyat": 3},
      ]
    },
  ];

  static final List<Map<String, dynamic>> levelsMedium = [
    {"judul": "13. At-Takatsur", "deskripsi": "Bermegah-megahan", "tipe": "normal", "konfigurasi": [{"idSurah": 102, "startAyat": 1, "endAyat": 8}]},
    {"judul": "14. Al-Qari'ah", "deskripsi": "Hari kiamat", "tipe": "normal", "konfigurasi": [{"idSurah": 101, "startAyat": 1, "endAyat": 11}]},
    {"judul": "15. Al-'Adiyat", "deskripsi": "Kuda perang", "tipe": "normal", "konfigurasi": [{"idSurah": 100, "startAyat": 1, "endAyat": 11}]},
    {
      "judul": "UJIAN TAHAP 1 (MEDIUM)",
      "deskripsi": "Evaluasi Level 13 sampai 15",
      "tipe": "ujian_tahap",
      "req_bintang": 38,
      "konfigurasi": [
        {"idSurah": 102, "startAyat": 1, "endAyat": 8},
        {"idSurah": 101, "startAyat": 1, "endAyat": 11},
        {"idSurah": 100, "startAyat": 1, "endAyat": 11},
      ]
    },
    {"judul": "16. Az-Zalzalah", "deskripsi": "Kegoncangan bumi", "tipe": "normal", "konfigurasi": [{"idSurah": 99, "startAyat": 1, "endAyat": 8}]},
    {"judul": "17. Al-Bayyinah", "deskripsi": "Bukti yang nyata", "tipe": "normal", "konfigurasi": [{"idSurah": 98, "startAyat": 1, "endAyat": 8}]},
    {"judul": "18. Al-Qadr", "deskripsi": "Kemuliaan malam Lailatul Qadr", "tipe": "normal", "konfigurasi": [{"idSurah": 97, "startAyat": 1, "endAyat": 5}]},
    {
      "judul": "UJIAN TAHAP 2 (MEDIUM)",
      "deskripsi": "Evaluasi Level 16 sampai 18",
      "tipe": "ujian_tahap",
      "req_bintang": 45,
      "konfigurasi": [
        {"idSurah": 99, "startAyat": 1, "endAyat": 8},
        {"idSurah": 98, "startAyat": 1, "endAyat": 8},
        {"idSurah": 97, "startAyat": 1, "endAyat": 5},
      ]
    },
    {"judul": "19. Al-'Alaq", "deskripsi": "Segumpal darah", "tipe": "normal", "konfigurasi": [{"idSurah": 96, "startAyat": 1, "endAyat": 19}]},
    {"judul": "20. At-Tin", "deskripsi": "Buah Tin", "tipe": "normal", "konfigurasi": [{"idSurah": 95, "startAyat": 1, "endAyat": 8}]},
    {"judul": "21. Asy-Syarh", "deskripsi": "Lapang dada", "tipe": "normal", "konfigurasi": [{"idSurah": 94, "startAyat": 1, "endAyat": 8}]},
    {"judul": "22. Ad-Duha", "deskripsi": "Waktu duha", "tipe": "normal", "konfigurasi": [{"idSurah": 93, "startAyat": 1, "endAyat": 11}]},
    {
      "judul": "UJIAN TAHAP 3 (MEDIUM)",
      "deskripsi": "Evaluasi Level 19 sampai 22",
      "tipe": "ujian_tahap",
      "req_bintang": 55,
      "konfigurasi": [
        {"idSurah": 96, "startAyat": 1, "endAyat": 19},
        {"idSurah": 95, "startAyat": 1, "endAyat": 8},
        {"idSurah": 94, "startAyat": 1, "endAyat": 8},
        {"idSurah": 93, "startAyat": 1, "endAyat": 11},
      ]
    },
    {
      "judul": "UJIAN AKBAR: MEDIUM (JUZ 30)",
      "deskripsi": "30 Soal Acak dari Kategori Mudah & Medium",
      "tipe": "ujian_akbar",
      "req_bintang": 65,
      "isRandom": true,
      "maxSoal": 30,
      "timeLimit": 300,
      "konfigurasi": [
        {"idSurah": 114, "startAyat": 1, "endAyat": 6},
        {"idSurah": 113, "startAyat": 1, "endAyat": 5},
        {"idSurah": 112, "startAyat": 1, "endAyat": 4},
        {"idSurah": 111, "startAyat": 1, "endAyat": 5},
        {"idSurah": 110, "startAyat": 1, "endAyat": 3},
        {"idSurah": 109, "startAyat": 1, "endAyat": 6},
        {"idSurah": 108, "startAyat": 1, "endAyat": 3},
        {"idSurah": 107, "startAyat": 1, "endAyat": 7},
        {"idSurah": 106, "startAyat": 1, "endAyat": 4},
        {"idSurah": 105, "startAyat": 1, "endAyat": 5},
        {"idSurah": 104, "startAyat": 1, "endAyat": 9},
        {"idSurah": 103, "startAyat": 1, "endAyat": 3},
        {"idSurah": 102, "startAyat": 1, "endAyat": 8},
        {"idSurah": 101, "startAyat": 1, "endAyat": 11},
        {"idSurah": 100, "startAyat": 1, "endAyat": 11},
        {"idSurah": 99, "startAyat": 1, "endAyat": 8},
        {"idSurah": 98, "startAyat": 1, "endAyat": 8},
        {"idSurah": 97, "startAyat": 1, "endAyat": 5},
        {"idSurah": 96, "startAyat": 1, "endAyat": 19},
        {"idSurah": 95, "startAyat": 1, "endAyat": 8},
        {"idSurah": 94, "startAyat": 1, "endAyat": 8},
        {"idSurah": 93, "startAyat": 1, "endAyat": 11},
      ]
    },
  ];

  static final List<Map<String, dynamic>> levelsSulit = [
    {"judul": "23. Al-Lail", "deskripsi": "Malam", "tipe": "normal", "konfigurasi": [{"idSurah": 92, "startAyat": 1, "endAyat": 21}]},
    {"judul": "24. Asy-Syams", "deskripsi": "Matahari", "tipe": "normal", "konfigurasi": [{"idSurah": 91, "startAyat": 1, "endAyat": 15}]},
    {"judul": "25. Al-Balad", "deskripsi": "Negeri", "tipe": "normal", "konfigurasi": [{"idSurah": 90, "startAyat": 1, "endAyat": 20}]},
    {"judul": "26. Al-Fajr", "deskripsi": "Fajar", "tipe": "normal", "konfigurasi": [{"idSurah": 89, "startAyat": 1, "endAyat": 30}]},
    {"judul": "27. Al-Ghasyiyah", "deskripsi": "Hari pembalasan", "tipe": "normal", "konfigurasi": [{"idSurah": 88, "startAyat": 1, "endAyat": 26}]},
    {"judul": "28. Al-A'la", "deskripsi": "Yang paling tinggi", "tipe": "normal", "konfigurasi": [{"idSurah": 87, "startAyat": 1, "endAyat": 19}]},
    {"judul": "29. At-Tariq", "deskripsi": "Yang datang di malam hari", "tipe": "normal", "konfigurasi": [{"idSurah": 86, "startAyat": 1, "endAyat": 17}]},
    {"judul": "30. Al-Buruj", "deskripsi": "Gugusan bintang", "tipe": "normal", "konfigurasi": [{"idSurah": 85, "startAyat": 1, "endAyat": 22}]},
    {"judul": "31. Al-Insyiqaq", "deskripsi": "Terbelah", "tipe": "normal", "konfigurasi": [{"idSurah": 84, "startAyat": 1, "endAyat": 25}]},
    {"judul": "32. Al-Mutaffifin", "deskripsi": "Orang yang curang", "tipe": "normal", "konfigurasi": [{"idSurah": 83, "startAyat": 1, "endAyat": 36}]},
    {"judul": "33. Al-Infitar", "deskripsi": "Terbelah", "tipe": "normal", "konfigurasi": [{"idSurah": 82, "startAyat": 1, "endAyat": 19}]},
    {"judul": "34. At-Takwir", "deskripsi": "Menggulung", "tipe": "normal", "konfigurasi": [{"idSurah": 81, "startAyat": 1, "endAyat": 29}]},
    {"judul": "35. 'Abasa", "deskripsi": "Ia bermuka masam", "tipe": "normal", "konfigurasi": [{"idSurah": 80, "startAyat": 1, "endAyat": 42}]},
    {"judul": "36. An-Nazi'at", "deskripsi": "Malaikat yang mencabut", "tipe": "normal", "konfigurasi": [{"idSurah": 79, "startAyat": 1, "endAyat": 46}]},
    {"judul": "37. An-Naba'", "deskripsi": "Berita besar", "tipe": "normal", "konfigurasi": [{"idSurah": 78, "startAyat": 1, "endAyat": 40}]},
    {
      "judul": "UJIAN AKBAR: SULIT (JUZ 30)",
      "deskripsi": "45 Soal Marathon Semua Level",
      "tipe": "ujian_akbar",
      "req_bintang": 100,
      "isRandom": true,
      "maxSoal": 45,
      "timeLimit": 420,
      "konfigurasi": [
        {"idSurah": 114, "startAyat": 1, "endAyat": 6},
        {"idSurah": 113, "startAyat": 1, "endAyat": 5},
        {"idSurah": 112, "startAyat": 1, "endAyat": 4},
        {"idSurah": 111, "startAyat": 1, "endAyat": 5},
        {"idSurah": 110, "startAyat": 1, "endAyat": 3},
        {"idSurah": 109, "startAyat": 1, "endAyat": 6},
        {"idSurah": 108, "startAyat": 1, "endAyat": 3},
        {"idSurah": 107, "startAyat": 1, "endAyat": 7},
        {"idSurah": 106, "startAyat": 1, "endAyat": 4},
        {"idSurah": 105, "startAyat": 1, "endAyat": 5},
        {"idSurah": 104, "startAyat": 1, "endAyat": 9},
        {"idSurah": 103, "startAyat": 1, "endAyat": 3},
        {"idSurah": 102, "startAyat": 1, "endAyat": 8},
        {"idSurah": 101, "startAyat": 1, "endAyat": 11},
        {"idSurah": 100, "startAyat": 1, "endAyat": 11},
        {"idSurah": 99, "startAyat": 1, "endAyat": 8},
        {"idSurah": 98, "startAyat": 1, "endAyat": 8},
        {"idSurah": 97, "startAyat": 1, "endAyat": 5},
        {"idSurah": 96, "startAyat": 1, "endAyat": 19},
        {"idSurah": 95, "startAyat": 1, "endAyat": 8},
        {"idSurah": 94, "startAyat": 1, "endAyat": 8},
        {"idSurah": 93, "startAyat": 1, "endAyat": 11},
        {"idSurah": 92, "startAyat": 1, "endAyat": 21},
        {"idSurah": 91, "startAyat": 1, "endAyat": 15},
        {"idSurah": 90, "startAyat": 1, "endAyat": 20},
        {"idSurah": 89, "startAyat": 1, "endAyat": 30},
        {"idSurah": 88, "startAyat": 1, "endAyat": 26},
        {"idSurah": 87, "startAyat": 1, "endAyat": 19},
        {"idSurah": 86, "startAyat": 1, "endAyat": 17},
        {"idSurah": 85, "startAyat": 1, "endAyat": 22},
        {"idSurah": 84, "startAyat": 1, "endAyat": 25},
        {"idSurah": 83, "startAyat": 1, "endAyat": 36},
        {"idSurah": 82, "startAyat": 1, "endAyat": 19},
        {"idSurah": 81, "startAyat": 1, "endAyat": 29},
        {"idSurah": 80, "startAyat": 1, "endAyat": 42},
        {"idSurah": 79, "startAyat": 1, "endAyat": 46},
        {"idSurah": 78, "startAyat": 1, "endAyat": 40},
      ]
    },
  ];

  static int get totalSemuaLevel => levelsMudah.length + levelsMedium.length + levelsSulit.length;

  @override
  State<CampaignLevelScreen> createState() => _CampaignLevelScreenState();
}

class _CampaignLevelScreenState extends State<CampaignLevelScreen> {
  int totalBintangUser = 0;
  List<String> _completedLevels = [];
  Map<String, int> _levelStars = {};

  @override
  void initState() {
    super.initState();
    _loadProgress();
  }

  Future<void> _loadProgress() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    int hitungBintang = 0;
    Map<String, int> starsMap = {};
    List<Map<String, dynamic>> allLevels = [...CampaignLevelScreen.levelsMudah, ...CampaignLevelScreen.levelsMedium, ...CampaignLevelScreen.levelsSulit];

    for (var level in allLevels) {
      int stars = prefs.getInt('stars_${level['judul']}') ?? 0;
      hitungBintang += stars;
      starsMap[level['judul']] = stars;
    }

    setState(() {
      _completedLevels = prefs.getStringList('completed_levels') ?? [];
      totalBintangUser = hitungBintang;
      _levelStars = starsMap;
    });
  }

  void _playSFX(String path) async {
    final player = AudioPlayer();
    await player.play(AssetSource(path));
    player.onPlayerComplete.listen((_) => player.dispose());
  }

  @override
  Widget build(BuildContext context) {
    bool isDarkMode = Theme.of(context).brightness == Brightness.dark;
    Color bgColor = isDarkMode ? const Color(0xFF0A2647) : Colors.grey.shade100;

    // FIX: Emojinya dihapus juga di sini biar cocok!
    bool isMediumUnlocked = _completedLevels.contains("UJIAN AKBAR: MUDAH (JUZ 30)");
    bool isSulitUnlocked = _completedLevels.contains("UJIAN AKBAR: MEDIUM (JUZ 30)");

    if (widget.juzId != 30) {
      return Scaffold(
        backgroundColor: bgColor,
        appBar: AppBar(title: Text('Juz ${widget.juzId}'), backgroundColor: const Color(0xFF0A2647)),
        body: const Center(child: Text('Data Surah Belum Dimasukkan / Coming Soon!', style: TextStyle(fontSize: 18))),
      );
    }

    return DefaultTabController(
      length: 3,
      child: Scaffold(
        backgroundColor: bgColor,
        appBar: AppBar(
          title: Text('Kampanye Juz ${widget.juzId}', style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
          backgroundColor: const Color(0xFF0A2647),
          elevation: 0,
          leading: IconButton(
              icon: Image.asset('assets/icons/back.png', width: 25, height: 25),
              onPressed: () {
                _playSFX('audio/click.wav');
                Navigator.pop(context);
              }
          ),
          actions: [
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 15, vertical: 12),
              padding: const EdgeInsets.symmetric(horizontal: 12),
              decoration: BoxDecoration(color: Colors.black45, borderRadius: BorderRadius.circular(20)),
              child: Row(
                children: [
                  Image.asset('assets/icons/star_gold.png', width: 20),
                  const SizedBox(width: 5),
                  Text('$totalBintangUser', style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.amber)),
                ],
              ),
            )
          ],
          bottom: const TabBar(
            indicatorColor: Colors.amber,
            indicatorWeight: 4,
            labelColor: Colors.amber,
            unselectedLabelColor: Colors.grey,
            tabs: [
              Tab(text: "MUDAH"),
              Tab(text: "MEDIUM"),
              Tab(text: "SULIT"),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            _buildLevelList(CampaignLevelScreen.levelsMudah, false, ""),
            _buildLevelList(CampaignLevelScreen.levelsMedium, !isMediumUnlocked, "Kalahkan 'UJIAN AKBAR: MUDAH' buat buka level ini!"),
            _buildLevelList(CampaignLevelScreen.levelsSulit, !isSulitUnlocked, "Kalahkan 'UJIAN AKBAR: MEDIUM' buat buka level ini!"),
          ],
        ),
      ),
    );
  }

  Widget _buildLockedTabInfo(String message) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(30.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset('assets/icons/kunci.png', width: 80, color: Colors.grey),
            const SizedBox(height: 20),
            Text('Mode Terkunci', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.grey.shade600)),
            const SizedBox(height: 10),
            Text(message, textAlign: TextAlign.center, style: const TextStyle(color: Colors.grey, fontSize: 16)),
          ],
        ),
      ),
    );
  }

  Widget _buildLevelList(List<Map<String, dynamic>> listData, bool isTabLocked, String tabLockMessage) {
    return ListView.builder(
      padding: const EdgeInsets.all(20),
      itemCount: listData.length,
      itemBuilder: (context, index) {
        var level = listData[index];
        bool isBoss = level['tipe'] == 'ujian_tahap' || level['tipe'] == 'ujian_akbar';

        bool isLocked = isTabLocked;

        if (!isTabLocked) {
          if (index > 0) {
            String prevLevelTitle = listData[index - 1]['judul'];
            if (!_completedLevels.contains(prevLevelTitle)) {
              isLocked = true;
            }
          }
          if (isBoss && totalBintangUser < (level['req_bintang'] ?? 0)) {
            isLocked = true;
          }
        }

        int earnedStars = _levelStars[level['judul']] ?? 0;

        return _buildLevelCard(level, isBoss, isLocked, earnedStars, isTabLocked ? tabLockMessage : null);
      },
    );
  }

  Widget _buildLevelCard(Map<String, dynamic> level, bool isBoss, bool isLocked, int earnedStars, String? customErrorMessage) {
    List<Color> cardGradient;
    if (isLocked) {
      cardGradient = [Colors.grey.shade700, Colors.grey.shade500];
    } else if (level['tipe'] == 'ujian_akbar') {
      cardGradient = [Colors.red.shade900, Colors.redAccent.shade700];
    } else if (level['tipe'] == 'ujian_tahap') {
      cardGradient = [Colors.orange.shade800, Colors.amber.shade600];
    } else {
      cardGradient = [Colors.green.shade700, Colors.lightGreen.shade500];
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(20),
          onTap: () async {
            if (isLocked) {
              _playSFX('audio/wrong.wav');
              String msg = customErrorMessage ?? (isBoss
                  ? 'Butuh ${level['req_bintang']} ⭐️ buat ikut Ujian ini!'
                  : 'Selesaikan level sebelumnya dulu!');
              ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg), backgroundColor: Colors.red));
              return;
            }

            _playSFX('audio/click.wav');
            await Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => GameplayScreen(
                  judulLevel: level['judul'],
                  konfigurasiLevel: List<Map<String, int>>.from(level['konfigurasi']),
                  isRandom: level['isRandom'] ?? false,
                  maxSoal: level['maxSoal'] ?? 0,
                  timeLimit: level['timeLimit'] ?? 0,
                ),
              ),
            );
            _loadProgress();
          },
          child: Ink(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: LinearGradient(colors: cardGradient),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: const BoxDecoration(color: Colors.white24, shape: BoxShape.circle),
                  child: isLocked
                      ? Image.asset('assets/icons/kunci.png', width: 30)
                      : (level['tipe'] == 'ujian_akbar'
                      ? Image.asset('assets/icons/crown_gold.png', width: 30)
                      : Image.asset('assets/icons/surah.png', width: 30)),
                ),
                const SizedBox(width: 15),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(level['judul'], style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
                      Text(level['deskripsi'], style: const TextStyle(color: Colors.white70, fontSize: 13)),
                      if (isBoss) ...[
                        const SizedBox(height: 5),
                        Text('Syarat: ${level['req_bintang']} ⭐️', style: TextStyle(color: isLocked ? Colors.red.shade200 : Colors.amber.shade200, fontSize: 12, fontWeight: FontWeight.bold)),
                      ]
                    ],
                  ),
                ),
                if (earnedStars > 0 && !isLocked)
                  Row(
                    children: List.generate(3, (index) => Icon(
                      index < earnedStars ? Icons.star : Icons.star_border,
                      color: Colors.amber,
                      size: 22,
                    )),
                  )
                else if (!isLocked)
                  const Icon(Icons.play_circle_fill, color: Colors.white, size: 30),
              ],
            ),
          ),
        ),
      ),
    );
  }
}