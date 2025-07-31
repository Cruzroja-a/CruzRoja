// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'maintenance_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

// Usar el método personalizado en el modelo

Map<String, dynamic> _$MaintenanceToJson(Maintenance instance) =>
    <String, dynamic>{
      'maintenanceId': instance.maintenanceId,
      'maintenanceType': instance.maintenanceType,
      'description': instance.description,
      'cost': instance.cost,
      'date': instance.date.toIso8601String(),
      'usuario': instance.usuario,
    };
