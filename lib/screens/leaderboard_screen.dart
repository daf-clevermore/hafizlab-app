import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:audioplayers/audioplayers.dart';
import '../main.dart';

class LeaderboardScreen extends StatefulWidget {
  const LeaderboardScreen({super.key});

  @override
  State<LeaderboardScreen> createState() => _LeaderboardScreenState();
}

class _LeaderboardScreenState extends State<LeaderboardScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  List<dynamic> leaderboardData = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _tabController.addListener(() {
      if (!_tabController.indexIsChanging) {
        _playSFX('audio/click.wav');
        _fetchLeaderboard(_getKategori(_tabController.index));
      }
    });
    _fetchLeaderboard('campaign');
  }

  void _playSFX(String path) async {
    if (!sfxNotifier.value) return;
    AudioPlayer player = AudioPlayer();
    await player.play(AssetSource(path));
    player.onPlayerComplete.listen((_) => player.dispose());
  }

  String _getKategori(int index) {
    if (index == 0) return 'campaign';
    if (index == 1) return 'tebak_surah';
    return 'tebak_ayat';
  }

  Future<void> _fetchLeaderboard(String kategori) async {
    if (!mounted) return;
    setState(() => isLoading = true);
    
    try {
      var url = Uri.parse('https://hafizlab.my.id/api/get_leaderboard.php?kategori=$kategori');
      var response = await http.get(url);

      if (response.statusCode == 200) {
        var jsonResponse = json.decode(response.body);
        if (jsonResponse['status'] == 'success' && mounted) {
          setState(() {
            leaderboardData = jsonResponse['data'];
            isLoading = false;
          });
        }
      }
    } catch (e) {
      debugPrint("Error Leaderboard: $e");
      if (mounted) {
        setState(() => isLoading = false);
      }
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    bool isDarkMode = Theme.of(context).brightness == Brightness.dark;
    Color cardColor = isDarkMode ? const Color(0xFF11325A).withOpacity(0.9) : Colors.white.withOpacity(0.95);

    return Scaffold(
      backgroundColor: Colors.transparent,
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: const Text('Papan Peringkat 🏆', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
        backgroundColor: const Color(0xFF0A2647).withOpacity(0.8),
        elevation: 0,
        centerTitle: true,
        automaticallyImplyLeading: false,
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.amber,
          indicatorWeight: 4,
          labelColor: Colors.amber,
          unselectedLabelColor: Colors.grey.shade400,
          tabs: const [
            Tab(text: "PETUALANGAN"),
            Tab(text: "SURAH"),
            Tab(text: "AYAT"),
          ],
        ),
      ),
      body: Container(
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/images/leaderboard.jpeg'),
            fit: BoxFit.cover,
          ),
        ),
        child: SafeArea(
          child: isLoading
              ? const Center(child: CircularProgressIndicator(color: Colors.amber))
              : leaderboardData.isEmpty
                  ? Center(
                      child: Text(
                        "Belum ada data skor 😔",
                        style: TextStyle(
                          color: isDarkMode ? Colors.white70 : Colors.black87,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.all(20),
                      itemCount: leaderboardData.length,
                      itemBuilder: (context, index) {
                        var data = leaderboardData[index];
                        int rank = index + 1;

                        Color rankColor;
                        Widget rankWidget;

                        if (rank == 1) {
                          rankColor = Colors.amber.shade400.withOpacity(0.95);
                          rankWidget = Image.asset('assets/icons/#1.png', width: 35, height: 35);
                        } else if (rank == 2) {
                          rankColor = Colors.grey.shade300.withOpacity(0.95);
                          rankWidget = Image.asset('assets/icons/#2.png', width: 35, height: 35);
                        } else if (rank == 3) {
                          rankColor = Colors.orange.shade300.withOpacity(0.95);
                          rankWidget = Image.asset('assets/icons/#3.png', width: 35, height: 35);
                        } else {
                          rankColor = cardColor;
                          rankWidget = Text(
                            '#$rank',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                              color: isDarkMode ? Colors.white70 : Colors.black54,
                            ),
                          );
                        }

                        return Container(
                          margin: const EdgeInsets.only(bottom: 12),
                          padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 12),
                          decoration: BoxDecoration(
                            color: rank <= 3 ? rankColor : cardColor,
                            borderRadius: BorderRadius.circular(15),
                            boxShadow: rank <= 3
                                ? [BoxShadow(color: Colors.amber.withOpacity(0.3), blurRadius: 8, offset: const Offset(0, 3))]
                                : [const BoxShadow(color: Colors.black12, blurRadius: 5)],
                          ),
                          child: Row(
                            children: [
                              SizedBox(width: 45, child: Center(child: rankWidget)),
                              const SizedBox(width: 10),
                              CircleAvatar(
                                backgroundColor: rank <= 3 ? Colors.white54 : Colors.amber.shade100,
                                backgroundImage: (data['avatar'] != null && data['avatar'].toString().isNotEmpty)
                                    ? AssetImage(data['avatar'])
                                    : const AssetImage('assets/avatar/user.png'),
                              ),
                              const SizedBox(width: 15),
                              Expanded(
                                child: Text(
                                  data['nama'],
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: rank <= 3 ? Colors.black87 : (isDarkMode ? Colors.white : Colors.black87),
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              Text(
                                data['skor'].toString(),
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: rank <= 3 ? Colors.black87 : Colors.amber.shade700,
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
        ),
      ),
    );
  }
}