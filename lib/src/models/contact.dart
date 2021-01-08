import 'dart:convert';

Contact contactFromJson(String str) =>
    Contact.fromJson(json.decode(str)['data']['contact']);

String contactToJson(Contact data) => json.encode(data.toJson());

List<Contact> contactsFromJson(String str) => List<Contact>.from(
    json.decode(str)['data']['contacts'].map((x) => Contact.fromJson(x)));

String contactsToJson(List<Contact> data) =>
    json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class Contact {
  Contact({
    this.city,
    this.address,
    this.coordinates,
    this.prefix,
    this.phones,
    this.cellphones,
  });

  String city;
  String address;
  List<double> coordinates;
  int prefix;
  List<int> phones;
  List<int> cellphones;

  factory Contact.fromJson(Map<String, dynamic> json) => Contact(
        city: json["city"],
        address: json["address"],
        coordinates:
            List<double>.from(json["coordinates"].map((x) => x.toDouble())),
        prefix: json["prefix"],
        phones: List<int>.from(json["phones"].map((x) => x)),
        cellphones: List<int>.from(json["cellphones"].map((x) => x)),
      );

  Map<String, dynamic> toJson() => {
        "city": city,
        "address": address,
        "coordinates": List<dynamic>.from(coordinates.map((x) => x)),
        "prefix": prefix,
        "phones": List<dynamic>.from(phones.map((x) => x)),
        "cellphones": List<dynamic>.from(cellphones.map((x) => x)),
      };
}
