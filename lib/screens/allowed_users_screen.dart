import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:firebase_auth/firebase_auth.dart';


class AllowedUsersScreen extends StatefulWidget {
  const AllowedUsersScreen({Key? key}) : super(key: key);

  @override

  State<AllowedUsersScreen> createState() => _AllowedUsersScreenState();
}


class _AllowedUsersScreenState extends State<AllowedUsersScreen> {
  List<Map<String, dynamic>> users = [];
  bool isAdmin = false;
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _usernameController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadAllowedUsersFromFirestore();
    _checkIfAdmin();
  }

  Future<void> _checkIfAdmin() async {
    final email = FirebaseAuth.instance.currentUser?.email ?? '';
    if (email.isEmpty) {
      setState(() { isAdmin = false; });
      return;
    }
    final doc = await FirebaseFirestore.instance.collection('allowed_users').doc(email).get();
    final data = doc.data();
    if (data != null && data['role'] == 'admin') {
      setState(() { isAdmin = true; });
    } else {
      setState(() { isAdmin = false; });
    }
  }

  Future<void> _loadAllowedUsersFromFirestore() async {
    final snapshot = await FirebaseFirestore.instance.collection('allowed_users').get();
    setState(() {
      users = snapshot.docs.map((doc) {
        final data = doc.data();
        return {
          'username': data['username'] ?? '',
          'email': data['email'] ?? doc.id,
          'role': data['role'] ?? 'user',
        };
      }).toList();
    });
    await _checkIfAdmin(); // Actualiza el estado de admin después de cargar usuarios
  }

  Future<void> _addAllowedUser() async {
    final email = _emailController.text.trim();
    final username = _usernameController.text.trim();
    if (email.isEmpty || username.isEmpty) return;
    final role = (email == 'gabriel.gacha07@gmail.com' || email == 'andresea212@gmail.com') ? 'admin' : 'user';
    await FirebaseFirestore.instance.collection('allowed_users').doc(email).set({
      'username': username,
      'email': email,
      'role': role,
    });
    _emailController.clear();
    _usernameController.clear();
    _loadAllowedUsersFromFirestore();
  }

  Future<void> _removeAllowedUser(String email) async {
    await FirebaseFirestore.instance.collection('allowed_users').doc(email).delete();
    _loadAllowedUsersFromFirestore();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Usuarios permitidos', style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.red,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            if (isAdmin) ...[
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _emailController,
                      decoration: const InputDecoration(hintText: 'Correo electrónico'),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: TextField(
                      controller: _usernameController,
                      decoration: const InputDecoration(hintText: 'Nombre de usuario'),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.add, color: Colors.red),
                    tooltip: 'Agregar usuario',
                    onPressed: _addAllowedUser,
                  ),
                ],
              ),
              const SizedBox(height: 16),
            ],
            Expanded(
              child: users.isEmpty
                  ? const Center(child: Text('No hay usuarios permitidos'))
                  : ListView.builder(
                      itemCount: users.length,
                      itemBuilder: (context, i) {
                        final user = users[i];
                        return ListTile(
                          title: Text(
                            user['username'] ?? '',
                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                          ),
                          subtitle: Text(
                            user['email'] ?? '',
                            style: const TextStyle(fontSize: 13, color: Colors.grey),
                          ),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(user['role'] == 'admin' ? 'admin' : 'user', style: TextStyle(color: user['role'] == 'admin' ? Colors.red : Colors.black)),
                              if (isAdmin) ...[
                                IconButton(
                                  icon: const Icon(Icons.delete, color: Colors.red),
                                  tooltip: 'Eliminar usuario',
                                  onPressed: () async {
                                    final confirm = await showDialog<bool>(
                                      context: context,
                                      builder: (ctx) => AlertDialog(
                                        title: const Text('Eliminar usuario'),
                                        content: Text('¿Eliminar a ${user['email']} de allowed_users?'),
                                        actions: [
                                          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancelar')),
                                          TextButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('Eliminar', style: TextStyle(color: Colors.red))),
                                        ],
                                      ),
                                    );
                                    if (confirm == true) _removeAllowedUser(user['email']);
                                  },
                                ),
                                if (user['role'] != 'admin')
                                  IconButton(
                                    icon: const Icon(Icons.upgrade, color: Colors.blue),
                                    tooltip: 'Convertir en admin',
                                    onPressed: () async {
                                      final confirm = await showDialog<bool>(
                                        context: context,
                                        builder: (ctx) => AlertDialog(
                                          title: const Text('Hacer admin'),
                                          content: Text('¿Convertir a ${user['email']} en administrador?'),
                                          actions: [
                                            TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancelar')),
                                            TextButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('Hacer admin', style: TextStyle(color: Colors.blue))),
                                          ],
                                        ),
                                      );
                                      if (confirm == true) {
                                        await FirebaseFirestore.instance.collection('allowed_users').doc(user['email']).update({'role': 'admin'});
                                        _loadAllowedUsersFromFirestore();
                                      }
                                    },
                                  ),
                                if (user['role'] == 'admin')
                                  IconButton(
                                    icon: const Icon(Icons.arrow_downward, color: Colors.orange),
                                    tooltip: 'Quitar admin',
                                    onPressed: () async {
                                      final confirm = await showDialog<bool>(
                                        context: context,
                                        builder: (ctx) => AlertDialog(
                                          title: const Text('Quitar admin'),
                                          content: Text('¿Quitar privilegios de administrador a ${user['email']}?'),
                                          actions: [
                                            TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancelar')),
                                            TextButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('Quitar admin', style: TextStyle(color: Colors.orange))),
                                          ],
                                        ),
                                      );
                                      if (confirm == true) {
                                        await FirebaseFirestore.instance.collection('allowed_users').doc(user['email']).update({'role': 'user'});
                                        _loadAllowedUsersFromFirestore();
                                      }
                                    },
                                  ),
                              ],
                            ],
                          ),
                          onLongPress: isAdmin && user['role'] != 'admin'
                              ? () async {
                                  final confirm = await showDialog<bool>(
                                    context: context,
                                    builder: (ctx) => AlertDialog(
                                      title: const Text('Eliminar usuario'),
                                      content: Text('¿Eliminar a ${user['email']} de allowed_users?'),
                                      actions: [
                                        TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancelar')),
                                        TextButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('Eliminar', style: TextStyle(color: Colors.red))),
                                      ],
                                    ),
                                  );
                                  if (confirm == true) _removeAllowedUser(user['email']);
                                }
                              : null,
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
