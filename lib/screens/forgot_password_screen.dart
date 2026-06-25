import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _otpController = TextEditingController();
  final TextEditingController _newPasswordController = TextEditingController();

  bool isOtpSent = false;

  Future<void> _requestOTP() async {
    if (_emailController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Isi emailnya dulu!')));
      return;
    }
    showDialog(context: context, barrierDismissible: false, builder: (context) => const Center(child: CircularProgressIndicator()));
    try {
      var url = Uri.parse('https://hafizlab.my.id/api/request_otp.php');
      var response = await http.post(url, body: {"email": _emailController.text});
      if (mounted) Navigator.pop(context);
      if (response.statusCode == 200) {
        var data = json.decode(response.body);
        if (data['status'] == 'success') {
          setState(() { isOtpSent = true; });
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(data['message']), backgroundColor: Colors.green));
        } else {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(data['message']), backgroundColor: Colors.red));
        }
      }
    } catch (e) {
      if (mounted) Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
    }
  }

  Future<void> _resetPassword() async {
    if (_otpController.text.isEmpty || _newPasswordController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Isi OTP dan Sandi baru!')));
      return;
    }
    showDialog(context: context, barrierDismissible: false, builder: (context) => const Center(child: CircularProgressIndicator()));
    try {
      var url = Uri.parse('https://hafizlab.my.id/api/reset_password.php');
      var response = await http.post(url, body: {"email": _emailController.text, "otp": _otpController.text, "new_password": _newPasswordController.text});
      if (mounted) Navigator.pop(context);
      if (response.statusCode == 200) {
        var data = json.decode(response.body);
        if (data['status'] == 'success') {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(data['message']), backgroundColor: Colors.green));
          if (mounted) Navigator.pop(context);
        } else {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(data['message']), backgroundColor: Colors.red));
        }
      }
    } catch (e) {
      if (mounted) Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    bool isDarkMode = Theme.of(context).brightness == Brightness.dark;
    Color cardColor = isDarkMode ? const Color(0xFF11325A).withOpacity(0.95) : Colors.white.withOpacity(0.95);
    Color textColor = isDarkMode ? Colors.white : Colors.black87;
    Color hintColor = isDarkMode ? Colors.white54 : Colors.grey;
    Color borderColor = isDarkMode ? Colors.white24 : Colors.grey.shade400;

    return Scaffold(
      backgroundColor: Colors.transparent,
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Image.asset('assets/icons/back.png', width: 25, height: 25, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/images/splash.jpeg'),
            fit: BoxFit.cover,
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              Expanded(
                flex: 3,
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const SizedBox(height: 40),
                      const Text('Lupa Sandi?', style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.amber)),
                      const SizedBox(height: 15),
                      Image.asset('assets/images/hafiz_reading.png', height: 160),
                    ],
                  ),
                ),
              ),
              Expanded(
                flex: 7,
                child: Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: cardColor,
                    borderRadius: const BorderRadius.only(topLeft: Radius.circular(30), topRight: Radius.circular(30)),
                  ),
                  child: SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        if (!isOtpSent) ...[
                          Text('Masukkan email kamu.\nKita bakal kirim kode OTP ke sana.', textAlign: TextAlign.center, style: TextStyle(color: textColor, fontSize: 16)),
                          const SizedBox(height: 25),
                          TextField(
                            controller: _emailController,
                            style: TextStyle(color: textColor),
                            decoration: InputDecoration(
                              prefixIcon: Icon(Icons.email_outlined, color: hintColor),
                              hintText: 'Email Terdaftar',
                              hintStyle: TextStyle(color: hintColor),
                              enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(15), borderSide: BorderSide(color: borderColor)),
                              focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(15), borderSide: const BorderSide(color: Colors.amber, width: 2)),
                            ),
                          ),
                          const SizedBox(height: 25),
                          ElevatedButton(
                              onPressed: _requestOTP,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.amber.shade600,
                                padding: const EdgeInsets.symmetric(vertical: 15),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                              ),
                              child: const Text('Kirim OTP', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white))
                          ),
                        ]
                        else ...[
                          const Text('Cek inbox email kamu sekarang!', textAlign: TextAlign.center, style: TextStyle(color: Colors.green, fontWeight: FontWeight.bold, fontSize: 16)),
                          const SizedBox(height: 25),
                          TextField(
                            controller: _otpController,
                            keyboardType: TextInputType.number,
                            style: TextStyle(color: textColor),
                            decoration: InputDecoration(
                              prefixIcon: Icon(Icons.pin_outlined, color: hintColor),
                              hintText: 'Masukkan 6 Digit OTP',
                              hintStyle: TextStyle(color: hintColor),
                              enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(15), borderSide: BorderSide(color: borderColor)),
                              focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(15), borderSide: const BorderSide(color: Colors.amber, width: 2)),
                            ),
                          ),
                          const SizedBox(height: 15),
                          TextField(
                            controller: _newPasswordController,
                            obscureText: true,
                            style: TextStyle(color: textColor),
                            decoration: InputDecoration(
                              prefixIcon: Icon(Icons.lock_outline, color: hintColor),
                              hintText: 'Kata Sandi Baru',
                              hintStyle: TextStyle(color: hintColor),
                              enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(15), borderSide: BorderSide(color: borderColor)),
                              focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(15), borderSide: const BorderSide(color: Colors.amber, width: 2)),
                            ),
                          ),
                          const SizedBox(height: 25),
                          ElevatedButton(
                            onPressed: _resetPassword,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.green,
                              padding: const EdgeInsets.symmetric(vertical: 15),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                            ),
                            child: const Text('Update Sandi', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
                          ),
                        ]
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}