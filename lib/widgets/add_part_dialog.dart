
// import 'package:cruzroja/models/ambulance_model.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AddPartDialog extends StatefulWidget {
  const AddPartDialog({super.key});

  @override
  State<AddPartDialog> createState() => _AddPartDialogState();
}

class _AddPartDialogState extends State<AddPartDialog> {
  List<String> _ambulanceIds = [];
  String? _selectedAmbulanceId;

  @override
  void initState() {
    super.initState();
    _cargarAmbulanciasFirestore();
  }

  Future<void> _cargarAmbulanciasFirestore() async {
    final snapshot = await FirebaseFirestore.instance.collection('ambulances').orderBy('createdAt', descending: true).get();
    setState(() {
      _ambulanceIds = snapshot.docs
          .map((doc) {
            final data = doc.data();
            final model = data['model'] ?? '';
            final plate = data['plate'] ?? '';
            return (model.isNotEmpty && plate.isNotEmpty) ? '$model-$plate' : '';
          })
          .where((id) => id.isNotEmpty)
          .toList();
    });
  }
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _costController = TextEditingController();
  DateTime _selectedDate = DateTime.now();
  int _quantity = 0;

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
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
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Piezas', 
              style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
      content: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 420),
        child: SingleChildScrollView(
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
                        items: _ambulanceIds
                            .map((id) => DropdownMenuItem(
                                  value: id,
                                  child: Text(id),
                                ))
                            .toList(),
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
                // Sección Nombre de pieza
                Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Nombre de pieza',
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 8),
                      TextFormField(
                        controller: _nameController,
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
                // Sección Cantidad
                Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Cantidad',
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 8),
                      InkWell(
                        child: InputDecorator(
                          decoration: const InputDecoration(
                            border: OutlineInputBorder(),
                            contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 16),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              IconButton(
                                icon: const Icon(Icons.remove),
                                onPressed: () {
                                  setState(() {
                                    if (_quantity > 0) _quantity--;
                                  });
                                },
                              ),
                              Text('$_quantity', style: const TextStyle(fontSize: 18)),
                              IconButton(
                                icon: const Icon(Icons.add),
                                onPressed: () {
                                  setState(() {
                                    _quantity++;
                                  });
                                },
                              ),
                            ],
                          ),
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
                      Row(
                        children: [
                          Expanded(
                            child: TextFormField(
                              controller: _costController,
                              keyboardType: TextInputType.number,
                              decoration: const InputDecoration(
                                prefixText: '₡ ',
                                border: OutlineInputBorder(),
                                contentPadding: EdgeInsets.symmetric(horizontal: 12),
                              ),
                              onTap: () {
                                if (_costController.text.isEmpty) {
                                  _costController.text = '';
                                }
                              },
                              validator: (value) {
                                if (value?.isEmpty ?? true) return 'Requerido';
                                if (double.tryParse(value!) == null) return 'Número inválido';
                                return null;
                              },
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                // Sección Fecha
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
            if (_formKey.currentState?.validate() ?? false) {
              final user = FirebaseAuth.instance.currentUser;
              String usuario = 'Desconocido';
              if (user?.email != null) {
                final doc = await FirebaseFirestore.instance.collection('allowed_users').doc(user!.email!).get();
                usuario = doc.data()?['username'] ?? user.email ?? user.uid ?? 'Desconocido';
              } else if (user?.uid != null) {
                usuario = user!.uid;
              }
              await FirebaseFirestore.instance.collection('parts').add({
                'name': _nameController.text,
                'date': _selectedDate,
                'maintenanceId': _selectedAmbulanceId ?? '',
                'cost': double.tryParse(_costController.text) ?? 0.0,
                'quantity': _quantity,
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
    _nameController.dispose();
    _costController.dispose();
    super.dispose();
  }
}