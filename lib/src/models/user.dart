import 'dart:convert';

User userFromJson(String str) => User.fromJson(json.decode(str));

String userToJson(User data) => json.encode(data.toJson());

class User {
  User({
    this.id,
    this.fullName,
    this.rank,
    this.ci,
  });

  int id;
  String fullName;
  String rank;
  String ci;

  factory User.fromJson(Map<String, dynamic> json) => User(
        id: json["id"],
        fullName: json["fullName"],
        rank: json["rank"],
        ci: json["ci"],
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "fullName": fullName,
        "rank": rank,
        "ci": ci,
      };

  String get nameWithRank => "$rank $fullName";
}
