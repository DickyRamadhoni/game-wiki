import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class CreateItemPage extends StatefulWidget {
  const CreateItemPage({super.key});

  @override
  State<CreateItemPage> createState() => _CreateItemPageState();
}

class _CreateItemPageState extends State<CreateItemPage> {
  final TextEditingController nameCtrl = TextEditingController();
  final TextEditingController tooltipCtrl = TextEditingController();
  final TextEditingController descCtrl = TextEditingController();
  final TextEditingController buyCtrl = TextEditingController();
  final TextEditingController sellCtrl = TextEditingController();

  String pageType = 'item';
  bool isLoading = false;

  CollectionReference get collection => FirebaseFirestore.instance.collection(
    pageType == 'item' ? 'items' : 'info_pages',
  );

  Future<void> createPage() async {
    final name = nameCtrl.text.trim();
    if (name.isEmpty) {
      showDialog(
        context: context,
        builder: (_) => const AlertDialog(
          title: Text("Error"),
          content: Text("Nama wajib diisi!"),
        ),
      );
      return;
    }

    final Map<String, dynamic> data = {
      'name': name,
      'tooltip': tooltipCtrl.text.trim(),
      'description': descCtrl.text.trim(),
      'type': pageType,
    };

    if (pageType == 'item') {
      data['buy_price'] = int.tryParse(buyCtrl.text) ?? 0;
      data['sell_price'] = int.tryParse(sellCtrl.text) ?? 0;
    }

    setState(() => isLoading = true);

    try {
      final doc = await collection.add(data);
      await doc.update({'id': doc.id});

      showDialog(
        context: context,
        builder: (_) => AlertDialog(
          title: const Text("Berhasil"),
          content: const Text("Halaman berhasil dibuat!"),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                Navigator.pop(context, true);
              },
              child: const Text("OK"),
            ),
          ],
        ),
      );
    } catch (e) {
      showDialog(
        context: context,
        builder: (_) => AlertDialog(
          title: const Text("Error"),
          content: Text("Terjadi error: $e"),
        ),
      );
    } finally {
      setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Create New Page")),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: ListView(
          children: [
            DropdownButtonFormField<String>(
              value: pageType,
              decoration: const InputDecoration(labelText: "Page Type"),
              items: const [
                DropdownMenuItem(
                  value: 'item',
                  child: Text("Informasi Barang"),
                ),
                DropdownMenuItem(
                  value: 'info',
                  child: Text("Halaman Informasi"),
                ),
              ],
              onChanged: (v) => setState(() => pageType = v!),
            ),
            TextField(
              controller: nameCtrl,
              decoration: const InputDecoration(labelText: "Name"),
            ),
            TextField(
              controller: tooltipCtrl,
              decoration: const InputDecoration(labelText: "Tooltip"),
            ),
            TextField(
              controller: descCtrl,
              decoration: const InputDecoration(labelText: "Description"),
              maxLines: 5,
            ),
            if (pageType == 'item') ...[
              TextField(
                controller: buyCtrl,
                decoration: const InputDecoration(labelText: "Buy Price in \$"),
                keyboardType: TextInputType.number,
              ),
              TextField(
                controller: sellCtrl,
                decoration: const InputDecoration(
                  labelText: "Sell Price in \$",
                ),
                keyboardType: TextInputType.number,
              ),
            ],
            const SizedBox(height: 20),
            isLoading
                ? const Center(child: CircularProgressIndicator())
                : ElevatedButton(
                    onPressed: createPage,
                    child: const Text("Create"),
                  ),
          ],
        ),
      ),
    );
  }
}
