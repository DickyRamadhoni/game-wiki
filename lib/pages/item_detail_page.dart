import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'edit_item_page.dart';

class ItemDetailPage extends StatefulWidget {
  final Map<String, dynamic> item;

  const ItemDetailPage({super.key, required this.item});

  @override
  State<ItemDetailPage> createState() => _ItemDetailPageState();
}

class _ItemDetailPageState extends State<ItemDetailPage> {
  String? loggedInUser;
  bool isLoadingUser = true;

  bool get isItem => widget.item['type'] == 'item';

  @override
  void initState() {
    super.initState();
    loadLoginState();
  }

  Future<void> loadLoginState() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      loggedInUser = prefs.getString('logged_in_user');
      isLoadingUser = false;
    });
  }

  void onEditPressed() {
    if (loggedInUser == null) {
      showDialog(
        context: context,
        builder: (_) => const AlertDialog(
          title: Text("Akun Dibutuhkan"),
          content: Text(
            "Untuk mengedit halaman anda harus melakukan login terlebih dahulu.",
          ),
        ),
      );
      return;
    }

    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => EditItemPage(item: widget.item)),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (isLoadingUser) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.item['name'] ?? '-'),
        actions: [
          IconButton(icon: const Icon(Icons.edit), onPressed: onEditPressed),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: ListView(
          children: [
            Text(
              widget.item['tooltip'] ?? '',
              style: const TextStyle(fontStyle: FontStyle.italic),
            ),
            const SizedBox(height: 12),
            Text(
              widget.item['description'] ?? 'Tidak ada deskripsi',
              style: const TextStyle(fontSize: 16),
            ),

            if (isItem) ...[
              const Divider(height: 32),
              Text("Buy Price : \$${widget.item['buy_price'] ?? 0}"),
              Text("Sell Price : \$${widget.item['sell_price'] ?? 0}"),
            ],
          ],
        ),
      ),
    );
  }
}
