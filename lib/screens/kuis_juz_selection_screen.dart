import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:audioplayers/audioplayers.dart';
import 'kuis_gameplay_screen.dart';

class KuisJuzSelectionScreen extends StatefulWidget {
  final String tipeKuis;

  const KuisJuzSelectionScreen({super.key, required this.tipeKuis});

  @override
  State<KuisJuzSelectionScreen> createState() => _KuisJuzSelectionScreenState();
}

class _KuisJuzSelectionScreenState extends State<KuisJuzSelectionScreen> {
  List<String> _completedLevels = [];
  final List<int> urutanJuz = [30, 29, 28, ...List.generate(27, (index) => index + 1)];

  @override
  void initState() {
    super.initState();
    _loadProgress();
  }

  Future<void> _loadProgress() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    if (!mounted) return;
    setState(() {
      _completedLevels = prefs.getStringList('completed_levels') ?? [];
    });
  }

  void _playSFX(String path) async {
    final player = AudioPlayer();
    await player.play(AssetSource(path));
    player.onPlayerComplete.listen((_) => player.dispose());
  }

  void _tampilkanDialogModeGame(int juzId) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text(
          'Pilih Mode Tantangan ⚔️',
          textAlign: TextAlign.center,
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green.shade600,
                minimumSize: const Size(double.infinity, 50),
              ),
              onPressed: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => KuisGameplayScreen(
                      juzId: juzId,
                      tipeKuis: widget.tipeKuis,
                      isEndless: false,
                    ),
                  ),
                );
              },
              child: const Text(
                'Terbatas (30 Soal, 3 Nyawa)',
                style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
              ),
            ),
            const SizedBox(height: 15),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red.shade900,
                minimumSize: const Size(double.infinity, 50),
              ),
              onPressed: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => KuisGameplayScreen(
                      juzId: juzId,
                      tipeKuis: widget.tipeKuis,
                      isEndless: true,
                    ),
                  ),
                );
              },
              child: const Text(
                'Mode Tanpa Batas',
                style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    bool isDarkMode = Theme.of(context).brightness == Brightness.dark;
    String judul = widget.tipeKuis == 'tebak_surah' ? 'Kuis Tebak Surah' : 'Kuis Tebak Ayat';

    return Scaffold(
      backgroundColor: isDarkMode ? const Color(0xFF0A2647) : Colors.grey.shade100,
      appBar: AppBar(
        title: Text(judul, style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
        backgroundColor: const Color(0xFF0A2647),
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: Image.asset('assets/icons/back.png', width: 25, height: 25),
          onPressed: () {
            _playSFX('audio/click.wav');
            Navigator.pop(context);
          },
        ),
      ),
      body: GridView.builder(
        padding: const EdgeInsets.all(20),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 15,
          mainAxisSpacing: 15,
          childAspectRatio: 1.1,
        ),
        itemCount: urutanJuz.length,
        itemBuilder: (context, index) {
          int juzSekarang = urutanJuz[index];
          bool isLocked = false;

          if (index > 0) {
            int juzSebelumnya = urutanJuz[index - 1];
            if (!_completedLevels.contains("🏆 UJIAN AKBAR: SULIT (JUZ $juzSebelumnya)")) {
              isLocked = true;
            }
          }

          return Material(
            color: Colors.transparent,
            child: InkWell(
              borderRadius: BorderRadius.circular(20),
              onTap: () {
                if (isLocked) {
                  _playSFX('audio/wrong.wav');
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Selesaikan Ujian Akbar (Sulit) di Campaign Juz sebelumnya!'),
                      backgroundColor: Colors.red,
                    ),
                  );
                  return;
                }

                _playSFX('audio/click.wav');
                
                if (juzSekarang != 30) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Data Juz Belum Dimasukkan!'),
                      backgroundColor: Colors.orange,
                    ),
                  );
                  return;
                }
                
                _tampilkanDialogModeGame(juzSekarang);
              },
              child: Ink(
                decoration: BoxDecoration(
                  color: isLocked ? Colors.grey.shade400 : (isDarkMode ? const Color(0xFF11325A) : Colors.white),
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 5)],
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    isLocked
                        ? Image.asset('assets/icons/kunci.png', width: 40, color: Colors.grey.shade700)
                        : Image.asset('assets/icons/help.png', width: 50),
                    const SizedBox(height: 15),
                    Text(
                      'JUZ $juzSekarang',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: isLocked ? Colors.grey.shade700 : (isDarkMode ? Colors.white : Colors.black87),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}