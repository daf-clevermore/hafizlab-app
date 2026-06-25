import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:audioplayers/audioplayers.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../main.dart';
import 'review_screen.dart';

class KuisGameplayScreen extends StatefulWidget {
  final int juzId;
  final String tipeKuis;
  final bool isEndless;

  const KuisGameplayScreen({
    super.key,
    required this.juzId,
    required this.tipeKuis,
    required this.isEndless
  });

  @override
  State<KuisGameplayScreen> createState() => _KuisGameplayScreenState();
}

class _KuisGameplayScreenState extends State<KuisGameplayScreen> with WidgetsBindingObserver {
  List<Map<String, dynamic>> soalList = [];
  int currentIndex = 0;
  int skor = 0;
  late int nyawa;
  int maxSoal = 0;
  bool isLoading = true;
  List<Map<String, String>> riwayatJawabanUser = [];

  final AudioPlayer _sfxPlayer = AudioPlayer();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    nyawa = widget.isEndless ? 1 : 3;
    maxSoal = widget.isEndless ? 9999 : 30;
    _fetchKuisData();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _sfxPlayer.dispose();
    super.dispose();
  }

  void _playSFX(String path) async {
    if (!sfxNotifier.value) return;
    await _sfxPlayer.play(AssetSource(path));
  }

  Future<void> _fetchKuisData() async {
    try {
      int startSurah = 78;
      int endSurah = 114;

      List<Future<http.Response>> requests = [];
      for (int i = startSurah; i <= endSurah; i++) {
        requests.add(http.get(Uri.parse('https://equran.id/api/v2/surat/$i')));
      }
      var responses = await Future.wait(requests);

      List<Map<String, dynamic>> rawAyatList = [];
      List<String> listSemuaNamaSurah = [];
      List<String> listSemuaTeksAyat = [];

      for (var response in responses) {
        if (response.statusCode == 200) {
          var data = json.decode(response.body)['data'];
          String namaSurah = data['namaLatin'];
          listSemuaNamaSurah.add(namaSurah);

          List<dynamic> ayatArray = data['ayat'];
          for (var ayat in ayatArray) {
            String teksArab = ayat['teksArab'];
            int nomorAyat = ayat['nomorAyat'];
            listSemuaTeksAyat.add(teksArab);

            rawAyatList.add({
              'nama_surah': namaSurah,
              'nomor_ayat': nomorAyat,
              'teks_arab': teksArab,
            });
          }
        }
      }

      rawAyatList.shuffle();
      List<Map<String, dynamic>> kumpulanSoal = [];

      int limitSoal = widget.isEndless ? rawAyatList.length : maxSoal;
      if (limitSoal > rawAyatList.length) limitSoal = rawAyatList.length;

      for (int i = 0; i < limitSoal; i++) {
        var dataAyat = rawAyatList[i];
        String pertanyaan = "";
        String kunciJawaban = "";
        List<String> pilihanGanda = [];

        if (widget.tipeKuis == 'tebak_surah') {
          pertanyaan = dataAyat['teks_arab'];
          kunciJawaban = dataAyat['nama_surah'];

          listSemuaNamaSurah.shuffle();
          var traps = listSemuaNamaSurah.where((s) => s != kunciJawaban).take(3).toList();
          pilihanGanda = [kunciJawaban, ...traps];

        } else {
          pertanyaan = "Surah ${dataAyat['nama_surah']}\nAyat ke-${dataAyat['nomor_ayat']} berbunyi...";
          kunciJawaban = dataAyat['teks_arab'];

          listSemuaTeksAyat.shuffle();
          var traps = listSemuaTeksAyat.where((a) => a != kunciJawaban).take(3).toList();
          pilihanGanda = [kunciJawaban, ...traps];
        }

        pilihanGanda.shuffle();

        kumpulanSoal.add({
          'pertanyaan': pertanyaan,
          'jawaban_benar': kunciJawaban,
          'pilihan': pilihanGanda,
        });
      }

      if (!mounted) return;
      setState(() {
        soalList = kumpulanSoal;
        maxSoal = limitSoal;
        isLoading = false;
      });

    } catch (e) {
      if (!mounted) return;
      setState(() => isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error koneksi: $e"), backgroundColor: Colors.red),
      );
    }
  }

  void _cekJawaban(String jawabanUser) {
    var soalSekarang = soalList[currentIndex];
    String jawabanBenar = soalSekarang['jawaban_benar'];
    bool isCorrect = (jawabanUser == jawabanBenar);

    riwayatJawabanUser.add({
      'soal': soalSekarang['pertanyaan'],
      'jawaban_user': jawabanUser,
      'jawaban_benar': jawabanBenar,
      'is_correct': isCorrect.toString(),
    });

    if (isCorrect) {
      _playSFX('audio/correct.wav');
      skor += 10;

      setState(() {
        if (currentIndex < soalList.length - 1) {
          currentIndex++;
        } else {
          _selesaiKuis();
        }
      });
    } else {
      _playSFX('audio/wrong.wav');
      setState(() {
        nyawa--;
        if (nyawa <= 0) {
          _selesaiKuis();
        } else {
          if (currentIndex < soalList.length - 1) {
            currentIndex++;
          } else {
            _selesaiKuis();
          }
        }
      });
    }
  }

  void _selesaiKuis() async {
    if (widget.isEndless) {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String keyLocal = 'highscore_${widget.tipeKuis}';
      int currentHighscore = prefs.getInt(keyLocal) ?? 0;

      if (skor > currentHighscore) {
        await prefs.setInt(keyLocal, skor);
      }

      String idUser = prefs.getString('id_user') ?? prefs.getInt('id_user')?.toString() ?? "";
      if (idUser.isEmpty) {
        idUser = prefs.getString('id') ?? prefs.getInt('id')?.toString() ?? "";
      }

      if (idUser.isNotEmpty) {
        http.post(
          Uri.parse('https://hafizlab.my.id/api/update_highscore.php'),
          body: {
            "id_user": idUser,
            "tipe_kuis": widget.tipeKuis,
            "score": skor.toString(),
          }
        ).then((response) {
          debugPrint("Backend Highscore tersimpan!");
        }).catchError((e) {
          debugPrint("Gagal nge-push highscore: $e");
        });
      }
    }

    String judulReview = widget.isEndless ? "Mode Tanpa Batas (Juz ${widget.juzId})" : "Kuis Terbatas (Juz ${widget.juzId})";

    if (mounted) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => ReviewScreen(
            judulLevel: judulReview,
            score: skor,
            stars: nyawa > 0 ? 3 : 1,
            riwayatJawaban: riwayatJawabanUser,
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    bool isDarkMode = Theme.of(context).brightness == Brightness.dark;
    Color textColor = isDarkMode ? Colors.white : Colors.black87;
    String modeTitle = widget.isEndless ? "Tanpa Batas" : "Terbatas";

    return Scaffold(
      backgroundColor: Colors.transparent,
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: Text(isLoading ? 'Mempersiapkan Soal...' : modeTitle, style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
        backgroundColor: const Color(0xFF0A2647).withOpacity(0.8),
        elevation: 0,
        centerTitle: true,
        leading: IconButton(icon: Image.asset('assets/icons/back.png', width: 25, height: 25), onPressed: () => Navigator.pop(context)),
      ),
      body: Container(
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/images/kuis_bg.png'),
            fit: BoxFit.cover,
          ),
        ),
        child: isLoading
            ? const Center(child: CircularProgressIndicator(color: Colors.amber))
            : SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 8),
                      decoration: BoxDecoration(color: Colors.amber.shade700, borderRadius: BorderRadius.circular(20)),
                      child: Text('Skor: $skor', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
                    ),
                    Row(
                      children: List.generate(widget.isEndless ? 1 : 3, (index) {
                        return Icon(index < nyawa ? Icons.favorite : Icons.favorite_border, color: Colors.redAccent, size: 30);
                      }),
                    )
                  ],
                ),
                const SizedBox(height: 30),

                Text(widget.isEndless ? 'Uji Ketahanan: ${currentIndex + 1}' : 'Soal ${currentIndex + 1} / $maxSoal', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, shadows: [Shadow(blurRadius: 5, color: Colors.black)]), textAlign: TextAlign.center),
                const SizedBox(height: 10),
                Container(
                  padding: const EdgeInsets.all(30),
                  decoration: BoxDecoration(
                    color: isDarkMode ? const Color(0xFF11325A).withOpacity(0.9) : Colors.white.withOpacity(0.95),
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 10, offset: Offset(0, 5))],
                    border: Border.all(color: widget.isEndless ? Colors.red.shade900 : Colors.green.shade600, width: 2),
                  ),
                  child: Column(
                    children: [
                      Text(widget.tipeKuis == 'tebak_surah' ? 'Ayat ini berasal dari Surah apa?' : 'Lanjutkan bacaan berikut:', style: const TextStyle(color: Colors.grey, fontSize: 14)),
                      const SizedBox(height: 20),
                      Text(
                        soalList[currentIndex]['pertanyaan'],
                        textAlign: TextAlign.center,
                        style: TextStyle(
                            fontSize: widget.tipeKuis == 'tebak_surah' ? 32 : 22,
                            fontWeight: FontWeight.normal,
                            fontFamily: widget.tipeKuis == 'tebak_surah' ? 'Arial' : 'Fredoka',
                            height: 2,
                            color: textColor
                        ),
                      ),
                    ],
                  ),
                ),
                const Spacer(),

                Expanded(
                  flex: 2,
                  child: ListView.builder(
                      itemCount: 4,
                      itemBuilder: (context, index) {
                        String opsi = soalList[currentIndex]['pilihan'][index];
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 20),
                              backgroundColor: isDarkMode ? const Color(0xFF1A3B66).withOpacity(0.9) : Colors.white.withOpacity(0.95),
                              foregroundColor: textColor,
                              elevation: 2,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15), side: BorderSide(color: Colors.grey.shade300)),
                            ),
                            onPressed: () => _cekJawaban(opsi),
                            child: Text(
                                opsi,
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontSize: widget.tipeKuis == 'tebak_ayat' ? 24 : 18,
                                  fontWeight: FontWeight.normal,
                                  fontFamily: widget.tipeKuis == 'tebak_ayat' ? 'Arial' : 'Fredoka',
                                )
                            ),
                          ),
                        );
                      }
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}