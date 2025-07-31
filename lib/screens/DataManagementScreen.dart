import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:logger/logger.dart';

final logger = Logger();

class DataManagementScreen extends StatefulWidget {
  const DataManagementScreen({super.key});

  @override
  State<DataManagementScreen> createState() => _DataManagementScreenState();
}

class _DataManagementScreenState extends State<DataManagementScreen> {
  Future<void> _clearAllData() async {
    try {
      // Eliminar todos los documentos de ambulances
      final ambulances = await FirebaseFirestore.instance.collection('ambulances').get();
      for (final doc in ambulances.docs) {
        await doc.reference.delete();
      }
      // Eliminar todos los documentos de maintenances
      final maintenances = await FirebaseFirestore.instance.collection('maintenances').get();
      for (final doc in maintenances.docs) {
        await doc.reference.delete();
      }
      // Eliminar todos los documentos de parts
      final parts = await FirebaseFirestore.instance.collection('parts').get();
      for (final doc in parts.docs) {
        await doc.reference.delete();
      }
      logger.w('🧹 Todos los datos de Firestore eliminados manualmente desde la app.');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('¡Datos borrados correctamente!')),
      );
      setState(() {});
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al borrar datos: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Administrar Datos'),
      ),
      body: Center(
        child: ElevatedButton.icon(
          icon: const Icon(Icons.delete_forever),
          label: const Text('Borrar TODOS los datos'),
          onPressed: () async {
            final confirm = await showDialog<bool>(
              context: context,
              builder: (context) => AlertDialog(
                title: const Text('Confirmar borrado'),
                content: const Text('¿Seguro que querés borrar todos los datos? Esta acción no se puede deshacer.'),
                actions: [
                  TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancelar')),
                  TextButton(onPressed: () => Navigator.pop(context, true), child: const Text('Borrar')),
                ],
              ),
            );
            if (confirm == true) {
              await _clearAllData();
            }
          },
        ),
      ),
    );
  }
}
