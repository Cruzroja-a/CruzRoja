import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:cruzroja/models/ambulance_model.dart';
import 'package:intl/intl.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cruzroja/models/part_model.dart';
import 'package:cruzroja/models/maintenance_model.dart';

import 'package:cruzroja/screens/part_detail_screen.dart';
import 'package:cruzroja/screens/maintenance_detail_screen.dart';

class AmbulanceDetailScreen extends StatelessWidget {
  final Ambulance ambulance;
  final bool showDeleteButton;
  final void Function(Maintenance)? onSelectMaintenance;
  final void Function(Part)? onSelectPart;

  const AmbulanceDetailScreen({
    super.key,
    required this.ambulance,
    this.showDeleteButton = true,
    this.onSelectMaintenance,
    this.onSelectPart,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F8F8),
      appBar: AppBar(
        backgroundColor: Colors.red,
        foregroundColor: Colors.white,
        iconTheme: const IconThemeData(color: Colors.white),
        title: const Text(
          'Details',
          style: TextStyle(color: Colors.white),
        ),
        actions: [
          if (showDeleteButton)
            IconButton(
              icon: const Icon(Icons.delete),
              onPressed: () async {
                try {
                  final query = await FirebaseFirestore.instance
                      .collection('ambulances')
                      .where('model', isEqualTo: ambulance.model)
                      .where('plate', isEqualTo: ambulance.plate)
                      .limit(1)
                      .get();
                  if (query.docs.isNotEmpty) {
                    await query.docs.first.reference.delete();
                    if (context.mounted) Navigator.pop(context);
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('No se encontró la ambulancia para eliminar.')),
                    );
                  }
                } catch (_) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Error al eliminar la ambulancia.')),
                  );
                }
              },
              tooltip: 'Eliminar',
            ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Card de detalles de ambulancia
              Card(
                elevation: 4,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                color: Colors.white,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(Icons.local_hospital, color: Colors.red[700], size: 32),
                          const SizedBox(width: 10),
                          Text(
                            '${ambulance.model} - ${ambulance.plate}',
                            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black87),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      Row(
                        children: [
                          const Icon(Icons.calendar_today, size: 18, color: Colors.grey),
                          const SizedBox(width: 6),
                          Text(
                            'Agregado: ',
                            style: TextStyle(fontSize: 15, color: Colors.grey[700]),
                          ),
                          Text(
                            DateFormat('dd/MM/yyyy').format(ambulance.addedDate),
                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: Colors.black87),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),
              // Piezas cambiadas de ese modelo
              Row(
                children: const [
                  Icon(Icons.build, color: Colors.red, size: 22),
                  SizedBox(width: 8),
                  Text('Piezas cambiadas', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.red)),
                ],
              ),
              const SizedBox(height: 8),
              FutureBuilder<QuerySnapshot>(
                future: FirebaseFirestore.instance
                    .collection('parts')
                    .where('maintenanceId', whereIn: [
                      '${ambulance.model}-${ambulance.plate}',
                      ambulance.plate,
                      ambulance.model
                    ])
                    .get(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Padding(
                      padding: EdgeInsets.symmetric(vertical: 12),
                      child: Center(child: CircularProgressIndicator()),
                    );
                  }
                  if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                    return const Padding(
                      padding: EdgeInsets.symmetric(vertical: 12),
                      child: Text('No hay piezas registradas para este modelo.', style: TextStyle(color: Colors.grey)),
                    );
                  }
                  final relatedParts = snapshot.data!.docs.map((doc) {
                    final data = doc.data() as Map<String, dynamic>;
                    return Part(
                      name: data['name'] ?? '',
                      maintenanceId: data['maintenanceId'] ?? '',
                      date: (data['date'] as Timestamp?)?.toDate() ?? DateTime.now(),
                      cost: (data['cost'] as num?)?.toDouble() ?? 0.0,
                      quantity: (data['quantity'] as int?) ?? 0,
                    );
                  }).toList();
                  bool verTodos = false;
                  List<DataRow> rowsToShow = relatedParts.take(3).map<DataRow>((p) => DataRow(
                    cells: [
                      DataCell(Text(p.name)),
                      DataCell(Text(p.quantity.toString())),
                      DataCell(Text(NumberFormat.currency(locale: 'es_CR', symbol: '₡').format(p.cost))),
                      DataCell(Text(DateFormat('dd/MM/yyyy').format(p.date))),
                    ],
                    onSelectChanged: (_) {
                      if (onSelectPart != null && (kIsWeb || MediaQuery.of(context).size.width > 900)) {
                        onSelectPart!(p);
                      } else {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => PartDetailScreen(part: p),
                          ),
                        );
                      }
                    },
                  )).toList();
                  return StatefulBuilder(
                    builder: (context, setState) {
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Card(
                            elevation: 2,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            color: Colors.white,
                            child: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: SingleChildScrollView(
                                scrollDirection: Axis.horizontal,
                                child: DataTable(
                                  showCheckboxColumn: false,
                                  headingRowColor: MaterialStateProperty.all(Color(0xFFFAE3E3)),
                                  dataRowColor: MaterialStateProperty.all(Colors.white),
                                  columns: const [
                                    DataColumn(label: Text('Pieza', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black))),
                                    DataColumn(label: Text('Cantidad', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black))),
                                    DataColumn(label: Text('Precio', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black))),
                                    DataColumn(label: Text('Fecha', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black))),
                                  ],
                                  rows: verTodos
                                    ? relatedParts.map<DataRow>((p) => DataRow(
                                        cells: [
                                          DataCell(Text(p.name)),
                                          DataCell(Text(p.quantity.toString())),
                                          DataCell(Text(NumberFormat.currency(locale: 'es_CR', symbol: '₡').format(p.cost))),
                                          DataCell(Text(DateFormat('dd/MM/yyyy').format(p.date))),
                                        ],
                                        onSelectChanged: (_) {
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder: (_) => PartDetailScreen(part: p),
                                            ),
                                          );
                                        },
                                      )).toList()
                                    : rowsToShow,
                                ),
                              ),
                            ),
                          ),
                          if (relatedParts.length > 3)
                            TextButton(
                              onPressed: () => setState(() => verTodos = !verTodos),
                              child: Text(verTodos ? 'Ver menos' : 'Ver todos'),
                            ),
                        ],
                      );
                    },
                  );
                },
              ),
              const SizedBox(height: 24),
              // Mantenimientos de ese modelo
              Row(
                children: const [
                  Icon(Icons.settings, color: Colors.red, size: 22),
                  SizedBox(width: 8),
                  Text('Mantenimientos', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.red)),
                ],
              ),
              const SizedBox(height: 8),
              FutureBuilder<QuerySnapshot>(
                future: FirebaseFirestore.instance
                    .collection('maintenances')
                    .where('maintenanceId', whereIn: [
                      '${ambulance.model} - ${ambulance.plate}',
                      '${ambulance.model}-${ambulance.plate}',
                      '${ambulance.model} -${ambulance.plate}',
                      '${ambulance.model}- ${ambulance.plate}',
                      ambulance.plate,
                      ambulance.model,
                    ])
                    .get(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Padding(
                      padding: EdgeInsets.symmetric(vertical: 12),
                      child: Center(child: CircularProgressIndicator()),
                    );
                  }
                  if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                    return const Padding(
                      padding: EdgeInsets.symmetric(vertical: 12),
                      child: Text('No hay mantenimientos registrados para este modelo.', style: TextStyle(color: Colors.grey)),
                    );
                  }
                  final relatedMaintenances = snapshot.data!.docs.map((doc) {
                    final data = doc.data() as Map<String, dynamic>;
                    return Maintenance(
                      maintenanceId: data['maintenanceId'] ?? '',
                      maintenanceType: data['maintenanceType'] ?? '',
                      description: data['description'] ?? '',
                      cost: (data['cost'] as num?)?.toDouble() ?? 0.0,
                      date: (data['date'] is Timestamp)
                          ? (data['date'] as Timestamp).toDate()
                          : (data['date'] is String)
                              ? DateFormat('dd/MM/yyyy').parse(data['date'])
                              : DateTime.now(),
                    );
                  }).toList();
                  bool verTodos = false;
                  List<DataRow> rowsToShow = relatedMaintenances.take(3).map<DataRow>((m) => DataRow(
                    cells: [
                      DataCell(Text(m.maintenanceType)),
                      DataCell(Text(m.description)),
                      DataCell(Text(NumberFormat.currency(locale: 'es_CR', symbol: '₡').format(m.cost)) ),
                      DataCell(Text(DateFormat('dd/MM/yyyy').format(m.date)) ),
                    ],
                    onSelectChanged: (_) {
                      if (onSelectMaintenance != null && (kIsWeb || MediaQuery.of(context).size.width > 900)) {
                        onSelectMaintenance!(m);
                      } else {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => MaintenanceDetailScreen(
                              maintenance: m,
                              ambulanceModel: '${ambulance.model} - ${ambulance.plate}',
                            ),
                          ),
                        );
                      }
                    },
                  )).toList();
                  return StatefulBuilder(
                    builder: (context, setState) {
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Card(
                            elevation: 2,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            color: Colors.white,
                            child: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: SingleChildScrollView(
                                scrollDirection: Axis.horizontal,
                                child: DataTable(
                                  showCheckboxColumn: false,
                                  headingRowColor: MaterialStateProperty.all(Color(0xFFFAE3E3)),
                                  dataRowColor: MaterialStateProperty.all(Colors.white),
                                  columns: const [
                                    DataColumn(label: Text('Tipo', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black))),
                                    DataColumn(label: Text('Descripción', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black))),
                                    DataColumn(label: Text('Precio', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black))),
                                    DataColumn(label: Text('Fecha', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black))),
                                  ],
                                  rows: verTodos
                                    ? relatedMaintenances.map<DataRow>((m) => DataRow(
                                        cells: [
                                          DataCell(Text(m.maintenanceType)),
                                          DataCell(Text(m.description)),
                                          DataCell(Text(NumberFormat.currency(locale: 'es_CR', symbol: '₡').format(m.cost)) ),
                                          DataCell(Text(DateFormat('dd/MM/yyyy').format(m.date)) ),
                                        ],
                                        onSelectChanged: (_) {
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder: (_) => MaintenanceDetailScreen(
                                                maintenance: m,
                                                ambulanceModel: '${ambulance.model} - ${ambulance.plate}',
                                              ),
                                            ),
                                          );
                                        },
                                      )).toList()
                                    : rowsToShow,
                                ),
                              ),
                            ),
                          ),
                          if (relatedMaintenances.length > 3)
                            TextButton(
                              onPressed: () => setState(() => verTodos = !verTodos),
                              child: Text(verTodos ? 'Ver menos' : 'Ver todos'),
                            ),
                        ],
                      );
                    },
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
