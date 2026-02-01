import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:game_wiki/pages/create_item_page.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'register_page.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final usernameController = TextEditingController();
  final passwordController = TextEditingController();
  String? loggedInUser;

  final CollectionReference accounts = FirebaseFirestore.instance.collection(
    'accounts',
  );

  @override
  void initState() {
    super.initState();
    loadLoggedInUser();
  }

  Future<void> loadLoggedInUser() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      loggedInUser = prefs.getString('logged_in_user');
      if (loggedInUser != null) {
        usernameController.text = loggedInUser!;
      }
    });
  }

  Future<void> saveLogin(String username) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('logged_in_user', username);
  }

  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('logged_in_user');
    setState(() {
      loggedInUser = null;
      usernameController.clear();
      passwordController.clear();
    });
  }

  Future<void> login() async {
    if (usernameController.text.isEmpty || passwordController.text.isEmpty) {
      showDialog(
        context: context,
        builder: (_) => const AlertDialog(
          title: Text("Login Gagal"),
          content: Text("Username dan password tidak boleh kosong."),
        ),
      );
      return;
    }

    try {
      final doc = await accounts.doc(usernameController.text).get();

      if (!doc.exists) {
        showDialog(
          context: context,
          builder: (_) => const AlertDialog(
            title: Text("Login Gagal"),
            content: Text("Username tidak ditemukan."),
          ),
        );
        return;
      }

      final data = doc.data() as Map<String, dynamic>;

      if (data['password'] == passwordController.text) {
        await saveLogin(data['name']);
        setState(() {
          loggedInUser = data['name'];
        });

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Selamat datang!"),
            duration: Duration(seconds: 2),
          ),
        );

        await Future.delayed(const Duration(seconds: 2));

        // setelah login, bisa masuk ke create page
      } else {
        showDialog(
          context: context,
          builder: (_) => const AlertDialog(
            title: Text("Login Gagal"),
            content: Text("Password salah."),
          ),
        );
      }
    } catch (e) {
      showDialog(
        context: context,
        builder: (_) => AlertDialog(
          title: const Text("Error"),
          content: Text("Terjadi kesalahan: $e"),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Login")),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            if (loggedInUser != null) ...[
              Card(
                color: Colors.green[50],
                margin: const EdgeInsets.only(bottom: 16),
                child: ListTile(
                  title: Text("Akun Aktif: $loggedInUser"),
                  trailing: TextButton(
                    onPressed: logout,
                    child: const Text("Logout"),
                  ),
                ),
              ),
              ElevatedButton(
                onPressed: () async {
                  final result = await Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const CreateItemPage()),
                  );

                  if (result == true) {
                    Navigator.pop(context, true);
                  }
                },
                child: const Text("Buat Halaman Baru"),
              ),
            ],
            if (loggedInUser == null) ...[
              TextField(
                controller: usernameController,
                decoration: const InputDecoration(labelText: "Username"),
              ),
              TextField(
                controller: passwordController,
                decoration: const InputDecoration(labelText: "Password"),
                obscureText: true,
              ),
              const SizedBox(height: 16),
              ElevatedButton(onPressed: login, child: const Text("Login")),
              const SizedBox(height: 8),
              TextButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const RegisterPage()),
                  );
                },
                child: const Text("Belum punya akun? Register"),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
