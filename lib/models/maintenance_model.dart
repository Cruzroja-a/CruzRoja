// maintenance_model.dart
// import 'package:hive/hive.dart';
import 'package:json_annotation/json_annotation.dart';

part 'maintenance_model.g.dart';

@JsonSerializable()
class Maintenance {
  final String maintenanceId;
  final String maintenanceType;
  final String description;
  final double cost;
  final DateTime date;
  final String? usuario;

  Maintenance({
    required this.maintenanceId,
    required this.maintenanceType,
    required this.description,
    required this.cost,
    required this.date,
    this.usuario,
  });

  // JSON serialization boilerplate generado automáticamente
  factory Maintenance.fromJson(Map<String, dynamic> json) {
    DateTime fecha;
    final rawDate = json['date'];
    if (rawDate is String) {
      fecha = DateTime.parse(rawDate);
    } else if (rawDate is DateTime) {
      fecha = rawDate;
    } else if (rawDate != null && rawDate.toString().contains('Timestamp')) {
      // Firestore Timestamp
      fecha = (rawDate as dynamic).toDate();
    } else {
      fecha = DateTime.now();
    }
    return Maintenance(
      maintenanceId: json['maintenanceId'] as String,
      maintenanceType: json['maintenanceType'] as String,
      description: json['description'] as String,
      cost: (json['cost'] as num).toDouble(),
      date: fecha,
      usuario: json['usuario'] as String?,
    );
  }

  Map<String, dynamic> toJson() => _$MaintenanceToJson(this);

  // Métodos adicionales
  String get fullDescription => '$maintenanceType - $description';
}
