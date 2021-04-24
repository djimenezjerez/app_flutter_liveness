import 'dart:convert';

User userFromJson(String str) =>
    User.fromJson(json.decode(str)['data']['user']);

String userToJson(User data) => json.encode(data.toJson());

class User {
  User({
    this.id,
    this.fullName,
    this.degree,
    this.identityCard,
    this.pensionEntity,
    this.category,
    this.enrolled,
    this.verified,
  });

  final int id;
  final String fullName;
  final String degree;
  final String identityCard;
  final String pensionEntity;
  final String category;
  final bool enrolled;
  final bool verified;

  factory User.fromJson(Map<String, dynamic> json) => User(
        id: json["id"],
        fullName: json["full_name"],
        degree: json["degree"],
        identityCard: json["identity_card"],
        pensionEntity: json["pension_entity"],
        category: json["category"],
        enrolled: json["enrolled"],
        verified: json["verified"],
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "full_name": fullName,
        "degree": degree,
        "identity_card": identityCard,
        "pension_entity": pensionEntity,
        "category": category,
        "enrolled": enrolled,
        "verified": verified,
      };
}
