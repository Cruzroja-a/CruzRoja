// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'ambulance_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Ambulance _$AmbulanceFromJson(Map<String, dynamic> json) => Ambulance(
      model: json['model'] as String,
      plate: json['plate'] as String,
      addedDate: DateTime.parse(json['addedDate'] as String),
    );

Map<String, dynamic> _$AmbulanceToJson(Ambulance instance) => <String, dynamic>{
      'model': instance.model,
      'plate': instance.plate,
      'addedDate': instance.addedDate.toIso8601String(),
    };
