import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';
import 'screens/splash_screen.dart';
import 'dart:io';

final ValueNotifier<ThemeMode> themeNotifier = ValueNotifier(ThemeMode.light);
final ValueNotifier<bool> bgmNotifier = ValueNotifier(true);
final ValueNotifier<bool> sfxNotifier = ValueNotifier(true);

class MyHttpOverrides extends HttpOverrides {
  @override
  HttpClient createHttpClient(SecurityContext? context) {
    return super.createHttpClient(context)
      ..badCertificateCallback = (X509Certificate cert, String host, int port) => true;
  }
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final audioContext = AudioContext(
    android: AudioContextAndroid(
      isSpeakerphoneOn: false,
      stayAwake: true,
      contentType: AndroidContentType.sonification,
      usageType: AndroidUsageType.game,
      audioFocus: AndroidAudioFocus.none,
    ),
    iOS: AudioContextIOS(
      category: AVAudioSessionCategory.playback,
      options: {AVAudioSessionOptions.mixWithOthers},
    ),
  );
  await AudioPlayer.global.setAudioContext(audioContext);

  HttpOverrides.global = MyHttpOverrides();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<ThemeMode>(
      valueListenable: themeNotifier,
      builder: (_, ThemeMode currentMode, __) {
        return MaterialApp(
          debugShowCheckedModeBanner: false,
          title: 'HafizLab',

          theme: ThemeData(
            brightness: Brightness.light,
            fontFamily: 'Fredoka',
          ),
          darkTheme: ThemeData(
            brightness: Brightness.dark,
            fontFamily: 'Fredoka',
          ),

          themeMode: currentMode,
          home: const SplashScreen(),
        );
      },
    );
  }
}