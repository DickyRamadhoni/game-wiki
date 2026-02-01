import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:rxdart/rxdart.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../widgets/app_drawer.dart';
import 'about_page.dart';
import 'item_detail_page.dart';
import 'login_page.dart';

class WikiHomePage extends StatefulWidget {
  const WikiHomePage({super.key});

  @override
  State<WikiHomePage> createState() => _WikiHomePageState();
}

class _WikiHomePageState extends State<WikiHomePage> {
  final TextEditingController _searchController = TextEditingController();
  String _searchKeyword = '';

  final _itemsCol = FirebaseFirestore.instance.collection('items');
  final _infoCol = FirebaseFirestore.instance.collection('info_pages');

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: const AppDrawer(),
      appBar: AppBar(
        title: const Text("Wiki Homepage"),
        actions: [
          IconButton(
            icon: const Icon(Icons.info_outline),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const AboutPage()),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.person_outline),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const LoginPage()),
              );
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // TITLE & DESCRIPTION
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                Text(
                  "Eco Game Wiki",
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 8),
                Text(
                  'Ensiklopedia item dan informasi seputar game Eco. '
                  'Anda dapat mencari informasi yang dibutuhkan menggunakan search bar dibawah ini (termasuk nama item, info, tooltop, dan deskripsi). '
                  '\n\nJika anda berminat untuk berkontribusi. Silakan login atau daftar akun terlebih dahulu.',
                  style: TextStyle(fontSize: 14),
                ),
              ],
            ),
          ),

          // SEARCH BAR
          Padding(
            padding: const EdgeInsets.all(12),
            child: TextField(
              controller: _searchController,
              decoration: const InputDecoration(
                hintText: "Cari item / info...",
                border: OutlineInputBorder(),
              ),
              onChanged: (v) {
                setState(() {
                  _searchKeyword = v.toLowerCase();
                });
              },
            ),
          ),

          // LIST
          Expanded(
            child: StreamBuilder(
              stream: CombineLatestStream.list([
                _itemsCol.snapshots(),
                _infoCol.snapshots(),
              ]),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return const Center(child: CircularProgressIndicator());
                }

                final itemsSnap = snapshot.data![0] as QuerySnapshot;
                final infoSnap = snapshot.data![1] as QuerySnapshot;

                final List<Map<String, dynamic>> allData = [];

                for (var d in itemsSnap.docs) {
                  final data = d.data() as Map<String, dynamic>;
                  data['id'] = d.id;
                  data['type'] = 'item';
                  allData.add(data);
                }

                for (var d in infoSnap.docs) {
                  final data = d.data() as Map<String, dynamic>;
                  data['id'] = d.id;
                  data['type'] = 'info';
                  allData.add(data);
                }

                final filtered = allData.where((e) {
                  final text =
                      ('${e['name']} ${e['tooltip']} ${e['description']}')
                          .toLowerCase();
                  return text.contains(_searchKeyword);
                }).toList();

                if (filtered.isEmpty) {
                  return const Center(child: Text("Data tidak ditemukan"));
                }

                return ListView.builder(
                  itemCount: filtered.length,
                  itemBuilder: (context, i) {
                    final item = filtered[i];

                    return ListTile(
                      leading: Icon(
                        item['type'] == 'item'
                            ? Icons.inventory_2
                            : Icons.menu_book,
                      ),
                      title: Text(item['name']),
                      subtitle: Text(item['tooltip'] ?? ''),
                      onTap: () async {
                        final prefs = await SharedPreferences.getInstance();

                        final historyItem = jsonEncode({
                          'id': item['id'],
                          'name': item['name'],
                          'type': item['type'],
                        });

                        final history =
                            prefs.getStringList('recent_items') ?? [];

                        history.removeWhere((e) {
                          final d = jsonDecode(e);
                          return d['id'] == item['id'];
                        });

                        history.insert(0, historyItem);
                        if (history.length > 5) {
                          history.removeLast();
                        }

                        await prefs.setStringList('recent_items', history);

                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => ItemDetailPage(item: item),
                          ),
                        );
                      },
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
