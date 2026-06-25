import 'package:flutter/material.dart';

class PrivacyPolicyScreen extends StatelessWidget {
  const PrivacyPolicyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    bool isDarkMode = Theme.of(context).brightness == Brightness.dark;
    Color textColor = isDarkMode ? Colors.white70 : Colors.black87;
    Color titleColor = isDarkMode ? Colors.white : Colors.black;

    return Scaffold(
      backgroundColor: isDarkMode ? const Color(0xFF0A2647) : Colors.white,
      appBar: AppBar(
        title: const Text('Kebijakan Privasi', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: titleColor,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Aplikasi HafizLab berkomitmen untuk melindungi privasi pengguna, khususnya anak-anak dan pengguna umum yang menggunakan layanan kami untuk belajar dan bermain edukatif berbasis Al-Qur’an.",
              style: TextStyle(fontSize: 15, height: 1.6, color: textColor),
              textAlign: TextAlign.justify,
            ),
            const SizedBox(height: 20),
            _buildSectionTitle("1. Informasi yang Kami Kumpulkan", titleColor),
            _buildSectionBody(
              "HafizLab dapat mengumpulkan beberapa jenis informasi berikut:\n"
              "• Informasi perangkat (tipe perangkat, sistem operasi, versi aplikasi)\n"
              "• Data penggunaan aplikasi (fitur yang digunakan, durasi, aktivitas belajar)\n"
              "• Informasi akun (nama atau username saat login)\n\n"
              "Kami tidak secara sengaja mengumpulkan informasi pribadi sensitif seperti alamat rumah, nomor identitas, atau data keuangan.",
              textColor,
            ),
            _buildSectionTitle("2. Penggunaan Informasi", titleColor),
            _buildSectionBody(
              "Informasi yang dikumpulkan digunakan untuk:\n"
              "• Meningkatkan kualitas aplikasi HafizLab\n"
              "• Menyediakan pengalaman belajar yang lebih baik dan personal\n"
              "• Memperbaiki bug dan performa aplikasi\n"
              "• Menganalisis penggunaan fitur untuk pengembangan ke depan.",
              textColor,
            ),
            _buildSectionTitle("3. Perlindungan Data", titleColor),
            _buildSectionBody(
              "Kami berusaha melindungi data pengguna dengan langkah-langkah keamanan yang wajar untuk mencegah akses tidak sah, perubahan, atau pengungkapan data.",
              textColor,
            ),
            _buildSectionTitle("4. Privasi Anak", titleColor),
            _buildSectionBody(
              "HafizLab dirancang untuk ramah anak. Kami tidak dengan sengaja mengumpulkan data pribadi anak tanpa izin orang tua atau wali. Jika diketahui ada data yang terkumpul tanpa izin, kami akan segera menghapusnya.",
              textColor,
            ),
            _buildSectionTitle("5. Pembagian Informasi", titleColor),
            _buildSectionBody(
              "Kami tidak menjual, menyewakan, atau memperdagangkan data pengguna kepada pihak ketiga. Informasi hanya dapat dibagikan jika:\n"
              "• Diperlukan oleh hukum\n"
              "• Dibutuhkan untuk meningkatkan layanan melalui penyedia pihak ketiga yang terpercaya (misalnya analitik aplikasi).",
              textColor,
            ),
            _buildSectionTitle("6. Layanan Pihak Ketiga", titleColor),
            _buildSectionBody(
              "Aplikasi mungkin menggunakan layanan pihak ketiga seperti analitik atau penyimpanan data. Setiap pihak ketiga memiliki kebijakan privasi masing-masing yang terpisah.",
              textColor,
            ),
            _buildSectionTitle("7. Perubahan Kebijakan", titleColor),
            _buildSectionBody(
              "Kami dapat memperbarui kebijakan privasi ini dari waktu ke waktu. Perubahan akan diinformasikan melalui pembaruan aplikasi atau pemberitahuan dalam aplikasi.",
              textColor,
            ),
            _buildSectionTitle("8. Kontak Kami", titleColor),
            _buildSectionBody(
              "Jika ada pertanyaan terkait kebijakan privasi ini, Anda dapat menghubungi kami melalui:\n"
              "haidarkadafi78@gmail.com\n"
              "azhar.wicaksono@gmail.com",
              textColor,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title, Color color) {
    return Padding(
      padding: const EdgeInsets.only(top: 16.0, bottom: 8.0),
      child: Text(
        title,
        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: color),
      ),
    );
  }

  Widget _buildSectionBody(String body, Color color) {
    return Text(
      body,
      style: TextStyle(fontSize: 15, height: 1.6, color: color),
      textAlign: TextAlign.justify,
    );
  }
}