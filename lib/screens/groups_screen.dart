// Archivo eliminado
// Este archivo ha sido eliminado como parte de la limpieza del código.
// Se eliminan todas las referencias a grupos.
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'group_main_screen.dart';
import 'splash_login_screen.dart';
import 'group_ambulances_screen.dart';

class GroupsScreen extends StatefulWidget {
  const GroupsScreen({super.key});

  @override
  State<GroupsScreen> createState() => _GroupsScreenState();
}

class _GroupsScreenState extends State<GroupsScreen> {
  final _groupNameController = TextEditingController();
  final user = FirebaseAuth.instance.currentUser;

  Future<void> _createGroup() async {
    final name = _groupNameController.text.trim();
    if (name.isEmpty || user == null) return;
    // Verificar si ya existe un grupo con ese nombre
    final existing = await FirebaseFirestore.instance
        .collection('groups')
        .where('name', isEqualTo: name)
        .get();
    if (existing.docs.isNotEmpty) return; // No crear duplicados
    final groupRef = FirebaseFirestore.instance.collection('groups').doc();
    await groupRef.set({
      'name': name,
      'admin': user!.uid,
      'adminEmail': user!.email,
      'members': [user!.uid],
      'memberEmails': [user!.email],
      'createdAt': FieldValue.serverTimestamp(),
    });
    _groupNameController.clear();
  }

  Future<void> _deleteGroup(String groupId) async {
    await FirebaseFirestore.instance.collection('groups').doc(groupId).delete();
  }

  @override
  Widget build(BuildContext context) {
    if (user == null) {
      // Redirigir a la pantalla de login si no está autenticado
      Future.microtask(() {
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (context) => SplashLoginScreen(onLoginSuccess: () {})),
          (route) => false,
        );
      });
      return const Scaffold(
        backgroundColor: Colors.black,
        body: Center(
          child: CircularProgressIndicator(color: Colors.red),
        ),
      );
    }
    return Scaffold(
      appBar: AppBar(
        title: const Text('Grupos', style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.red,
        iconTheme: const IconThemeData(color: Colors.white),
        actions: [
          IconButton(
            icon: const Icon(Icons.add_circle_outline, color: Colors.white),
            tooltip: 'Crear grupo',
            onPressed: () {
              showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  title: const Text('Nuevo grupo', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
                  content: TextField(
                    controller: _groupNameController,
                    decoration: const InputDecoration(hintText: 'Nombre del grupo'),
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('Cancelar'),
                    ),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                      onPressed: () async {
                        await _createGroup();
                        if (mounted) Navigator.pop(context);
                      },
                      child: const Text('Crear'),
                    ),
                  ],
                ),
                barrierDismissible: false,
              );
            },
          ),
        ],
      ),
      backgroundColor: Colors.red[50],
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('groups')
            .where('members', arrayContains: user!.uid)
            .orderBy('createdAt', descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          final docs = snapshot.data?.docs ?? [];
          if (docs.isEmpty) {
            return Center(
              child: Text('No perteneces a ningún grupo.', style: TextStyle(color: Colors.red[300], fontSize: 18)),
            );
          }
          return ListView.separated(
            padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 12),
            itemCount: docs.length,
            separatorBuilder: (_, __) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              final data = docs[index].data() as Map<String, dynamic>;
              final isAdmin = data['admin'] == user!.uid;
              final members = (data['memberEmails'] as List?)?.cast<String>() ?? [];
              return Card(
                elevation: 3,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                color: Colors.white,
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundColor: isAdmin ? Colors.amber : Colors.blue,
                    child: Icon(isAdmin ? Icons.star : Icons.group, color: Colors.white),
                  ),
                  title: Text(data['name'] ?? 'Sin nombre', style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.black)),
                  subtitle: isAdmin
                      ? Text('Admin: ${data['adminEmail'] ?? ''}')
                      : Text('Integrantes: ${members.where((e) => e != data['adminEmail']).join(', ')}'),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.info_outline, color: Colors.red),
                        tooltip: 'Ver información',
                        onPressed: () {
                          showDialog(
                            context: context,
                            builder: (context) => AlertDialog(
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                              title: Text('Lobby: ${data['name']}', style: const TextStyle(color: Colors.white)),
                              content: Column(
                                mainAxisSize: MainAxisSize.min,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text('Admin: ${data['adminEmail'] ?? ''}'),
                                  const SizedBox(height: 8),
                                  const Text('Integrantes:'),
                                  ...members.where((e) => e != data['adminEmail']).map((e) => Text('- $e')).toList(),
                                ],
                              ),
                              actions: [
                                TextButton(
                                  onPressed: () => Navigator.pop(context),
                                  child: const Text('Cerrar'),
                                ),
                                ElevatedButton(
                                  style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                                  onPressed: () {
                                    Navigator.pop(context);
                                    Navigator.of(context).push(
                                      MaterialPageRoute(
                                        builder: (_) => GroupMainScreen(
                                          groupId: docs[index].id,
                                          groupName: data['name'] ?? '',
                                        ),
                                      ),
                                    );
                                  },
                                  child: const Text('Entrar al grupo'),
                                ),
                                ElevatedButton(
                                  style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                                  onPressed: () {
                                    Navigator.pop(context);
                                    Navigator.of(context).push(
                                      MaterialPageRoute(
                                        builder: (_) => GroupAmbulancesScreen(groupId: docs[index].id),
                                      ),
                                    );
                                  },
                                  child: const Text('Ambulancias'),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                      if (isAdmin)
                        IconButton(
                          icon: const Icon(Icons.delete_outline, color: Colors.red),
                          tooltip: 'Eliminar grupo',
                          onPressed: () async {
                            final confirm = await showDialog<bool>(
                              context: context,
                              builder: (context) => AlertDialog(
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                                title: const Text('Eliminar grupo', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                                content: Text('¿Estás seguro de que deseas eliminar el grupo "${data['name']}"? Esta acción no se puede deshacer.'),
                                actions: [
                                  TextButton(
                                    onPressed: () => Navigator.pop(context, false),
                                    child: const Text('Cancelar'),
                                  ),
                                  ElevatedButton(
                                    style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                                    onPressed: () => Navigator.pop(context, true),
                                    child: const Text('Eliminar'),
                                  ),
                                ],
                              ),
                            );
                            if (confirm == true) {
                              await _deleteGroup(docs[index].id);
                            }
                          },
                        ),
                    ],
                  ),
                  onTap: () {
                    // También puedes abrir el lobby al tocar la tarjeta
                    showDialog(
                      context: context,
                      builder: (context) => AlertDialog(
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                        title: Text('Lobby: ${data['name']}', style: const TextStyle(color: Colors.white)),
                        content: Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Admin: ${data['adminEmail'] ?? ''}'),
                            const SizedBox(height: 8),
                            const Text('Integrantes:'),
                            ...members.where((e) => e != data['adminEmail']).map((e) => Text('- $e')).toList(),
                          ],
                        ),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(context),
                            child: const Text('Cerrar'),
                          ),
                          ElevatedButton(
                            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                            onPressed: () {
                              Navigator.pop(context);
                              Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (_) => GroupMainScreen(
                                    groupId: docs[index].id,
                                    groupName: data['name'] ?? '',
                                  ),
                                ),
                              );
                            },
                            child: const Text('Entrar al grupo'),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              );
            },
          );
        },
      ),
    );
  }
}
