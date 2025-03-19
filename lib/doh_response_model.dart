class DohResponse {
  final int statusCode;
  final String message;
  final Map<String, dynamic> data;

  DohResponse({
    required this.statusCode,
    required this.message,
    required this.data,
  });

  static DohResponse empty() {
    return DohResponse(data: {}, statusCode: 0, message: "");
  }
}
