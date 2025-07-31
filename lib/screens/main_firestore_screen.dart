
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class MainFirestoreScreen extends StatelessWidget {
  const MainFirestoreScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Ambulancias', style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.red,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      backgroundColor: Colors.red[50],
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('ambulances')
            .orderBy('createdAt', descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          final docs = snapshot.data?.docs ?? [];
          final ambulances = docs.map((doc) {
            final data = doc.data() as Map<String, dynamic>;
            return AmbulanceFirestore(
              id: doc.id,
              name: data['name'] ?? '',
              createdAt: (data['createdAt'] as Timestamp?)?.toDate(),
            );
          }).toList();
          return AmbulanceListFirestore(ambulances: ambulances);
        },
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.red,
        onPressed: () async {
          final controller = TextEditingController();
          await showDialog(
            context: context,
            builder: (context) => AlertDialog(
              title: const Text('Agregar ambulancia', style: TextStyle(color: Colors.red)),
              content: TextField(
                controller: controller,
                decoration: const InputDecoration(hintText: 'Nombre de la ambulancia'),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Cancelar'),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                  onPressed: () async {
                    final name = controller.text.trim();
                    if (name.isNotEmpty) {
                      await FirebaseFirestore.instance
                          .collection('ambulances')
                          .add({'name': name, 'createdAt': FieldValue.serverTimestamp()});
                    }
                    Navigator.pop(context);
                  },
                  child: const Text('Agregar'),
                ),
              ],
            ),
          );
        },
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }
}

class AmbulanceFirestore {
  final String id;
  final String name;
  final DateTime? createdAt;
  AmbulanceFirestore({required this.id, required this.name, this.createdAt});
}


class AmbulanceListFirestore extends StatelessWidget {
  final List<AmbulanceFirestore> ambulances;
  const AmbulanceListFirestore({super.key, required this.ambulances});

  @override
  Widget build(BuildContext context) {
    if (ambulances.isEmpty) {
      return const Center(child: Text('No hay ambulancias.'));
    }
    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: ambulances.length,
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        final amb = ambulances[index];
        return Card(
          child: ListTile(
            title: Text(amb.name, style: const TextStyle(fontWeight: FontWeight.bold)),
            subtitle: amb.createdAt != null ? Text('Agregada: {amb.createdAt!.day}/{amb.createdAt!.month}/{amb.createdAt!.year}') : null,
            trailing: IconButton(
              icon: const Icon(Icons.delete, color: Colors.red),
              onPressed: () async {
                await FirebaseFirestore.instance
                    .collection('ambulances')
                    .doc(amb.id)
                    .delete();
              },
            ),
          ),
        );
      },
    );
  }
}
