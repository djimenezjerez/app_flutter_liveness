import 'package:meta/meta.dart';
import 'dart:convert';

EconomicComplement economicComplementFromJson(String str) =>
    EconomicComplement.fromJson(
        json.decode(str)['data']['economic_complement']);

String economicComplementToJson(EconomicComplement data) =>
    json.encode(data.toJson());

List<EconomicComplement> economicComplementsFromJson(String str) =>
    List<EconomicComplement>.from(json
        .decode(str)['data']['data']
        .map((x) => EconomicComplement.fromJson(x)));

String economicComplementsToJson(List<EconomicComplement> data) =>
    json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class EconomicComplement {
  EconomicComplement({
    @required this.id,
    @required this.code,
    @required this.receptionDate,
    @required this.totalAmountSemester,
    @required this.difference,
    @required this.total,
    @required this.ecoComStateId,
    this.ecoComState,
    this.ecoComStateType,
    this.wfCurrentState,
    this.city,
    this.category,
  });

  final int id;
  final String code;
  final DateTime receptionDate;
  final String totalAmountSemester;
  final String difference;
  final String total;
  final int ecoComStateId;
  final String ecoComState;
  final String ecoComStateType;
  final String wfCurrentState;
  final String city;
  final String category;

  factory EconomicComplement.fromJson(Map<String, dynamic> json) =>
      EconomicComplement(
        id: json["id"],
        code: json["code"],
        receptionDate: DateTime.parse(json["reception_date"]),
        totalAmountSemester: json["total_amount_semester"],
        difference: json["difference"],
        total: json["total"],
        ecoComStateId: json["eco_com_state_id"],
        ecoComState:
            json["eco_com_state"] == null ? null : json["eco_com_state"],
        ecoComStateType: json["eco_com_state_type"] == null
            ? null
            : json["eco_com_state_type"],
        wfCurrentState:
            json["wf_current_state"] == null ? null : json["wf_current_state"],
        city: json["city"] == null ? null : json["city"],
        category: json["category"] == null ? null : json["category"],
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "code": code,
        "reception_date":
            "${receptionDate.year.toString().padLeft(4, '0')}-${receptionDate.month.toString().padLeft(2, '0')}-${receptionDate.day.toString().padLeft(2, '0')}",
        "total_amount_semester": totalAmountSemester,
        "difference": difference,
        "total": total,
        "eco_com_state_id": ecoComStateId == null ? null : ecoComStateId,
        "eco_com_state": ecoComState == null ? null : ecoComState,
        "eco_com_state_type": ecoComStateType == null ? null : ecoComStateType,
        "wf_current_state": wfCurrentState == null ? null : wfCurrentState,
        "city": city == null ? null : city,
        "category": category == null ? null : category,
      };
}
