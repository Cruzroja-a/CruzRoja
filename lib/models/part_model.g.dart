// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'part_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Part _$PartFromJson(Map<String, dynamic> json) => Part(
      name: json['name'] as String,
      date: DateTime.parse(json['date'] as String),
      maintenanceId: json['maintenanceId'] as String? ?? '',
      cost: (json['cost'] as num?)?.toDouble() ?? 0.0,
      quantity: (json['quantity'] as num?)?.toInt() ?? 0,
      usuario: json['usuario'] as String?,
    );

Map<String, dynamic> _$PartToJson(Part instance) => <String, dynamic>{
      'name': instance.name,
      'date': instance.date.toIso8601String(),
      'maintenanceId': instance.maintenanceId,
      'cost': instance.cost,
      'quantity': instance.quantity,
      'usuario': instance.usuario,
    };
