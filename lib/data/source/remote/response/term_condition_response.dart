class TermConditionResponse {
  bool error;
  String? data;

  TermConditionResponse({
    required this.error,
    this.data,
  });

  factory TermConditionResponse.fromJson(Map<String, dynamic> json) {
    return TermConditionResponse(
      error: json['error'] ?? false,
      data: json['data']['data'],
    );
  }
}
