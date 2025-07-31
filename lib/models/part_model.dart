// part_model.dart
// import 'package:hive/hive.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:intl/intl.dart';

part 'part_model.g.dart';

@JsonSerializable()
class Part {
  final String name;
  final DateTime date;
  final String maintenanceId;
  final double cost;
  final int quantity;
  final String? usuario;

  Part({
    required this.name,
    required this.date,
    this.maintenanceId = '',
    this.cost = 0.0,
    this.quantity = 0,
    this.usuario,
  });

  // Métodos adicionales que puedas necesitar
  String get formattedDate => DateFormat('dd/MM/yyyy').format(date);

  double get totalCost => cost * quantity;

  // JSON serialization
  factory Part.fromJson(Map<String, dynamic> json) => _$PartFromJson(json);

  Map<String, dynamic> toJson() => _$PartToJson(this);
}
