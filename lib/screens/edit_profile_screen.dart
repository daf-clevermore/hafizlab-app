import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart'as http;

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final TextEditingController _nameController = TextEditingController();

  final List<String> listAvatar = [
    'assets/avatar/ahmad.png',
    'assets/avatar/azhar.png',
    'assets/avatar/aziz.png',
    'assets/avatar/azizah.png',
    'assets/avatar/erine.png',
    'assets/avatar/fatih.png',
    'assets/avatar/fatimah.png',
    'assets/avatar/ghozali.png',
    'assets/avatar/ilyasa.png',
    'assets/avatar/iqbal.png',
    'assets/avatar/khadafi.png',
    'assets/avatar/panda.png',
    'assets/avatar/rafif.png',
    'assets/avatar/robot.png',
    'assets/avatar/singa.png',
    'assets/avatar/siti.png',
    'assets/avatar/thoras.png',
    'assets/avatar/user.png',
    'assets/avatar/yusuf.png',
    'assets/avatar/zahra.png',
  ];

  String selectedAvatar = 'assets/avatar/user.png';

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      _nameController.text = prefs.getString('nama_user') ?? "Guest";
      selectedAvatar = prefs.getString('avatar_user') ?? listAvatar[0];
    });
  }

  Future<void> _saveProfile() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String idUser = prefs.getString('id_user') ?? "";

    if (idUser.isNotEmpty) {
      try {
        var url = Uri.parse('https://hafizlab.my.id/api/update_profile.php');
        await http.post(url, body: {
          "id_user": idUser,
          "nama": _nameController.text,
          "avatar": selectedAvatar,
        });
      } catch (e) {
        debugPrint("Gagal update DB: $e");
      }
    }

 
    await prefs.setString('nama_user', _nameController.text);
    await prefs.setString('avatar_user', selectedAvatar);

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Profil berhasil diperbarui!'), backgroundColor: Colors.green));
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    bool isDarkMode = Theme.of(context).brightness == Brightness.dark;
    Color textColor = isDarkMode ? Colors.white : Colors.black87;

    return Scaffold(
      backgroundColor: isDarkMode ? const Color(0xFF0A2647) : Colors.white,
      appBar: AppBar(
        title: const Text('Profil Saya'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Center(child: Text('Pilih Avatar Kamu!', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold))),
            const SizedBox(height: 20),

            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                  crossAxisSpacing: 15,
                  mainAxisSpacing: 15
              ),
              itemCount: listAvatar.length,
              itemBuilder: (context, index) {
                bool isSelected = selectedAvatar == listAvatar[index];
                return GestureDetector(
                  onTap: () => setState(() => selectedAvatar = listAvatar[index]),
                  child: Container(
                    decoration: BoxDecoration(
                      color: isSelected ? Colors.amber.shade100 : Colors.grey.shade100,
                      border: Border.all(color: isSelected ? Colors.amber : Colors.transparent, width: 3),
                      shape: BoxShape.circle,
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Image.asset(listAvatar[index]),
                    ),
                  ),
                );
              },
            ),

            const SizedBox(height: 40),
            Text('Nama Panggilan', style: TextStyle(color: textColor, fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            TextField(
              controller: _nameController,
              decoration: InputDecoration(
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(15)),
                prefixIcon: const Icon(Icons.person),
              ),
            ),

            const SizedBox(height: 40),
            ElevatedButton(
              onPressed: _saveProfile,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                padding: const EdgeInsets.symmetric(vertical: 15),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
              ),
              child: const Text('Simpan Perubahan', style: TextStyle(fontSize: 16, color: Colors.white, fontWeight: FontWeight.bold)),
            )
          ],
        ),
      ),
    );
  }
}