import 'dart:convert';

ApiResponse apiResponseFromJson(String str, int code) =>
    ApiResponse.fromJson(json.decode(str), code);

class ApiResponse {
  ApiResponse({
    this.code,
    this.error,
    this.message,
    this.data,
  });

  int code;
  bool error;
  String message;
  Map<String, dynamic> data;

  factory ApiResponse.fromJson(Map<String, dynamic> json, int code) =>
      ApiResponse(
        code: code == null ? 0 : code,
        error: json['error'] == null ? true : json['error'],
        message: json['message'] == null
            ? 'No se puede conectar con el servidor'
            : json['message'],
        data: json['data'] == [] ? {} : json['data'],
      );
}
