import 'package:flutter/material.dart';

import 'data/local/dao/user_dao.dart';
import 'data/local/db/app_data_base.dart';
import 'models/user.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final db = await AppDatabase.database;
  final userDao = UserDao(db);

  runApp(MyApp(userDao));
}

class MyApp extends StatelessWidget {
  final UserDao userDao;

  const MyApp(this.userDao, {super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(home: UserScreen(userDao: userDao));
  }
}

class UserScreen extends StatefulWidget {
  final UserDao userDao;

  const UserScreen({super.key, required this.userDao});

  @override
  State<UserScreen> createState() => _UserScreenState();
}

class _UserScreenState extends State<UserScreen> {
  final nameController = TextEditingController();
  final emailController = TextEditingController();

  List<User> users = [];

  @override
  void initState() {
    super.initState();
    loadUsers();
  }

  Future<void> loadUsers() async {
    final data = await widget.userDao.getUsers();
    setState(() {
      users = data;
    });
  }

  // ➕ Insert
  Future<void> addUser() async {
    if (nameController.text.isEmpty || emailController.text.isEmpty) return;

    await widget.userDao.insertUser(
      User(name: nameController.text, email: emailController.text),
    );

    nameController.clear();
    emailController.clear();

    await loadUsers();
  }

  // ❌ Delete
  Future<void> deleteUser(int id) async {
    await widget.userDao.deleteUser(id);
    await loadUsers();
  }

  // ✏️ Update
  Future<void> updateUser(User user) async {
    final nameController = TextEditingController(text: user.name);
    final emailController = TextEditingController(text: user.email);

    await showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Update User"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: const InputDecoration(labelText: "Name"),
              ),
              TextField(
                controller: emailController,
                decoration: const InputDecoration(labelText: "Email"),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Cancel"),
            ),
            ElevatedButton(
              onPressed: () async {
                final updatedName = nameController.text.isEmpty
                    ? user.name
                    : nameController.text;

                final updatedEmail = emailController.text.isEmpty
                    ? user.email
                    : emailController.text;

                await widget.userDao.updateUser(
                  User(id: user.id, name: updatedName, email: updatedEmail),
                );

                if (mounted) {
                  Navigator.pop(context);
                }
                await loadUsers();
              },
              child: const Text("Save"),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Users CRUD")),

      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            /// 🔹 Inputs
            TextField(
              controller: nameController,
              decoration: const InputDecoration(labelText: "Name"),
            ),

            TextField(
              controller: emailController,
              decoration: const InputDecoration(labelText: "Email"),
            ),

            const SizedBox(height: 10),

            /// 🔹 Insert Button
            ElevatedButton(onPressed: addUser, child: const Text("Save Data")),

            const SizedBox(height: 20),

            /// 🔹 List (READ)
            Expanded(
              child: ListView.builder(
                itemCount: users.length,
                itemBuilder: (context, index) {
                  final user = users[index];

                  return Card(
                    child: ListTile(
                      title: Text(user.name),
                      subtitle: Text(user.email),

                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          /// Update
                          IconButton(
                            icon: const Icon(Icons.edit),
                            onPressed: () => updateUser(user),
                          ),

                          /// Delete
                          IconButton(
                            icon: const Icon(Icons.delete),
                            onPressed: () => deleteUser(user.id!),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
