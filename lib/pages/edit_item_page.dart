import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class EditItemPage extends StatefulWidget {
  final Map<String, dynamic> item;

  const EditItemPage({super.key, required this.item});

  @override
  State<EditItemPage> createState() => _EditItemPageState();
}

class _EditItemPageState extends State<EditItemPage> {
  late TextEditingController nameCtrl;
  late TextEditingController tooltipCtrl;
  late TextEditingController descCtrl;
  late TextEditingController buyCtrl;
  late TextEditingController sellCtrl;

  bool get isItem => widget.item['type'] == 'item';

  CollectionReference get collection =>
      FirebaseFirestore.instance.collection(isItem ? 'items' : 'info_pages');

  @override
  void initState() {
    super.initState();
    nameCtrl = TextEditingController(text: widget.item['name']);
    tooltipCtrl = TextEditingController(text: widget.item['tooltip']);
    descCtrl = TextEditingController(text: widget.item['description']);
    buyCtrl = TextEditingController(
      text: widget.item['buy_price']?.toString() ?? '',
    );
    sellCtrl = TextEditingController(
      text: widget.item['sell_price']?.toString() ?? '',
    );
  }

  Future<void> updatePage() async {
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
    };

    if (isItem) {
      data['buy_price'] = int.tryParse(buyCtrl.text) ?? 0;
      data['sell_price'] = int.tryParse(sellCtrl.text) ?? 0;
    }

    try {
      await collection.doc(widget.item['id']).update(data);

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Data berhasil disimpan")));

      Navigator.pop(context, true);
      Navigator.pop(context, true);
    } catch (e) {
      showDialog(
        context: context,
        builder: (_) => AlertDialog(
          title: const Text("Error"),
          content: Text("Terjadi error: $e"),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(isItem ? "Edit Item" : "Edit Info Page")),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: ListView(
          children: [
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
            if (isItem) ...[
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
            ElevatedButton(
              onPressed: updatePage,
              child: const Text("Save Changes"),
            ),
          ],
        ),
      ),
    );
  }
}
