import 'package:meta/meta.dart';
import 'dart:convert';

EcoComStateType ecoComStateTypeFromJson(String str) =>
    EcoComStateType.fromJson(json.decode(str));

String ecoComStateTypeToJson(EcoComStateType data) =>
    json.encode(data.toJson());

class EcoComStateType {
  EcoComStateType({
    @required this.id,
    @required this.name,
  });

  final int id;
  final String name;

  factory EcoComStateType.fromJson(Map<String, dynamic> json) =>
      EcoComStateType(
        id: json["id"],
        name: json["name"],
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "name": name,
      };
}
