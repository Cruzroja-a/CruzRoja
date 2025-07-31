
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:flutter/foundation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
// import eliminado, ya está presente más abajo
import 'package:cruzroja/models/maintenance_model.dart';
import 'package:cruzroja/models/part_model.dart';
import 'ambulance_detail_screen.dart';
import 'maintenance_detail_screen.dart';
import 'package:cruzroja/widgets/maintenance_list.dart';
import 'package:cruzroja/widgets/ambulance_list.dart';
import 'package:cruzroja/widgets/part_list.dart';
import 'package:cruzroja/screens/part_detail_screen.dart';
import 'package:cruzroja/widgets/add_ambulance_dialog.dart';
import 'package:cruzroja/widgets/add_maintenance_dialog.dart';
import 'package:cruzroja/widgets/add_part_dialog.dart';
import 'about_screen.dart';
import 'allowed_users_screen.dart';
import 'account_screen.dart';


import 'package:cruzroja/models/ambulance_model.dart';

class PantallaPrincipal extends StatefulWidget {
  final Ambulance? ambulanciaPreseleccionada;
  const PantallaPrincipal({Key? key, this.ambulanciaPreseleccionada}) : super(key: key);

  @override
  _PantallaPrincipalState createState() => _PantallaPrincipalState();
}

class _PantallaPrincipalState extends State<PantallaPrincipal> {
  Part? _piezaSeleccionada;
  Ambulance? _ambulanciaSeleccionada;
  Maintenance? _mantenimientoSeleccionado;
  final TextEditingController _searchController = TextEditingController();
  String _searchText = '';
  void _onSearchChanged() {
    setState(() {
      _searchText = _searchController.text.trim().toLowerCase();
    });
  }
  int _indiceActual = 0;
  late final PageController _controladorPagina;
  Set<int> _seleccionados = {};
  bool _modoSeleccion = false;
  // Eliminada variable de ambulancias, ya no se usa con StreamBuilder

  @override
  void initState() {
    super.initState();
    _controladorPagina = PageController(initialPage: _indiceActual);
    // Si viene una ambulancia preseleccionada, mostrarla en el master-detail
    if (widget.ambulanciaPreseleccionada != null) {
      _indiceActual = 0;
      _ambulanciaSeleccionada = widget.ambulanciaPreseleccionada;
    }
  }

  void _activarSeleccion() {
    setState(() {
      _modoSeleccion = true;
      _seleccionados.clear();
    });
  }

  void _cancelarSeleccion() {
    setState(() {
      _modoSeleccion = false;
      _seleccionados.clear();
    });
  }

  void _toggleSeleccion(int index) {
    setState(() {
      if (_seleccionados.contains(index)) {
        _seleccionados.remove(index);
      } else {
        _seleccionados.add(index);
      }//n
    });
  }

  Future<void> _borrarSeleccionados() async {
    if (_indiceActual == 0) {
      // Eliminar ambulancias seleccionadas de Firestore
      final snapshot = await FirebaseFirestore.instance.collection('ambulances').orderBy('createdAt', descending: true).get();
      final docs = snapshot.docs;
      final refs = _seleccionados.where((i) => i < docs.length).map((i) => docs[i].reference).toList();
      for (final ref in refs) {
        await ref.delete();
      }
      // Ya no es necesario recargar manualmente, StreamBuilder actualiza la UI
    } else if (_indiceActual == 1) {
      // Eliminar mantenimientos seleccionados de Firestore
      final snapshot = await FirebaseFirestore.instance.collection('maintenances').orderBy('date', descending: true).get();
      final docs = snapshot.docs;
      final refs = _seleccionados.where((i) => i < docs.length).map((i) => docs[i].reference).toList();
      for (final ref in refs) {
        await ref.delete();
      }
      setState(() {});
    } else if (_indiceActual == 2) {
      // Eliminar piezas seleccionadas de Firestore
      final snapshot = await FirebaseFirestore.instance.collection('parts').orderBy('date', descending: true).get();
      final docs = snapshot.docs;
      final refs = _seleccionados.where((i) => i < docs.length).map((i) => docs[i].reference).toList();
      for (final ref in refs) {
        await ref.delete();
      }
      setState(() {});
    }
    _cancelarSeleccion();
  }

  @override
  Widget build(BuildContext context) {
    final titulosAppBar = [
      'Ambulancias',
      'Mantenimientos',
      'Piezas',
    ];

    return Scaffold(
      drawer: _buildDrawer(context),
      appBar: AppBar(
        leading: Builder(
          builder: (context) => IconButton(
            icon: const Icon(Icons.menu, color: Colors.white),
            onPressed: () => Scaffold.of(context).openDrawer(),
            tooltip: 'Menú',
          ),
        ),
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Image.asset(
              'assets/ambulance.png',
              height: 33,
              width: 33,
            ),
            const SizedBox(width: 8),
            Text(
              titulosAppBar[_indiceActual],
              style: const TextStyle(color: Colors.white),
            ),
          ],
        ),
        backgroundColor: Colors.red,
        actions: [
          if (_modoSeleccion) ...[
            IconButton(
              icon: const Icon(Icons.delete, color: Colors.white),
              onPressed: _seleccionados.isEmpty ? null : _borrarSeleccionados,
              tooltip: 'Borrar seleccionados',
            ),
            IconButton(
              icon: const Icon(Icons.close, color: Colors.white),
              onPressed: _cancelarSeleccion,
              tooltip: 'Cancelar selección',
            ),
          ] else ...[
            SizedBox(
              width: 120,
              child: TextField(
                controller: _searchController,
                onChanged: (_) => _onSearchChanged(),
                style: const TextStyle(color: Colors.white, fontSize: 14),
                decoration: InputDecoration(
                  hintText: 'Buscar...',
                  hintStyle: const TextStyle(color: Colors.white70, fontSize: 13),
                  filled: true,
                  fillColor: Colors.red[400],
                  contentPadding: const EdgeInsets.symmetric(vertical: 0, horizontal: 10),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(30),
                    borderSide: BorderSide.none,
                  ),
                  prefixIcon: const Icon(Icons.search, color: Colors.white, size: 18),
                ),
              ),
            ),
            IconButton(
              icon: const Icon(Icons.select_all, color: Colors.white),
              onPressed: _activarSeleccion,
              tooltip: 'Seleccionar',
            ),
          ],
        ],
      ),
      body: PageView(
        controller: _controladorPagina,
        onPageChanged: (index) {
          setState(() {
            _indiceActual = index;
          });
        },
        children: [
          // Ambulancias desde Firestore
          StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance.collection('ambulances').orderBy('createdAt', descending: true).snapshots(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }
              final docs = snapshot.data?.docs ?? [];
              final ambulancias = docs.map((doc) {
                final data = doc.data() as Map<String, dynamic>;
                return Ambulance(
                  model: data['model'] ?? '',
                  plate: data['plate'] ?? '',
                  addedDate: (data['addedDate'] as Timestamp?)?.toDate() ?? DateTime.now(),
                );
              }).toList();
              final filtered = _searchText.isEmpty
                  ? ambulancias
                  : ambulancias.where((a) {
                      final dateStr = a.addedDate.day.toString().padLeft(2, '0') + '/' +
                          a.addedDate.month.toString().padLeft(2, '0') + '/' +
                          a.addedDate.year.toString();
                      return a.model.toLowerCase().contains(_searchText)
                          || a.plate.toLowerCase().contains(_searchText)
                          || dateStr.contains(_searchText);
                    }).toList();
              // Si es web o pantalla ancha, usar master-detail
              final isWide = kIsWeb || MediaQuery.of(context).size.width > 900;
              if (isWide) {
                if (_ambulanciaSeleccionada == null) {
                  // Solo la lista, ocupa todo el ancho
                  return AmbulanceList(
                    ambulances: filtered,
                    onAddAmbulance: () async {
                      await showDialog<Ambulance>(
                        context: context,
                        builder: (_) => AddAmbulanceDialog(),
                      );
                    },
                    modoSeleccion: _modoSeleccion,
                    seleccionados: _seleccionados,
                    onToggleSeleccion: _toggleSeleccion,
                    onTapAmbulance: (ambulance) {
                      setState(() {
                        if (_ambulanciaSeleccionada == ambulance) {
                          _ambulanciaSeleccionada = null;
                        } else {
                          _ambulanciaSeleccionada = ambulance;
                        }
                      });
                    },
                  );
                } else {
                  // Master-detail: lista y detalle
                  return Row(
                    children: [
                      // Lista de ambulancias ocupa el espacio restante
                      Expanded(
                        child: AmbulanceList(
                          ambulances: filtered,
                          onAddAmbulance: () async {
                            await showDialog<Ambulance>(
                              context: context,
                              builder: (_) => AddAmbulanceDialog(),
                            );
                          },
                          modoSeleccion: _modoSeleccion,
                          seleccionados: _seleccionados,
                          onToggleSeleccion: _toggleSeleccion,
                          onTapAmbulance: (ambulance) {
                            setState(() {
                              _ambulanciaSeleccionada = ambulance;
                            });
                          },
                        ),
                      ),
                      // Panel de detalles con ancho fijo
                      Container(
                        width: 520,
                        constraints: const BoxConstraints(maxWidth: 600),
                        child: Stack(
                          children: [
                            AmbulanceDetailScreen(
                              ambulance: _ambulanciaSeleccionada!,
                              showDeleteButton: false,
                              onSelectMaintenance: (m) {
                                setState(() {
                                  _indiceActual = 1;
                                  _mantenimientoSeleccionado = m;
                                  _controladorPagina.jumpToPage(1);
                                });
                              },
                              onSelectPart: (p) {
                                setState(() {
                                  _indiceActual = 2;
                                  _piezaSeleccionada = p;
                                  _controladorPagina.jumpToPage(2);
                                });
                              },
                            ),
                            Positioned(
                              top: 8,
                              right: 8,
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  // Botón de basurero
                                  IconButton(
                                    icon: const Icon(Icons.delete, color: Colors.white, size: 26),
                                    tooltip: 'Eliminar',
                                    onPressed: () async {
                                      // Confirmar antes de eliminar
                                      final confirmar = await showDialog<bool>(
                                        context: context,
                                        builder: (ctx) => AlertDialog(
                                          title: const Text('¿Eliminar ambulancia?'),
                                          content: const Text('Esta acción no se puede deshacer.'),
                                          actions: [
                                            TextButton(
                                              onPressed: () => Navigator.pop(ctx, false),
                                              child: const Text('Cancelar'),
                                            ),
                                            TextButton(
                                              onPressed: () => Navigator.pop(ctx, true),
                                              child: const Text('Eliminar', style: TextStyle(color: Colors.red)),
                                            ),
                                          ],
                                        ),
                                      );
                                      if (confirmar == true) {
                                        // Eliminar de Firestore
                                        final query = await FirebaseFirestore.instance
                                            .collection('ambulances')
                                            .where('model', isEqualTo: _ambulanciaSeleccionada!.model)
                                            .where('plate', isEqualTo: _ambulanciaSeleccionada!.plate)
                                            .limit(1)
                                            .get();
                                        if (query.docs.isNotEmpty) {
                                          await query.docs.first.reference.delete();
                                          setState(() {
                                            _ambulanciaSeleccionada = null;
                                          });
                                        } else {
                                          ScaffoldMessenger.of(context).showSnackBar(
                                            const SnackBar(content: Text('No se encontró la ambulancia para eliminar.')),
                                          );
                                        }
                                      }
                                    },
                                  ),
                                  // Botón de cerrar (X)
                                  IconButton(
                                    icon: const Icon(Icons.close, color: Colors.white, size: 28),
                                    tooltip: 'Cerrar',
                                    onPressed: () {
                                      setState(() {
                                        _ambulanciaSeleccionada = null;
                                      });
                                    },
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  );
                }
              } else {
                // Móvil: navegación normal
                return AmbulanceList(
                  ambulances: filtered,
                  onAddAmbulance: () async {
                    await showDialog<Ambulance>(
                      context: context,
                      builder: (_) => AddAmbulanceDialog(),
                    );
                  },
                  modoSeleccion: _modoSeleccion,
                  seleccionados: _seleccionados,
                  onToggleSeleccion: _toggleSeleccion,
                );
              }
            },
          ),
          // Mantenimientos desde Firestore
          StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance.collection('maintenances').orderBy('date', descending: true).snapshots(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }
              final docs = snapshot.data?.docs ?? [];
              final maintenances = docs.map((doc) {
                final data = doc.data() as Map<String, dynamic>;
                return Maintenance(
                  maintenanceId: data['maintenanceId'] ?? '',
                  maintenanceType: data['maintenanceType'] ?? '',
                  description: data['description'] ?? '',
                  date: (data['date'] as Timestamp?)?.toDate() ?? DateTime.now(),
                  cost: (data['cost'] ?? 0).toDouble(),
                  usuario: data['usuario'] as String?,
                );
              }).toList();
              final filtered = _searchText.isEmpty
                  ? maintenances
                  : maintenances.where((m) {
                      final dateStr = m.date.day.toString().padLeft(2, '0') + '/' +
                          m.date.month.toString().padLeft(2, '0') + '/' +
                          m.date.year.toString();
                      return m.maintenanceId.toLowerCase().contains(_searchText)
                          || m.maintenanceType.toLowerCase().contains(_searchText)
                          || m.description.toLowerCase().contains(_searchText)
                          || dateStr.contains(_searchText);
                    }).toList();
              final isWide = kIsWeb || MediaQuery.of(context).size.width > 900;
              if (isWide) {
                if (_mantenimientoSeleccionado == null) {
                  return MaintenanceList(
                    maintenances: filtered,
                    modoSeleccion: _modoSeleccion,
                    seleccionados: _seleccionados,
                    onToggleSeleccion: _toggleSeleccion,
                    onAddMaintenance: () async {
                      await showDialog<Maintenance>(
                        context: context,
                        builder: (_) => AddMaintenanceDialog(),
                      );
                    },
                    onTapMaintenance: (maintenance) {
                      setState(() {
                        _mantenimientoSeleccionado = maintenance;
                      });
                    },
                  );
                } else {
                  return Row(
                    children: [
                      Expanded(
                        child: MaintenanceList(
                          maintenances: filtered,
                          modoSeleccion: _modoSeleccion,
                          seleccionados: _seleccionados,
                          onToggleSeleccion: _toggleSeleccion,
                          onAddMaintenance: () async {
                            await showDialog<Maintenance>(
                              context: context,
                              builder: (_) => AddMaintenanceDialog(),
                            );
                          },
                          onTapMaintenance: (maintenance) {
                            setState(() {
                              _mantenimientoSeleccionado = maintenance;
                            });
                          },
                        ),
                      ),
                      Container(
                        width: 520,
                        constraints: const BoxConstraints(maxWidth: 600),
                        child: Stack(
                          children: [
                            MaintenanceDetailScreen(
                              maintenance: _mantenimientoSeleccionado!,
                              ambulanceModel: _mantenimientoSeleccionado!.maintenanceId,
                              showDeleteButton: false,
                              onSelectAmbulance: (a) {
                                setState(() {
                                  _indiceActual = 0;
                                  _ambulanciaSeleccionada = a;
                                  _controladorPagina.jumpToPage(0);
                                });
                              },
                            ),
                            Positioned(
                              top: 8,
                              right: 8,
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  IconButton(
                                    icon: const Icon(Icons.edit, color: Colors.white, size: 24),
                                    tooltip: 'Editar',
                                    onPressed: () async {
                                      final maintenance = _mantenimientoSeleccionado!;
                                      final maintenanceIdController = TextEditingController(text: maintenance.maintenanceId);
                                      final typeController = TextEditingController(text: maintenance.maintenanceType);
                                      final descController = TextEditingController(text: maintenance.description);
                                      final costController = TextEditingController(text: maintenance.cost.toString());
                                      DateTime selectedDate = maintenance.date;
                                      await showDialog(
                                        context: context,
                                        builder: (context) {
                                          return AlertDialog(
                                            title: const Text('Editar mantenimiento'),
                                            content: SingleChildScrollView(
                                              child: Column(
                                                mainAxisSize: MainAxisSize.min,
                                                children: [
                                                  TextField(
                                                    controller: maintenanceIdController,
                                                    decoration: const InputDecoration(labelText: 'Modelo-Placa'),
                                                  ),
                                                  TextField(
                                                    controller: typeController,
                                                    decoration: const InputDecoration(labelText: 'Tipo de mantenimiento'),
                                                  ),
                                                  TextField(
                                                    controller: descController,
                                                    decoration: const InputDecoration(labelText: 'Descripción'),
                                                  ),
                                                  TextField(
                                                    controller: costController,
                                                    decoration: const InputDecoration(labelText: 'Costo'),
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
                                                      .collection('maintenances')
                                                      .where('maintenanceId', isEqualTo: maintenance.maintenanceId)
                                                      .where('maintenanceType', isEqualTo: maintenance.maintenanceType)
                                                      .where('date', isEqualTo: Timestamp.fromDate(maintenance.date))
                                                      .limit(1)
                                                      .get();
                                                  if (query.docs.isNotEmpty) {
                                                    await query.docs.first.reference.update({
                                                      'maintenanceId': maintenanceIdController.text.trim(),
                                                      'maintenanceType': typeController.text.trim(),
                                                      'description': descController.text.trim(),
                                                      'cost': double.tryParse(costController.text) ?? 0.0,
                                                      'date': Timestamp.fromDate(selectedDate),
                                                    });
                                                    Navigator.pop(context);
                                                    ScaffoldMessenger.of(context).showSnackBar(
                                                      const SnackBar(content: Text('Mantenimiento actualizado.')),
                                                    );
                                                  } else {
                                                    Navigator.pop(context);
                                                    ScaffoldMessenger.of(context).showSnackBar(
                                                      const SnackBar(content: Text('No se encontró el mantenimiento para editar.')),
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
                                    icon: const Icon(Icons.delete, color: Colors.white, size: 26),
                                    tooltip: 'Eliminar',
                                    onPressed: () async {
                                      final confirmar = await showDialog<bool>(
                                        context: context,
                                        builder: (ctx) => AlertDialog(
                                          title: const Text('¿Eliminar mantenimiento?'),
                                          content: const Text('Esta acción no se puede deshacer.'),
                                          actions: [
                                            TextButton(
                                              onPressed: () => Navigator.pop(ctx, false),
                                              child: const Text('Cancelar'),
                                            ),
                                            TextButton(
                                              onPressed: () => Navigator.pop(ctx, true),
                                              child: const Text('Eliminar', style: TextStyle(color: Colors.red)),
                                            ),
                                          ],
                                        ),
                                      );
                                      if (confirmar == true) {
                                        final query = await FirebaseFirestore.instance
                                            .collection('maintenances')
                                            .where('maintenanceId', isEqualTo: _mantenimientoSeleccionado!.maintenanceId)
                                            .where('maintenanceType', isEqualTo: _mantenimientoSeleccionado!.maintenanceType)
                                            .where('date', isEqualTo: Timestamp.fromDate(_mantenimientoSeleccionado!.date))
                                            .limit(1)
                                            .get();
                                        if (query.docs.isNotEmpty) {
                                          await query.docs.first.reference.delete();
                                          setState(() {
                                            _mantenimientoSeleccionado = null;
                                          });
                                        } else {
                                          ScaffoldMessenger.of(context).showSnackBar(
                                            const SnackBar(content: Text('No se encontró el mantenimiento para eliminar.')),
                                          );
                                        }
                                      }
                                    },
                                  ),
                                  IconButton(
                                    icon: const Icon(Icons.close, color: Colors.white, size: 28),
                                    tooltip: 'Cerrar',
                                    onPressed: () {
                                      setState(() {
                                        _mantenimientoSeleccionado = null;
                                      });
                                    },
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  );
                }
              } else {
                return MaintenanceList(
                  maintenances: filtered,
                  modoSeleccion: _modoSeleccion,
                  seleccionados: _seleccionados,
                  onToggleSeleccion: _toggleSeleccion,
                  onAddMaintenance: () async {
                    await showDialog<Maintenance>(
                      context: context,
                      builder: (_) => AddMaintenanceDialog(),
                    );
                  },
                );
              }
            },
          ),
          // Piezas desde Firestore
          StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance.collection('parts').orderBy('date', descending: true).snapshots(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }
              final docs = snapshot.data?.docs ?? [];
              final parts = docs.map((doc) {
                final data = doc.data() as Map<String, dynamic>;
                return Part(
                  name: data['name'] ?? '',
                  maintenanceId: data['maintenanceId'] ?? '',
                  date: (data['date'] as Timestamp?)?.toDate() ?? DateTime.now(),
                  cost: (data['cost'] ?? 0).toDouble(),
                  quantity: (data['quantity'] ?? 0) as int,
                  usuario: data['usuario'] as String?,
                );
              }).toList();
              final filtered = _searchText.isEmpty
                  ? parts
                  : parts.where((p) {
                      final dateStr = p.date.day.toString().padLeft(2, '0') + '/' +
                          p.date.month.toString().padLeft(2, '0') + '/' +
                          p.date.year.toString();
                      return p.name.toLowerCase().contains(_searchText)
                          || p.maintenanceId.toLowerCase().contains(_searchText)
                          || dateStr.contains(_searchText);
                    }).toList();
              final isWide = MediaQuery.of(context).size.width > 900;
              return isWide
                  ? Row(
                      children: [
                        Expanded(
                          flex: _piezaSeleccionada == null ? 1 : 2,
                          child: PartList(
                            parts: filtered,
                            modoSeleccion: _modoSeleccion,
                            seleccionados: _seleccionados,
                            onToggleSeleccion: _toggleSeleccion,
                            onAddPart: () async {
                              await showDialog<Part>(
                                context: context,
                                builder: (_) => AddPartDialog(),
                              );
                            },
                            onTapPart: (part) {
                              setState(() {
                                _piezaSeleccionada = part;
                              });
                            },
                          ),
                        ),
                        if (_piezaSeleccionada != null)
                          Container(
                            width: 520,
                            constraints: const BoxConstraints(maxWidth: 600),
                            color: const Color(0xFFF8F8F8),
                            child: Stack(
                              children: [
                                Align(
                                  alignment: Alignment.topRight,
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      IconButton(
                                        icon: const Icon(Icons.edit, color: Colors.white, size: 24),
                                        tooltip: 'Editar',
                                        onPressed: () async {
                                          final part = _piezaSeleccionada!;
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
                                        icon: const Icon(Icons.delete, color: Colors.white, size: 26),
                                        tooltip: 'Eliminar',
                                        onPressed: () async {
                                          final confirmar = await showDialog<bool>(
                                            context: context,
                                            builder: (ctx) => AlertDialog(
                                              title: const Text('¿Eliminar pieza?'),
                                              content: const Text('Esta acción no se puede deshacer.'),
                                              actions: [
                                                TextButton(
                                                  onPressed: () => Navigator.pop(ctx, false),
                                                  child: const Text('Cancelar'),
                                                ),
                                                TextButton(
                                                  onPressed: () => Navigator.pop(ctx, true),
                                                  child: const Text('Eliminar', style: TextStyle(color: Colors.red)),
                                                ),
                                              ],
                                            ),
                                          );
                                          if (confirmar == true) {
                                            final query = await FirebaseFirestore.instance
                                                .collection('parts')
                                                .where('name', isEqualTo: _piezaSeleccionada!.name)
                                                .where('maintenanceId', isEqualTo: _piezaSeleccionada!.maintenanceId)
                                                .where('date', isEqualTo: Timestamp.fromDate(_piezaSeleccionada!.date))
                                                .limit(1)
                                                .get();
                                            if (query.docs.isNotEmpty) {
                                              await query.docs.first.reference.delete();
                                              setState(() {
                                                _piezaSeleccionada = null;
                                              });
                                            } else {
                                              ScaffoldMessenger.of(context).showSnackBar(
                                                const SnackBar(content: Text('No se encontró la pieza para eliminar.')),
                                              );
                                            }
                                          }
                                        },
                                      ),
                                      IconButton(
                                        icon: const Icon(Icons.close, color: Colors.white, size: 28),
                                        tooltip: 'Cerrar',
                                        onPressed: () {
                                          setState(() {
                                            _piezaSeleccionada = null;
                                          });
                                        },
                                      ),
                                    ],
                                  ),
                                ),
                                PartDetailScreen(
                                  part: _piezaSeleccionada!,
                                  onClose: () {
                                    setState(() {
                                      _piezaSeleccionada = null;
                                    });
                                  },
                                  onSelectAmbulance: (a) {
                                    setState(() {
                                      _indiceActual = 0;
                                      _ambulanciaSeleccionada = a;
                                      _controladorPagina.jumpToPage(0);
                                    });
                                  },
                                ),
                              ],
                            ),
                          ),
                      ],
                    )
                  : PartList(
                      parts: filtered,
                      modoSeleccion: _modoSeleccion,
                      seleccionados: _seleccionados,
                      onToggleSeleccion: _toggleSeleccion,
                      onAddPart: () async {
                        await showDialog<Part>(
                          context: context,
                          builder: (_) => AddPartDialog(),
                        );
                      },
                    );
            },
          ),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _indiceActual,
        onTap: (index) {
          setState(() {
            _indiceActual = index;
            _controladorPagina.animateToPage(
              index,
              duration: const Duration(milliseconds: 350),
              curve: Curves.easeInOut,
            );
          });
        },
        backgroundColor: Colors.red,
        selectedItemColor: Colors.white,
        unselectedItemColor: Colors.white.withOpacity(0.7),
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.directions_car),
            label: 'Ambulancias',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.build),
            label: 'Mantenimientos',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.settings),
            label: 'Piezas',
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.red,
        onPressed: _manejarBotonFlotante,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  @override
  void dispose() {
    _controladorPagina.dispose();
    super.dispose();
  }

  void _manejarBotonFlotante() {
    switch (_indiceActual) {
      case 0:
        _agregarNuevaAmbulancia();
        break;
      case 1:
        _agregarNuevoMantenimiento();
        break;
      case 2:
        _agregarNuevaPieza();
        break;
    }
  }

  Future<void> _agregarNuevaAmbulancia() async {
    await showDialog<Ambulance>(
      context: context,
      builder: (context) => const AddAmbulanceDialog(),
    );
    // Ya no es necesario recargar manualmente
  }

  Future<void> _agregarNuevoMantenimiento() async {
    final resultado = await showDialog<Maintenance>(
      context: context,
      builder: (context) => const AddMaintenanceDialog(),
    );
    if (resultado != null) {
      String maintenanceId = resultado.maintenanceId;
      // Si solo viene la placa, buscar el modelo y armar 'modelo - placa'
      if (!maintenanceId.contains('-')) {
        final query = await FirebaseFirestore.instance
            .collection('ambulances')
            .where('plate', isEqualTo: maintenanceId)
            .limit(1)
            .get();
        if (query.docs.isNotEmpty) {
          final data = query.docs.first.data();
          final model = data['model'] ?? '';
          if (model.isNotEmpty) {
            maintenanceId = '$model - $maintenanceId';
          }
        }
      } else {
        // Si ya viene en formato 'modelo - placa', asegurarse de que no haya espacios extra
        final parts = maintenanceId.split('-');
        if (parts.length == 2) {
          final model = parts[0].trim();
          final plate = parts[1].trim();
          maintenanceId = '$model - $plate';
        }
      }
      await FirebaseFirestore.instance.collection('maintenances').add({
        'maintenanceId': maintenanceId,
        'maintenanceType': resultado.maintenanceType,
        'description': resultado.description,
        'date': resultado.date,
        'cost': resultado.cost,
        'usuario': resultado.usuario ?? 'Desconocido',
      });
      setState(() {});
    }
  }

  Future<void> _agregarNuevaPieza() async {
    final resultado = await showDialog<Part>(
      context: context,
      builder: (context) => const AddPartDialog(),
    );
    if (resultado != null) {
      await FirebaseFirestore.instance.collection('parts').add({
        'name': resultado.name,
        'maintenanceId': resultado.maintenanceId,
        'date': resultado.date,
        'cost': resultado.cost,
        'quantity': resultado.quantity,
      });
      setState(() {});
    }
  }

  Widget _buildDrawer(BuildContext context) {
    return Drawer(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: ListView(
              padding: EdgeInsets.zero,
              children: [
                DrawerHeader(
                  decoration: const BoxDecoration(color: Colors.red),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: const [
                      Icon(Icons.local_hospital, color: Colors.white, size: 48),
                      SizedBox(height: 8),
                      Text('Menú', style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold)),
                    ],
                  ),
                ),
                ListTile(
                  leading: const Icon(Icons.info, color: Colors.red),
                  title: const Text('Acerca de', style: TextStyle(color: Colors.black87)),
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const AboutScreen()),
                    );
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.share, color: Colors.red),
                  title: const Text('Compartir'),
                  onTap: () {
                    Navigator.pop(context);
                    showDialog(
                      context: context,
                      builder: (ctx) => AlertDialog(
                        title: const Text('Compartir app'),
                        content: const SelectableText('https://tulinkdescarga.com/app'),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(ctx),
                            child: const Text('Cerrar'),
                          ),
                        ],
                      ),
                    );
                  },
                ),
                const Divider(),
                ListTile(
                  leading: const Icon(Icons.verified_user, color: Colors.red),
                  title: const Text('Usuarios permitidos'),
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const AllowedUsersScreen()),
                    );
                  },
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(left: 16, right: 16, bottom: 24),
            child: SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
                icon: const Icon(Icons.logout),
                label: const Text('Tu cuenta', style: TextStyle(fontWeight: FontWeight.bold)),
                onPressed: () async {
                  Navigator.pop(context);
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const AccountScreen()),
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ...existing code...
}

