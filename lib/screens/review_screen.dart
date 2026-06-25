import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';
import '../main.dart';

class ReviewScreen extends StatefulWidget {
  final String judulLevel;
  final int score;
  final int stars;
  final List<Map<String, String>> riwayatJawaban;

  const ReviewScreen({
    super.key,
    required this.judulLevel,
    required this.score,
    required this.stars,
    required this.riwayatJawaban,
  });

  @override
  State<ReviewScreen> createState() => _ReviewScreenState();
}

class _ReviewScreenState extends State<ReviewScreen> {

  @override
  void initState() {
    super.initState();
    _playResultBGM();
  }

  void _playResultBGM() async {
    if (!sfxNotifier.value) return;

    AudioPlayer player = AudioPlayer();
    String audioPath;

    if (widget.stars > 0) {
      if (widget.judulLevel.contains("UJIAN AKBAR")) {
        audioPath = 'audio/victory_boss.wav';
      } else {
        audioPath = 'audio/star.wav';
      }
    } else {
      audioPath = 'audio/wrong.wav';
    }

    await player.play(AssetSource(audioPath));
    player.onPlayerComplete.listen((_) => player.dispose());
  }

  void _playSFX(String path) async {
    if (!sfxNotifier.value) return;
    AudioPlayer player = AudioPlayer();
    await player.play(AssetSource(path));
    player.onPlayerComplete.listen((_) => player.dispose());
  }

  @override
  Widget build(BuildContext context) {
    bool isDarkMode = Theme.of(context).brightness == Brightness.dark;
    Color bgColor = isDarkMode ? const Color(0xFF0A2647) : Colors.grey.shade100;
    Color cardColor = isDarkMode ? const Color(0xFF11325A) : Colors.white;
    Color textColor = isDarkMode ? Colors.white : Colors.black87;

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        title: const Text('Hasil Permainan', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
        backgroundColor: const Color(0xFF0A2647),
        elevation: 0,
        centerTitle: true,
        automaticallyImplyLeading: false,
      ),
      body: SafeArea(
        child: Column(
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: const Color(0xFF0A2647),
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(30),
                  bottomRight: Radius.circular(30),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.2),
                    blurRadius: 10,
                    offset: const Offset(0, 5),
                  )
                ],
              ),
              child: Column(
                children: [
                  Text(
                    widget.judulLevel,
                    textAlign: TextAlign.center,
                    style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white),
                  ),
                  const SizedBox(height: 15),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(
                      3,
                      (index) => Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 5),
                        child: Icon(
                          index < widget.stars ? Icons.star : Icons.star_border,
                          color: Colors.amber,
                          size: 40,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 15),
                  Text(
                    'Skor Anda: ${widget.score}',
                    style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.amber),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 10),
            Text(
              'Evaluasi Jawaban',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: textColor),
            ),
            const SizedBox(height: 10),
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                itemCount: widget.riwayatJawaban.length,
                itemBuilder: (context, index) {
                  var riwayat = widget.riwayatJawaban[index];
                  bool isBenar = riwayat['is_correct'] == 'true';

                  return Container(
                    margin: const EdgeInsets.only(bottom: 15),
                    padding: const EdgeInsets.all(15),
                    decoration: BoxDecoration(
                      color: cardColor,
                      borderRadius: BorderRadius.circular(15),
                      border: Border.all(color: isBenar ? Colors.green : Colors.red, width: 2),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Text('Pertanyaan:', style: TextStyle(color: Colors.grey.shade600, fontSize: 12)),
                        Text(
                          riwayat['soal']!,
                          textAlign: TextAlign.right,
                          style: TextStyle(fontSize: 20, fontFamily: 'Arial', color: textColor),
                        ),
                        const Divider(height: 20),
                        Text('Jawaban Anda:', style: TextStyle(color: Colors.grey.shade600, fontSize: 12)),
                        Text(
                          riwayat['jawaban_user']!,
                          textAlign: TextAlign.right,
                          style: TextStyle(
                            fontSize: 18,
                            fontFamily: 'Fredoka',
                            color: isBenar ? Colors.green : Colors.red,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        if (!isBenar) ...[
                          const SizedBox(height: 10),
                          Text('Jawaban Benar:', style: TextStyle(color: Colors.grey.shade600, fontSize: 12)),
                          Text(
                            riwayat['jawaban_benar']!,
                            textAlign: TextAlign.right,
                            style: const TextStyle(
                              fontSize: 18,
                              fontFamily: 'Fredoka',
                              color: Colors.green,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ]
                      ],
                    ),
                  );
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 10, 20, 20),
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.amber.shade700,
                  minimumSize: const Size(double.infinity, 55),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                  elevation: 5,
                ),
                onPressed: () {
                  _playSFX('audio/click.wav');
                  if (widget.judulLevel.contains("🏆 UJIAN AKBAR: SULIT")) {
                    Navigator.pop(context);
                    Navigator.pop(context);
                  } else {
                    Navigator.pop(context);
                  }
                },
                child: const Text(
                  'Selesai & Kembali',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}