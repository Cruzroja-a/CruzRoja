// ambulance_model.dart
// import 'package:hive/hive.dart';
import 'package:json_annotation/json_annotation.dart';

part 'ambulance_model.g.dart';

@JsonSerializable() // <-- Esto habilita la generación de JSON
class Ambulance {
  final String model;
  final String plate;
  final DateTime addedDate;

  Ambulance({
    required this.model,
    required this.plate,
    required this.addedDate,
  });

  // -----------------------------
  // JSON Serialization (auto)
  // -----------------------------
  factory Ambulance.fromJson(Map<String, dynamic> json) =>
      _$AmbulanceFromJson(json);

  Map<String, dynamic> toJson() => _$AmbulanceToJson(this);

  // -----------------------------
  // Opcional: solo si lo usás
  // -----------------------------
  String get fullIdentification => '$model - $plate';
}
