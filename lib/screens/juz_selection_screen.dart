import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:audioplayers/audioplayers.dart';
import 'campaign_level_screen.dart';

class JuzSelectionScreen extends StatefulWidget {
  const JuzSelectionScreen({super.key});

  @override
  State<JuzSelectionScreen> createState() => _JuzSelectionScreenState();
}

class _JuzSelectionScreenState extends State<JuzSelectionScreen> {
  List<String> _completedLevels = [];

  final List<int> urutanJuz = [
    30, 29, 28,
    ...List.generate(27, (index) => index + 1)
  ];

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

  @override
  Widget build(BuildContext context) {
    bool isDarkMode = Theme.of(context).brightness == Brightness.dark;
    Color bgColor = isDarkMode ? const Color(0xFF0A2647) : Colors.grey.shade100;

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        title: const Text('Pilih Juz', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
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
            String namaBosSulitSebelumnya = "🏆 UJIAN AKBAR: SULIT (JUZ $juzSebelumnya)";
            if (!_completedLevels.contains(namaBosSulitSebelumnya)) {
              isLocked = true;
            }
          }

          return _buildJuzCard(juzSekarang, isLocked, isDarkMode);
        },
      ),
    );
  }

  Widget _buildJuzCard(int juzId, bool isLocked, bool isDarkMode) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: () async {
          if (isLocked) {
            _playSFX('audio/wrong.wav');
            if (!mounted) return;
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Kalahkan Ujian Akbar (Sulit) di Juz sebelumnya untuk membuka ini!'),
                backgroundColor: Colors.red,
              ),
            );
            return;
          }

          _playSFX('audio/click.wav');
          await Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => CampaignLevelScreen(juzId: juzId)),
          );
          
          _loadProgress();
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
                  : Image.asset('assets/icons/alquran.png', width: 50),
              const SizedBox(height: 15),
              Text(
                'JUZ $juzId',
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
  }
}