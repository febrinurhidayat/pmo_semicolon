import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'absen/absen_page.dart';
import 'history/history_page.dart';
import 'leave/leave_page.dart';
import 'login/login_page.dart'; // Import halaman login yang sesuai dengan aplikasi Anda

class MainPage extends StatelessWidget {
  const MainPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () => _onWillPop(context),
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: const Color(0xFF6C3483),
          title: const Text(
            "Absensi Face ID",
            style: TextStyle(color: Colors.white),
          ),
          centerTitle: true,
          actions: [
            IconButton(
              icon: const Icon(Icons.logout),
              onPressed: () => _showLogoutDialog(context),
            ),
          ],
        ),
        backgroundColor: Colors.white,
        body: SafeArea(
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _buildMenuItem(
                  imageAsset: 'assets/images/ic_absen.png',
                  title: "Absen Kehadiran",
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const AbsenPage()),
                    );
                  },
                ),
                const SizedBox(height: 40),
                _buildMenuItem(
                  imageAsset: 'assets/images/ic_leave.png',
                  title: "Cuti / Izin",
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const LeavePage()),
                    );
                  },
                ),
                const SizedBox(height: 40),
                _buildMenuItem(
                  imageAsset: 'assets/images/ic_history.png',
                  title: "Riwayat Absensi",
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const HistoryPage()),
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildMenuItem({
    required String imageAsset,
    required String title,
    required VoidCallback onTap,
  }) {
    return Container(
      margin: const EdgeInsets.all(10),
      child: Expanded(
        child: InkWell(
          highlightColor: Colors.transparent,
          splashColor: Colors.transparent,
          onTap: onTap,
          child: Column(
            children: [
              Image(
                image: AssetImage(imageAsset),
                height: 100,
                width: 100,
              ),
              const SizedBox(height: 10),
              Text(
                title,
                style:
                    const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<bool> _onWillPop(BuildContext context) async {
    return (await showDialog(
          barrierDismissible: false,
          context: context,
          builder: (context) => AlertDialog(
            title: const Text(
              "INFO",
              style: TextStyle(
                color: Colors.black,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            content: const Text(
              "Apa Anda ingin keluar dari aplikasi?",
              style: TextStyle(color: Colors.black, fontSize: 16),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: const Text(
                  "Batal",
                  style: TextStyle(color: Colors.black, fontSize: 14),
                ),
              ),
              TextButton(
                onPressed: () => SystemNavigator.pop(),
                child: const Text(
                  "Ya",
                  style: TextStyle(color: Color(0xFF6C3483), fontSize: 14),
                ),
              ),
            ],
          ),
        )) ??
        false;
  }

  Future<void> _showLogoutDialog(BuildContext context) async {
    try {
      await FirebaseAuth.instance.signOut();
      Navigator.of(context).pushNamedAndRemoveUntil(
          '/login', (Route<dynamic> route) => false);
    } catch (e) {
      print("Error during logout: $e");
      // Handle error jika terjadi
    }
  }
}
