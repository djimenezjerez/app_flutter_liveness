import 'package:meta/meta.dart';
import 'dart:convert';
import 'package:muserpol_app/src/models/eco_com_state_type.dart';

EcoComState ecoComStateFromJson(String str) =>
    EcoComState.fromJson(json.decode(str)['data']['eco_com_state']);

String ecoComStateToJson(EcoComState data) => json.encode(data.toJson());

List<EcoComState> ecoComStatesFromJson(String str) =>
    List<EcoComState>.from(json
        .decode(str)['data']['eco_com_states']
        .map((x) => EcoComState.fromJson(x)));

String ecoComStatesToJson(List<EcoComState> data) =>
    json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class EcoComState {
  EcoComState({
    @required this.id,
    @required this.ecoComStateTypeId,
    @required this.name,
    @required this.ecoComStateType,
  });

  final int id;
  final int ecoComStateTypeId;
  final String name;
  final EcoComStateType ecoComStateType;

  factory EcoComState.fromJson(Map<String, dynamic> json) => EcoComState(
        id: json["id"],
        ecoComStateTypeId: json["eco_com_state_type_id"],
        name: json["name"],
        ecoComStateType: EcoComStateType.fromJson(json["eco_com_state_type"]),
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "eco_com_state_type_id": ecoComStateTypeId,
        "name": name,
        "eco_com_state_type": ecoComStateType.toJson(),
      };
}
