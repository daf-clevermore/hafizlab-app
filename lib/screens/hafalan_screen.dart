import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:audioplayers/audioplayers.dart';
import '../main.dart';
import 'detail_hafalan_screen.dart';

class HafalanScreen extends StatefulWidget {
  const HafalanScreen({super.key});

  @override
  State<HafalanScreen> createState() => _HafalanScreenState();
}

class _HafalanScreenState extends State<HafalanScreen> {
  List<dynamic> listSurah = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchSurah();
  }

  void _playSFX() async {
    if (!sfxNotifier.value) return;
    AudioPlayer player = AudioPlayer();
    await player.play(AssetSource('audio/click.wav'));
    player.onPlayerComplete.listen((_) => player.dispose());
  }

  Future<void> _fetchSurah() async {
    try {
      var url = Uri.parse('https://equran.id/api/v2/surat');
      var response = await http.get(url);

      if (response.statusCode == 200) {
        var data = json.decode(response.body);
        setState(() {
          listSurah = data['data'];
          isLoading = false;
        });
      }
    } catch (e) {
      setState(() => isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Gagal memuat API eQuran!')));
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
        title: const Text('Daftar Surah 📖', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
        backgroundColor: const Color(0xFF0A2647),
        elevation: 0,
        centerTitle: true,
        automaticallyImplyLeading: false,
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator(color: Colors.amber))
          : ListView.builder(
        padding: const EdgeInsets.all(20),
        itemCount: listSurah.length,
        itemBuilder: (context, index) {
          var surah = listSurah[index];
          return Container(
            margin: const EdgeInsets.only(bottom: 12),
            decoration: BoxDecoration(
              color: cardColor,
              borderRadius: BorderRadius.circular(15),
              boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 5)],
            ),
            child: ListTile(
              contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              leading: Container(
                width: 45,
                height: 45,
                decoration: const BoxDecoration(
                  image: DecorationImage(image: AssetImage('assets/icons/surah.png'), fit: BoxFit.cover),
                ),
                child: Center(
                  child: Text(surah['nomor'].toString(), style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.black87, fontSize: 14)),
                ),
              ),
              title: Text(surah['namaLatin'], style: TextStyle(fontWeight: FontWeight.bold, color: textColor, fontSize: 16)),
              subtitle: Text('${surah['tempatTurun']} • ${surah['jumlahAyat']} Ayat', style: const TextStyle(color: Colors.grey, fontSize: 12)),
              trailing: Text(surah['nama'], style: const TextStyle(color: Colors.amber, fontFamily: 'Uthmanic', fontSize: 24, fontWeight: FontWeight.bold)),
              onTap: () {
                _playSFX();
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => DetailHafalanScreen(
                      nomorSurah: surah['nomor'],
                      namaSurah: surah['namaLatin'],
                    ),
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }
}