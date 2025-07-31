import 'package:cloud_firestore/cloud_firestore.dart';

class Project {
  final String id;
  final String nombre;
  final String descripcion;
  final String creador;
  final Map<String, String> miembros; // uid: rol

  Project({
    required this.id,
    required this.nombre,
    required this.descripcion,
    required this.creador,
    required this.miembros,
  });

  factory Project.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return Project(
      id: doc.id,
      nombre: data['nombre'] ?? '',
      descripcion: data['descripcion'] ?? '',
      creador: data['creador'] ?? '',
      miembros: Map<String, String>.from(data['miembros'] ?? {}),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'nombre': nombre,
      'descripcion': descripcion,
      'creador': creador,
      'miembros': miembros,
    };
  }
}
