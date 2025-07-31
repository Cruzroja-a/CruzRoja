import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
// import 'package:cruzroja/models/ambulance_model.dart';

class AddMaintenanceDialog extends StatefulWidget {
  const AddMaintenanceDialog({super.key});

  @override
  State<AddMaintenanceDialog> createState() => _AddMaintenanceDialogState();
}

class _AddMaintenanceDialogState extends State<AddMaintenanceDialog> {
  final _formKey = GlobalKey<FormState>();
  final _typeController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _costController = TextEditingController();
  DateTime _selectedDate = DateTime.now();

  List<Map<String, String>> _ambulanceOptions = [];
  String? _selectedAmbulanceId;

  @override
  void initState() {
    super.initState();
    _cargarAmbulanciasFirestore();
  }

  Future<void> _cargarAmbulanciasFirestore() async {
    final snapshot = await FirebaseFirestore.instance.collection('ambulances').orderBy('createdAt', descending: true).get();
    setState(() {
      _ambulanceOptions = snapshot.docs
          .map((doc) {
            final data = doc.data();
            final model = data['model'] ?? '';
            final plate = data['plate'] ?? '';
            return {
              'id': plate.toString(),
              'label': '$model - $plate'
            };
          })
          .where((map) => map['id']!.isNotEmpty)
          .toList();
    });
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2000),
      lastDate: DateTime.now(),
      locale: const Locale('es', 'ES'),
      builder: (BuildContext context, Widget? child) {
        return Theme(
          data: ThemeData.light().copyWith(
            colorScheme: const ColorScheme.light(
              primary: Colors.red,
              onPrimary: Colors.white,
            ),
            dialogBackgroundColor: Colors.white,
          ),
          child: child!,
        );
      },
    );
    if (picked != null && picked != _selectedDate) {
      // Aquí está la corrección - agregar setState
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Agregar Mantenimiento', 
              style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
      content: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Sección Ambulancia Id (Dropdown)
              Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Ambulancia Id',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8),
                    DropdownButtonFormField<String>(
                      value: _selectedAmbulanceId,
                      items: _ambulanceOptions.map((option) {
                        return DropdownMenuItem<String>(
                          value: option['id'],
                          child: Text(option['label'] ?? ''),
                        );
                      }).toList(),
                      onChanged: (value) {
                        setState(() {
                          _selectedAmbulanceId = value;
                        });
                      },
                      decoration: const InputDecoration(
                        border: OutlineInputBorder(),
                        contentPadding: EdgeInsets.symmetric(horizontal: 12),
                      ),
                      validator: (value) => (value == null || value.isEmpty) ? 'Requerido' : null,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              
              // Sección Tipo de Mantenimiento
              Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Tipo de Mantenimiento',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8),
                    TextFormField(
                      controller: _typeController,
                      decoration: const InputDecoration(
                        border: OutlineInputBorder(),
                        contentPadding: EdgeInsets.symmetric(horizontal: 12),
                      ),
                      validator: (value) => value?.isEmpty ?? true ? 'Requerido' : null,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              
              // Sección Descripción
              Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Descripción',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8),
                    TextFormField(
                      controller: _descriptionController,
                      decoration: const InputDecoration(
                        border: OutlineInputBorder(),
                        contentPadding: EdgeInsets.symmetric(horizontal: 12),
                      ),
                    
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              
              // Sección Precio
              Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Precio',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8),
                    TextFormField(
                      controller: _costController,
                      decoration: const InputDecoration(
                        border: OutlineInputBorder(),
                        contentPadding: EdgeInsets.symmetric(horizontal: 12),
                        prefixText: '₡ ',
                      ),
                      keyboardType: TextInputType.number,
                      validator: (value) => value?.isEmpty ?? true ? 'Requerido' : null,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              
              // Sección Fecha (corregida)
              Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Fecha',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8),
                    InkWell(
                      onTap: () => _selectDate(context),
                      child: InputDecorator(
                        decoration: const InputDecoration(
                          border: OutlineInputBorder(),
                          contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 16),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              DateFormat('dd/MM/yyyy').format(_selectedDate),
                              style: const TextStyle(fontSize: 16),
                            ),
                            const Icon(Icons.calendar_today, size: 20),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.red),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Text('Cancelar', 
                style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
          ),
        ),
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.red,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
          ),
          onPressed: () async {
            if (_formKey.currentState!.validate()) {
              final user = FirebaseAuth.instance.currentUser;
              String usuario = 'Desconocido';
              if (user?.email != null) {
                final doc = await FirebaseFirestore.instance.collection('allowed_users').doc(user!.email!).get();
                usuario = doc.data()?['username'] ?? user.email ?? user.uid ?? 'Desconocido';
              } else if (user?.uid != null) {
                usuario = user!.uid;
              }
              // Buscar el label correspondiente al id seleccionado
              String maintenanceId = '';
              final selected = _ambulanceOptions.firstWhere(
                (opt) => opt['id'] == _selectedAmbulanceId,
                orElse: () => {'label': _selectedAmbulanceId ?? ''},
              );
              maintenanceId = selected['label'] ?? _selectedAmbulanceId ?? '';
              await FirebaseFirestore.instance.collection('maintenances').add({
                'maintenanceId': maintenanceId,
                'maintenanceType': _typeController.text,
                'description': _descriptionController.text,
                'cost': double.parse(_costController.text),
                'date': _selectedDate,
                'usuario': usuario,
              });
              Navigator.pop(context);
            }
          },
          child: const Text('Guardar', 
              style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        ),
      ],
    );
  }

  @override
  void dispose() {
    _typeController.dispose();
    _descriptionController.dispose();
    _costController.dispose();
    super.dispose();
  }
}