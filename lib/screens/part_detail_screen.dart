import 'package:flutter/material.dart';
import 'package:cruzroja/models/part_model.dart';
import 'package:intl/intl.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cruzroja/models/ambulance_model.dart';
import 'ambulance_detail_screen.dart';


class PartDetailScreen extends StatelessWidget {
  final Part part;
  final VoidCallback? onClose;
  final void Function(Ambulance)? onSelectAmbulance;

  const PartDetailScreen({super.key, required this.part, this.onClose, this.onSelectAmbulance});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F8F8),
      appBar: AppBar(
        backgroundColor: Colors.red,
        foregroundColor: Colors.white,
        iconTheme: const IconThemeData(color: Colors.white),
        title: const Text('Detalle de Pieza', style: TextStyle(color: Colors.white)),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            tooltip: 'Editar',
            onPressed: () async {
              final nameController = TextEditingController(text: part.name);
              final maintenanceIdController = TextEditingController(text: part.maintenanceId);
              final quantityController = TextEditingController(text: part.quantity.toString());
              final costController = TextEditingController(text: part.cost.toString());
              DateTime selectedDate = part.date;
              await showDialog(
                context: context,
                builder: (context) {
                  return AlertDialog(
                    title: const Text('Editar pieza'),
                    content: SingleChildScrollView(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          TextField(
                            controller: nameController,
                            decoration: const InputDecoration(labelText: 'Nombre de la pieza'),
                          ),
                          TextField(
                            controller: maintenanceIdController,
                            decoration: const InputDecoration(labelText: 'Ambulancia ID'),
                          ),
                          TextField(
                            controller: quantityController,
                            decoration: const InputDecoration(labelText: 'Cantidad'),
                            keyboardType: TextInputType.number,
                          ),
                          TextField(
                            controller: costController,
                            decoration: const InputDecoration(labelText: 'Costo unitario'),
                            keyboardType: TextInputType.number,
                          ),
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              const Text('Fecha: '),
                              TextButton(
                                child: Text(DateFormat('dd/MM/yyyy').format(selectedDate)),
                                onPressed: () async {
                                  final picked = await showDatePicker(
                                    context: context,
                                    initialDate: selectedDate,
                                    firstDate: DateTime(2000),
                                    lastDate: DateTime(2100),
                                  );
                                  if (picked != null) {
                                    selectedDate = picked;
                                  }
                                },
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    actions: [
                      TextButton(
                        child: const Text('Cancelar'),
                        onPressed: () => Navigator.pop(context),
                      ),
                      ElevatedButton(
                        child: const Text('Guardar'),
                        onPressed: () async {
                          final query = await FirebaseFirestore.instance
                              .collection('parts')
                              .where('name', isEqualTo: part.name)
                              .where('maintenanceId', isEqualTo: part.maintenanceId)
                              .where('date', isEqualTo: Timestamp.fromDate(part.date))
                              .limit(1)
                              .get();
                          if (query.docs.isNotEmpty) {
                            await query.docs.first.reference.update({
                              'name': nameController.text.trim(),
                              'maintenanceId': maintenanceIdController.text.trim(),
                              'quantity': int.tryParse(quantityController.text) ?? 0,
                              'cost': double.tryParse(costController.text) ?? 0.0,
                              'date': Timestamp.fromDate(selectedDate),
                            });
                            Navigator.pop(context);
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Pieza actualizada.')),
                            );
                          } else {
                            Navigator.pop(context);
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('No se encontró la pieza para editar.')),
                            );
                          }
                        },
                      ),
                    ],
                  );
                },
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.delete),
            onPressed: () async {
              try {
                final query = await FirebaseFirestore.instance
                    .collection('parts')
                    .where('name', isEqualTo: part.name)
                    .where('maintenanceId', isEqualTo: part.maintenanceId)
                    .where('date', isEqualTo: Timestamp.fromDate(part.date))
                    .limit(1)
                    .get();
                if (query.docs.isNotEmpty) {
                  await query.docs.first.reference.delete();
                  if (context.mounted) Navigator.pop(context);
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('No se encontró la pieza para eliminar.')),
                  );
                }
              } catch (_) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Error al eliminar la pieza.')),
                );
              }
            },
            tooltip: 'Eliminar',
          ),
          IconButton(
            icon: const Icon(Icons.close),
            tooltip: 'Cerrar',
            onPressed: () {
              if (onClose != null) {
                onClose!();
              } else {
                Navigator.pop(context);
              }
            },
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
                        child: const Icon(Icons.build, color: Colors.white, size: 28),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          part.name,
                          style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.black87),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 18),
                  // Ambulancia ID (tappable)
                  GestureDetector(
                    onTap: () async {
                      String model = '';
                      String plate = '';
                      if (part.maintenanceId.contains('-')) {
                        final parts = part.maintenanceId.split('-');
                        model = parts[0].trim();
                        plate = parts.length > 1 ? parts[1].trim() : '';
                      } else {
                        model = part.maintenanceId.trim();
                      }
                      try {
                        final query = await FirebaseFirestore.instance
                            .collection('ambulances')
                            .where('model', isEqualTo: model)
                            .where('plate', isEqualTo: plate)
                            .limit(1)
                            .get();
                        if (query.docs.isNotEmpty) {
                          final data = query.docs.first.data();
                          final ambulance = Ambulance(
                            model: data['model'] ?? '',
                            plate: data['plate'] ?? '',
                            addedDate: (data['addedDate'] as Timestamp?)?.toDate() ?? DateTime.now(),
                          );
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
                            part.maintenanceId,
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
                      const Icon(Icons.confirmation_num, color: Colors.grey, size: 20),
                      const SizedBox(width: 8),
                      const Text('Cantidad:', style: TextStyle(fontSize: 16, color: Colors.black54)),
                      const SizedBox(width: 4),
                      Text(
                        part.quantity.toString(),
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 17, color: Colors.black87),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      const Icon(Icons.attach_money, color: Colors.green, size: 20),
                      const SizedBox(width: 8),
                      const Text('Costo unitario:', style: TextStyle(fontSize: 16, color: Colors.black54)),
                      const SizedBox(width: 4),
                      Text(
                        '₡${part.cost.toStringAsFixed(2)}',
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
                        DateFormat('dd/MM/yyyy').format(part.date),
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 17, color: Colors.black87),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      const Icon(Icons.calculate, color: Colors.orange, size: 20),
                      const SizedBox(width: 8),
                      const Text('Costo total:', style: TextStyle(fontSize: 16, color: Colors.black54)),
                      const SizedBox(width: 4),
                      Text(
                        '₡${(part.cost * part.quantity).toStringAsFixed(2)}',
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
                          part.usuario ?? 'Desconocido',
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
