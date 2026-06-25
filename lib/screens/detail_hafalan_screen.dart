import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:audioplayers/audioplayers.dart';
import '../main.dart';

class DetailHafalanScreen extends StatefulWidget {
  final int nomorSurah;
  final String namaSurah;

  const DetailHafalanScreen({super.key, required this.nomorSurah, required this.namaSurah});

  @override
  State<DetailHafalanScreen> createState() => _DetailHafalanScreenState();
}

class _DetailHafalanScreenState extends State<DetailHafalanScreen> {
  List<dynamic> listAyat = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
    _fetchDetailSurah();
  }

  @override
  void dispose() {
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual, overlays: SystemUiOverlay.values);
    super.dispose();
  }

  void _playSFX() async {
    if (!sfxNotifier.value) return;
    AudioPlayer player = AudioPlayer();
    await player.play(AssetSource('audio/click.wav'));
    player.onPlayerComplete.listen((_) => player.dispose());
  }

  Future<void> _fetchDetailSurah() async {
    try {
      var url = Uri.parse('https://equran.id/api/v2/surat/${widget.nomorSurah}');
      var response = await http.get(url);

      if (response.statusCode == 200) {
        var data = json.decode(response.body);
        setState(() {
          listAyat = data['data']['ayat'];
          isLoading = false;
        });
      }
    } catch (e) {
      setState(() => isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Gagal memuat data ayat!')));
    }
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
        title: Text('Surah ${widget.namaSurah}', style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
        backgroundColor: const Color(0xFF0A2647),
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: Image.asset('assets/icons/back.png', width: 25, height: 25, color: Colors.white),
          onPressed: () {
            _playSFX();
            Navigator.pop(context);
          },
        ),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator(color: Colors.amber))
          : ListView.builder(
   
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 40),
        itemCount: listAyat.length,
        itemBuilder: (context, index) {
          var ayat = listAyat[index];
          return Container(
            margin: const EdgeInsets.only(bottom: 15),
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: cardColor,
              borderRadius: BorderRadius.circular(15),
              boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 5)],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    CircleAvatar(
                      backgroundColor: Colors.amber.shade100,
                      radius: 15,
                      child: Text(ayat['nomorAyat'].toString(), style: TextStyle(color: Colors.amber.shade800, fontWeight: FontWeight.bold, fontSize: 12)),
                    ),
                    const SizedBox(width: 15),
                    Expanded(
                      child: Text(
                        ayat['teksArab'],
                        textAlign: TextAlign.right,
                        style: TextStyle(fontSize: 26, fontFamily: 'Uthmanic', color: textColor, height: 2),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 15),
                Text(ayat['teksLatin'], style: TextStyle(color: Colors.amber.shade700, fontStyle: FontStyle.italic, fontSize: 14)),
                const SizedBox(height: 5),
                Text(ayat['teksIndonesia'], style: TextStyle(color: isDarkMode ? Colors.white70 : Colors.black54, fontSize: 14)),
              ],
            ),
          );
        },
      ),
    );
  }
}