import 'package:flutter/material.dart';
import 'package:cruzroja/models/maintenance_model.dart';
import 'package:intl/intl.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'ambulance_detail_screen.dart';
import 'package:cruzroja/models/ambulance_model.dart';

class MaintenanceDetailScreen extends StatelessWidget {
  final Maintenance maintenance;
  final String ambulanceModel;
  final bool showDeleteButton;
  final void Function(Ambulance)? onSelectAmbulance;

  const MaintenanceDetailScreen({
    super.key,
    required this.maintenance,
    required this.ambulanceModel,
    this.showDeleteButton = true,
    this.onSelectAmbulance,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F8F8),
      appBar: AppBar(
        backgroundColor: Colors.red,
        foregroundColor: Colors.white,
        iconTheme: const IconThemeData(color: Colors.white),
        title: const Text('Detalles de mantenimiento', style: TextStyle(color: Colors.white)),
        actions: [
          if (showDeleteButton)
            IconButton(
              icon: const Icon(Icons.delete),
              onPressed: () async {
                try {
                  final query = await FirebaseFirestore.instance
                      .collection('maintenances')
                      .where('maintenanceId', isEqualTo: maintenance.maintenanceId)
                      .where('maintenanceType', isEqualTo: maintenance.maintenanceType)
                      .where('date', isEqualTo: Timestamp.fromDate(maintenance.date))
                      .limit(1)
                      .get();
                  if (query.docs.isNotEmpty) {
                    await query.docs.first.reference.delete();
                    if (context.mounted) Navigator.pop(context);
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('No se encontró el mantenimiento para eliminar.')),
                    );
                  }
                } catch (_) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Error al eliminar el mantenimiento.')),
                  );
                }
              },
              tooltip: 'Eliminar',
            ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Center(
          child: Card(
            elevation: 4,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
            color: Colors.white,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 28),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.red,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        padding: const EdgeInsets.all(6),
                        child: const Icon(Icons.medical_services, color: Colors.white, size: 28),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          maintenance.maintenanceType,
                          style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.black87),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 18),
                  // Ambulancia ID (modelo y placa en rojo, redirige correctamente)
                  GestureDetector(
                    onTap: () async {
                      String model = '';
                      String plate = '';
                      if (maintenance.maintenanceId.contains('-')) {
                        final parts = maintenance.maintenanceId.split('-');
                        model = parts[0].trim();
                        plate = parts.length > 1 ? parts[1].trim() : '';
                      } else {
                        model = maintenance.maintenanceId.trim();
                        plate = '';
                      }
                      try {
                        Query<Map<String, dynamic>> query = FirebaseFirestore.instance.collection('ambulances');
                        if (model.isNotEmpty) {
                          query = query.where('model', isEqualTo: model);
                        }
                        if (plate.isNotEmpty) {
                          query = query.where('plate', isEqualTo: plate);
                        }
                        final result = await query.limit(1).get();
                        if (result.docs.isNotEmpty) {
                          final data = result.docs.first.data();
                          final ambulance = Ambulance(
                            model: data['model'] ?? '',
                            plate: data['plate'] ?? '',
                            addedDate: (data['addedDate'] as Timestamp?)?.toDate() ?? DateTime.now(),
                          );
                          // Solo para web: navegar a la pantalla principal y seleccionar la ambulancia
                          if (onSelectAmbulance != null && (Theme.of(context).platform == TargetPlatform.windows || Theme.of(context).platform == TargetPlatform.macOS || Theme.of(context).platform == TargetPlatform.linux)) {
                            onSelectAmbulance!(ambulance);
                          } else {
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (_) => AmbulanceDetailScreen(ambulance: ambulance),
                              ),
                            );
                          }
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('No se encontró la ambulancia asociada.')),
                          );
                        }
                      } catch (_) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Error al buscar la ambulancia.')),
                        );
                      }
                    },
                    child: Row(
                      children: [
                        const Icon(Icons.settings, color: Colors.red, size: 20),
                        const SizedBox(width: 8),
                        const Text('Ambulancia ID:', style: TextStyle(fontSize: 16, color: Colors.black54)),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            (() {
                              String model = '';
                              String plate = '';
                              if (maintenance.maintenanceId.contains('-')) {
                                final parts = maintenance.maintenanceId.split('-');
                                model = parts[0].trim();
                                plate = parts.length > 1 ? parts[1].trim() : '';
                              } else {
                                model = maintenance.maintenanceId.trim();
                                plate = '';
                              }
                              if (model.isNotEmpty && plate.isNotEmpty) {
                                return '$model - $plate';
                              } else if (model.isNotEmpty) {
                                return model;
                              } else if (plate.isNotEmpty) {
                                return plate;
                              } else {
                                return '';
                              }
                            })(),
                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 17, color: Colors.red),
                            overflow: TextOverflow.ellipsis,
                            maxLines: 1,
                          ),
                        ),
                        const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.red),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      const Icon(Icons.description, color: Colors.grey, size: 20),
                      const SizedBox(width: 8),
                      const Text('Descripción:', style: TextStyle(fontSize: 16, color: Colors.black54)),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          maintenance.description,
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 17, color: Colors.black87),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      const Icon(Icons.attach_money, color: Colors.green, size: 20),
                      const SizedBox(width: 8),
                      const Text('Costo:', style: TextStyle(fontSize: 16, color: Colors.black54)),
                      const SizedBox(width: 4),
                      Text(
                        '₡${maintenance.cost.toStringAsFixed(2)}',
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 17, color: Colors.black87),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      const Icon(Icons.calendar_today, color: Colors.blue, size: 20),
                      const SizedBox(width: 8),
                      const Text('Fecha:', style: TextStyle(fontSize: 16, color: Colors.black54)),
                      const SizedBox(width: 4),
                      Text(
                        DateFormat('dd/MM/yyyy').format(maintenance.date),
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 17, color: Colors.black87),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      const Icon(Icons.person, color: Colors.deepPurple, size: 20),
                      const SizedBox(width: 8),
                      const Text('Usuario:', style: TextStyle(fontSize: 16, color: Colors.black54)),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          maintenance.usuario ?? 'Desconocido',
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 17, color: Colors.deepPurple),
                          overflow: TextOverflow.ellipsis,
                          maxLines: 1,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}