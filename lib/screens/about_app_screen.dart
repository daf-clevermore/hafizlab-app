import 'package:flutter/material.dart';

class AboutAppScreen extends StatelessWidget {
  const AboutAppScreen({super.key});

  @override
  Widget build(BuildContext context) {
    bool isDarkMode = Theme.of(context).brightness == Brightness.dark;
    Color textColor = isDarkMode ? Colors.white70 : Colors.black87;
    Color titleColor = isDarkMode ? Colors.white : Colors.black;

    return Scaffold(
      backgroundColor: isDarkMode ? const Color(0xFF0A2647) : Colors.white,
      appBar: AppBar(
        title: const Text('Tentang Aplikasi', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: titleColor,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Image.asset('assets/images/hafizlab_text.png', height: 80),
            const SizedBox(height: 10),
            const Text("Versi 1.0.0", style: TextStyle(color: Colors.grey, fontWeight: FontWeight.bold)),
            const SizedBox(height: 30),
            Text(
              "HafizLab adalah aplikasi edukasi yang dirancang untuk membantu anak-anak dan pengguna umum dalam belajar Al-Qur’an dengan cara yang lebih menyenangkan, interaktif, dan mudah dipahami.\n\n"
                  "Aplikasi ini menggabungkan konsep belajar sambil bermain (learning by playing) agar pengguna tidak hanya menghafal, tetapi juga memahami dan mencintai Al-Qur’an sejak dini.\n\n"
                  "🌟 Fitur Utama HafizLab\n"
                  "• Belajar menghafal secara bertahap dan terstruktur\n"
                  "• Game edukasi Islami untuk meningkatkan motivasi belajar\n"
                  "• Latihan hafalan interaktif\n"
                  "• Mode anak-anak yang aman dan ramah pengguna\n"
                  "• Progress belajar untuk memantau perkembangan hafalan\n"
                  "• Audio bacaan yang jelas dan tartil\n\n"
                  "🎯 Tujuan Aplikasi\n"
                  "• Membantu anak-anak lebih mudah menghafal Al-Qur’an\n"
                  "• Menjadikan proses belajar lebih menyenangkan\n"
                  "• Meningkatkan kecintaan terhadap Al-Qur’an sejak usia dini\n"
                  "• Mendukung orang tua dan guru dalam proses pembelajaran\n\n"
                  "👥 Siapa yang Bisa Menggunakan?\n"
                  "• Anak-anak (pemula belajar Al-Qur’an)\n"
                  "• Pelajar sekolah\n"
                  "• Orang tua yang ingin mendampingi anak belajar\n"
                  "• Siapa saja yang ingin memperbaiki hafalan.\n\n"
                  "🛡️ Komitmen Kami\n"
                  "Kami berkomitmen untuk menghadirkan aplikasi yang edukatif, aman untuk anak, bebas dari konten yang tidak sesuai, dan terus dikembangkan agar semakin bermanfaat.",
              style: TextStyle(fontSize: 15, height: 1.6, color: textColor),
              textAlign: TextAlign.justify,
            ),
            const SizedBox(height: 40),
            const Text("Dibuat dengan ❤️ untuk generasi Qur'ani", style: TextStyle(color: Colors.grey, fontStyle: FontStyle.italic)),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}