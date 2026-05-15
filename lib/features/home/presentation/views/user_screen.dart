import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../models/user.dart';
import '../cubit/user_cubit/user_cubit.dart';

class UserScreen extends StatelessWidget {
  UserScreen({super.key});

  final nameController = TextEditingController();
  final emailController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Users CRUD")),

      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            /// Inputs
            TextField(
              controller: nameController,
              decoration: const InputDecoration(labelText: "Name"),
            ),
            TextField(
              controller: emailController,
              decoration: const InputDecoration(labelText: "Email"),
            ),

            const SizedBox(height: 10),

            /// Add
            ElevatedButton(
              onPressed: () {
                context.read<UserCubit>().addUser(
                  nameController.text,
                  emailController.text,
                );

                nameController.clear();
                emailController.clear();
              },
              child: const Text("Save Data"),
            ),

            const SizedBox(height: 20),

            /// List
            Expanded(
              child: BlocBuilder<UserCubit, UserState>(
                builder: (context, state) {
                  if (state is UserLoading) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  if (state is UserLoaded) {
                    final users = state.users;
                    return ListView.builder(
                      itemCount: users.length,
                      itemBuilder: (context, index) {
                        final user = users[index];
                        print(user.toString());
                        // if (user.nationalId == null ||
                        //     user.nationalId!.isEmpty) {
                        //   Future.microtask(() {
                        //     showDialog(
                        //       context: context,
                        //       builder: (_) => AlertDialog(
                        //         title: Text("Missing National ID"),
                        //         content: Text("Please add your National ID"),
                        //         actions: [
                        //           TextButton(
                        //             onPressed: () => Navigator.pop(context),
                        //             child: Text("OK"),
                        //           ),
                        //         ],
                        //       ),
                        //     );
                        //   });
                        // }
                        return Card(
                          child: ListTile(
                            title: Text(user.name),
                            subtitle: Text(user.email),
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                IconButton(
                                  icon: const Icon(Icons.edit),
                                  onPressed: () =>
                                      _showUpdateDialog(context, user),
                                ),
                                IconButton(
                                  icon: const Icon(Icons.delete),
                                  onPressed: () => context
                                      .read<UserCubit>()
                                      .deleteUser(user.id!),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    );
                  }

                  return const SizedBox();
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showUpdateDialog(BuildContext context, OldUserModel user) {
    final nameController = TextEditingController(text: user.name);
    final emailController = TextEditingController(text: user.email);

    showDialog(
      context: context,
      builder: (_) {
        return AlertDialog(
          title: const Text("Update User"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(controller: nameController),
              TextField(controller: emailController),
            ],
          ),
          actions: [
            ElevatedButton(
              onPressed: () {
                context.read<UserCubit>().updateUser(
                  OldUserModel(
                    id: user.id,
                    name: nameController.text.isEmpty
                        ? user.name
                        : nameController.text,
                    email: emailController.text.isEmpty
                        ? user.email
                        : emailController.text,
                  ),
                );

                Navigator.pop(context);
              },
              child: const Text("Save"),
            ),
          ],
        );
      },
    );
  }
}
