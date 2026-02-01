import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../pages/login_page.dart';
import '../pages/item_detail_page.dart';

class AppDrawer extends StatefulWidget {
  const AppDrawer({super.key});

  @override
  State<AppDrawer> createState() => _AppDrawerState();
}

class _AppDrawerState extends State<AppDrawer> {
  String? loggedInUser;
  String userRole = 'Guest';
  List<String> recentItems = [];

  @override
  void initState() {
    super.initState();
    loadUserAndRole();
    loadHistory();
  }

  // ============================
  // Ambil user login & role dari Firestore
  // ============================
  Future<void> loadUserAndRole() async {
    final prefs = await SharedPreferences.getInstance();
    final username = prefs.getString('logged_in_user');

    if (username != null) {
      // ambil role dari Firestore
      final doc = await FirebaseFirestore.instance
          .collection('accounts')
          .doc(username)
          .get();

      setState(() {
        loggedInUser = username;
        if (doc.exists) {
          final data = doc.data();
          userRole = data?['role'] ?? 'Editor';
        } else {
          userRole = 'Editor'; // fallback
        }
      });
    } else {
      setState(() {
        loggedInUser = null;
        userRole = 'Guest';
      });
    }
  }

  // ============================
  // Ambil history item (JSON)
  // ============================
  Future<void> loadHistory() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      recentItems = prefs.getStringList('recent_items') ?? [];
    });
  }

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ============================
          // HEADER PROFILE
          // ============================
          UserAccountsDrawerHeader(
            currentAccountPicture: const CircleAvatar(
              child: Icon(Icons.person, size: 32),
            ),
            accountName: Text(loggedInUser ?? "Guest"),
            accountEmail: Text("Role: $userRole"),
          ),

          // ============================
          // MENU AKUN
          // ============================
          ListTile(
            leading: const Icon(Icons.login),
            title: const Text("Halaman Akun"),
            onTap: () async {
              Navigator.pop(context);
              final result = await Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const LoginPage()),
              );

              if (result == true) {
                await loadUserAndRole();
                await loadHistory();
              }
            },
          ),

          const Divider(),

          // ============================
          // HISTORY ITEM
          // ============================
          if (recentItems.isNotEmpty) ...[
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Text(
                "Terakhir Dibuka",
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ),

            ...recentItems.map((jsonItem) {
              final Map<String, dynamic> item =
                  jsonDecode(jsonItem) as Map<String, dynamic>;

              return ListTile(
                leading: const Icon(Icons.history),
                title: Text(item['name'] ?? 'Unknown Item'),
                subtitle: item['tooltip'] != null
                    ? Text(item['tooltip'])
                    : null,
                onTap: () {
                  Navigator.pop(context);

                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => ItemDetailPage(item: item),
                    ),
                  );
                },
              );
            }),

            ListTile(
              leading: const Icon(Icons.delete),
              title: const Text("Hapus Riwayat"),
              onTap: () async {
                final prefs = await SharedPreferences.getInstance();
                await prefs.remove('recent_items');

                setState(() {
                  recentItems.clear();
                });

                Navigator.pop(context);

                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text("Riwayat berhasil dihapus")),
                );
              },
            ),

            const Divider(),
          ] else ...[
            const Padding(
              padding: EdgeInsets.all(16),
              child: Text(
                "Tidak ada halaman yang dibuka sebelumnya",
                style: TextStyle(
                  fontStyle: FontStyle.italic,
                  color: Colors.grey,
                ),
              ),
            ),
          ],

          const Spacer(),

          const Padding(
            padding: EdgeInsets.all(12),
            child: Text("Eco Game Wiki", style: TextStyle(color: Colors.grey)),
          ),
        ],
      ),
    );
  }
}
