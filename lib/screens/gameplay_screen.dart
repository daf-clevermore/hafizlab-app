import 'package:flutter/material.dart';
import 'dart:convert';
import 'dart:async';
import 'package:http/http.dart' as http;
import 'package:audioplayers/audioplayers.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../main.dart';
import 'review_screen.dart';

class GameplayScreen extends StatefulWidget {
  final List<Map<String, int>> konfigurasiLevel;
  final String judulLevel;
  final bool isRandom;
  final int maxSoal;
  final int timeLimit;

  const GameplayScreen({
    super.key,
    required this.konfigurasiLevel,
    required this.judulLevel,
    this.isRandom = false,
    this.maxSoal = 0,
    this.timeLimit = 0,
  });

  @override
  State<GameplayScreen> createState() => _GameplayScreenState();
}

class _GameplayScreenState extends State<GameplayScreen> with WidgetsBindingObserver {
  List<Map<String, dynamic>> soalList = [];
  int currentIndex = 0;
  int correctAnswers = 0;
  bool isLoading = true;
  List<Map<String, String>> riwayatJawabanUser = [];

  final AudioPlayer _bgmPlayer = AudioPlayer();
  final AudioPlayer _timerSfxPlayer = AudioPlayer();

  Timer? _timer;
  int _timeLeft = 0;

  int get currentScore => soalList.isEmpty ? 0 : ((correctAnswers / soalList.length) * 100).round();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _timeLeft = widget.timeLimit;
    _fetchSoalGabungan();
    _playBGM();
  }

  void _startTimer() {
    if (_timeLeft > 0) {
      _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
        if (_timeLeft > 0) {
          setState(() {
            _timeLeft--;

            if (_timeLeft == 10 && widget.judulLevel.contains("UJIAN AKBAR")) {
              if (sfxNotifier.value) {
                _timerSfxPlayer.setVolume(1.0);
                _timerSfxPlayer.play(AssetSource('audio/timer.wav'));
              }
            }
          });
        } else {
          _timer?.cancel();
          _timerSfxPlayer.stop();
          _playSFX('audio/wrong.wav');
          _showGameFinished();
        }
      });
    }
  }

  void _playBGM() async {
    if (!bgmNotifier.value) return;
    await _bgmPlayer.setReleaseMode(ReleaseMode.loop);
    await _bgmPlayer.setVolume(0.3);

    String bgmPath = widget.judulLevel.contains("UJIAN AKBAR") ? 'audio/akbar.mp3' : 'audio/gameplay.wav';
    await _bgmPlayer.play(AssetSource(bgmPath));
  }

  void _playSFX(String path) async {
    if (!sfxNotifier.value) return;
    AudioPlayer player = AudioPlayer();
    await player.play(AssetSource(path));
    player.onPlayerComplete.listen((_) => player.dispose());
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _timer?.cancel();
    _bgmPlayer.dispose();
    _timerSfxPlayer.dispose();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    if (state == AppLifecycleState.paused || state == AppLifecycleState.inactive) {
      _bgmPlayer.pause();
    } else if (state == AppLifecycleState.resumed) {
      if (bgmNotifier.value) _bgmPlayer.resume();
    }
  }

  Future<void> _fetchSoalGabungan() async {
    try {
      List<Map<String, dynamic>> kumpulanSoal = [];
      for (var target in widget.konfigurasiLevel) {
        int idSurah = target['idSurah']!;
        int startAyat = target['startAyat']!;
        int endAyat = target['endAyat']!;

        var url = Uri.parse('https://equran.id/api/v2/surat/$idSurah');
        var response = await http.get(url);

        if (response.statusCode == 200) {
          var data = json.decode(response.body);
          List<dynamic> allAyatList = data['data']['ayat'];

          int startIndex = (startAyat - 1).clamp(0, allAyatList.length - 1);
          int endIndex = endAyat.clamp(0, allAyatList.length);

          List<dynamic> targetAyatList = allAyatList.sublist(startIndex, endIndex);

          for (int i = 0; i < targetAyatList.length - 1; i++) {
            String teksPertanyaan = targetAyatList[i]['teksArab'];
            String teksJawabanBenar = targetAyatList[i + 1]['teksArab'];

            List<String> listTrap = allAyatList
                .where((a) => a['teksArab'] != teksJawabanBenar && a['teksArab'] != teksPertanyaan)
                .map((a) => a['teksArab'] as String)
                .toList();
            listTrap.shuffle();

            List<String> pilihanGanda = [
              teksJawabanBenar,
              listTrap.isNotEmpty ? listTrap[0] : "بِسْمِ ٱللَّهِ ٱلرَّحْمَٰنِ ٱلرَّحِيمِ",
              listTrap.length > 1 ? listTrap[1] : "ٱلْحَمْدُ لِلَّهِ رَبِّ ٱلْعَٰلَمِينَ"
            ];
            pilihanGanda.shuffle();

            String kunciHuruf = ['A', 'B', 'C'][pilihanGanda.indexOf(teksJawabanBenar)];

            kumpulanSoal.add({
              'teks_ayat': teksPertanyaan,
              'pilihan_a': pilihanGanda[0],
              'pilihan_b': pilihanGanda[1],
              'pilihan_c': pilihanGanda[2],
              'jawaban_benar': kunciHuruf,
            });
          }
        }
      }

      if (widget.isRandom) {
        kumpulanSoal.shuffle();
        if (kumpulanSoal.length > widget.maxSoal) kumpulanSoal = kumpulanSoal.sublist(0, widget.maxSoal);
      }

      setState(() {
        soalList = kumpulanSoal;
        isLoading = false;
      });

      if (widget.timeLimit > 0) _startTimer();
    } catch (e) {
      _showError("Gagal memuat data soal.");
    }
  }

  void _showError(String msg) {
    setState(() => isLoading = false);
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg), backgroundColor: Colors.red));
  }

  void _cekJawaban(String jawabanUser) {
    String jawabanBenar = soalList[currentIndex]['jawaban_benar'];
    bool isCorrect = (jawabanUser == jawabanBenar);

    riwayatJawabanUser.add({
      'soal': soalList[currentIndex]['teks_ayat'],
      'jawaban_user': soalList[currentIndex]['pilihan_${jawabanUser.toLowerCase()}'],
      'jawaban_benar': soalList[currentIndex]['pilihan_${jawabanBenar.toLowerCase()}'],
      'is_correct': isCorrect.toString(),
    });

    if (isCorrect) {
      _playSFX('audio/correct.wav');
      correctAnswers++;
    } else {
      _playSFX('audio/wrong.wav');
    }

    setState(() {
      if (currentIndex < soalList.length - 1) {
        currentIndex++;
      } else {
        _timer?.cancel();
        _showGameFinished();
      }
    });
  }

  Future<void> _syncToDatabase(int finalScore) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String idUser = prefs.getString('id_user') ?? prefs.getInt('id_user')?.toString() ?? "";

    if (idUser.isEmpty) return;

    try {
      await http.post(
          Uri.parse('https://hafizlab.my.id/api/update_progress.php'),
          body: {"id_user": idUser, "level_selesai": widget.judulLevel, "score": finalScore.toString()}
      );
    } catch (e) {
      // Silent error for production
    }
  }

  void _showGameFinished() async {
    _bgmPlayer.stop();
    _timerSfxPlayer.stop();

    int finalScore = currentScore;
    double percentage = soalList.isNotEmpty ? (correctAnswers / soalList.length) : 0.0;
    int starsEarned = percentage >= 1.0 ? 3 : (percentage >= 0.6 ? 2 : (percentage >= 0.3 ? 1 : 0));

    SharedPreferences prefs = await SharedPreferences.getInstance();
    if (starsEarned > 0) {
      List<String> completedLevels = prefs.getStringList('completed_levels') ?? [];
      if (!completedLevels.contains(widget.judulLevel)) {
        completedLevels.add(widget.judulLevel);
        await prefs.setStringList('completed_levels', completedLevels);
      }
      if (starsEarned > (prefs.getInt('stars_${widget.judulLevel}') ?? 0)) {
        await prefs.setInt('stars_${widget.judulLevel}', starsEarned);
      }
    }

    _syncToDatabase(finalScore);

    if (mounted) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => ReviewScreen(
            judulLevel: widget.judulLevel,
            score: finalScore,
            stars: starsEarned,
            riwayatJawaban: riwayatJawabanUser,
          ),
        ),
      );
    }
  }

  String get timerText {
    int minutes = _timeLeft ~/ 60;
    int seconds = _timeLeft % 60;
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    bool isDarkMode = Theme.of(context).brightness == Brightness.dark;
    return Scaffold(
      backgroundColor: Colors.black, // <--- BIKIN AMAN BIAR GAK TEMBUS LAYAR HITAM ANEH
      appBar: AppBar(
        title: widget.timeLimit > 0
            ? Row(mainAxisSize: MainAxisSize.min, children: [Icon(Icons.timer, color: _timeLeft <= 30 ? Colors.red : Colors.white), const SizedBox(width: 5), Text(timerText, style: TextStyle(fontWeight: FontWeight.bold, color: _timeLeft <= 30 ? Colors.red : Colors.white, fontSize: 18))])
            : Text(isLoading ? 'Loading...' : widget.judulLevel, style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white, fontSize: 18)),
        backgroundColor: const Color(0xFF0A2647).withOpacity(0.8),
        elevation: 0,
        centerTitle: true,
        leading: IconButton(icon: Image.asset('assets/icons/back.png', width: 25, height: 25), onPressed: () => Navigator.pop(context)),
        actions: [Center(child: Padding(padding: const EdgeInsets.only(right: 20), child: Text('Skor: $currentScore', style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.amber, fontSize: 16))))],
      ),
      body: Container(
        width: double.infinity, // <--- FIX BACKGROUND KEPOTONG
        height: double.infinity, // <--- FIX BACKGROUND KEPOTONG
        decoration: const BoxDecoration(image: DecorationImage(image: AssetImage('assets/images/gameplay_bg.jpeg'), fit: BoxFit.cover)),
        child: isLoading
            ? const Center(child: CircularProgressIndicator(color: Colors.amber))
            : soalList.isEmpty
            ? const Center(child: Text("Gagal memuat soal!", style: TextStyle(color: Colors.white)))
            : _buildGameplayUI(isDarkMode),
      ),
    );
  }

  Widget _buildGameplayUI(bool isDarkMode) {
    var soalSekarang = soalList[currentIndex];
    Color cardColor = isDarkMode ? const Color(0xFF1A3B66) : Colors.white;
    Color textColor = isDarkMode ? Colors.white : Colors.black87;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(color: cardColor, borderRadius: BorderRadius.circular(20)),
            child: Column(
              children: [
                Text('Lanjutkan Ayat: (${currentIndex + 1}/${soalList.length})', style: const TextStyle(color: Colors.grey, fontWeight: FontWeight.bold)),
                const SizedBox(height: 10),
                Text(soalSekarang['teks_ayat'], textAlign: TextAlign.center, style: TextStyle(fontSize: 32, fontWeight: FontWeight.normal, fontFamily: 'Arial', height: 2, color: textColor)),
              ],
            ),
          ),
          const SizedBox(height: 30),
          DragTarget<String>(
            builder: (context, candidateData, rejectedData) => Container(
              height: 120,
              decoration: BoxDecoration(color: candidateData.isNotEmpty ? Colors.amber.withOpacity(0.5) : Colors.black45, border: Border.all(color: Colors.amber, width: 2), borderRadius: BorderRadius.circular(15)),
              child: const Center(child: Text('Seret lanjutan ayat ke sini', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold))),
            ),
            onWillAccept: (data) => true,
            onAccept: (data) => _cekJawaban(data),
          ),
          const SizedBox(height: 30),
          const Text('Pilihan Jawaban:', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, shadows: [Shadow(color: Colors.black, blurRadius: 5)])),
          const SizedBox(height: 15),
          _buildDraggableItem('A', soalSekarang['pilihan_a'], cardColor, textColor),
          const SizedBox(height: 10),
          _buildDraggableItem('B', soalSekarang['pilihan_b'], cardColor, textColor),
          const SizedBox(height: 10),
          _buildDraggableItem('C', soalSekarang['pilihan_c'], cardColor, textColor),
        ],
      ),
    );
  }

  Widget _buildDraggableItem(String keyJawaban, String teksAyat, Color cardColor, Color textColor) {
    return Draggable<String>(
      data: keyJawaban,
      feedback: Material(
        color: Colors.transparent,
        child: Container(
            width: MediaQuery.of(context).size.width - 40,
            padding: const EdgeInsets.all(15),
            decoration: BoxDecoration(
                color: Colors.amber,
                borderRadius: BorderRadius.circular(15)
            ),
            child: Text(
                teksAyat,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 26,
                  color: Colors.black,
                  fontFamily: 'Arial',
                  fontWeight: FontWeight.normal,
                  decoration: TextDecoration.none,
                  height: 1.8, // <--- FIX FONT & HARAKAT KEPOTONG SAAT DRAG
                )
            )
        ),
      ),
      childWhenDragging: Opacity(opacity: 0.3, child: _pilihanCard(teksAyat, cardColor, textColor)),
      child: _pilihanCard(teksAyat, cardColor, textColor),
    );
  }

  Widget _pilihanCard(String teksAyat, Color cardColor, Color textColor) {
    return Container(
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(color: cardColor.withOpacity(0.95), borderRadius: BorderRadius.circular(15)),
      child: Text(
          teksAyat,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 26,
            fontWeight: FontWeight.normal,
            fontFamily: 'Arial',
            color: textColor,
            height: 1.8, // <--- FIX HARAKAT KEPOTONG DI KOTAK PILIHAN BAWAH
          )
      ),
    );
  }
}