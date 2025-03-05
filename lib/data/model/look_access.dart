class LookAccess {
  final String id;
  final String lookId;
  final String userId;
  final DateTime purchasedAt;
  final DateTime lastUpdate;

  LookAccess({
    required this.id,
    required this.lookId,
    required this.userId,
    required this.purchasedAt,
    required this.lastUpdate,
  });

  factory LookAccess.fromJson(Map<String, dynamic> json) {
    return LookAccess(
      id: json['id'],
      userId: json['user_id'],
      lookId: json['look_id'],
      lastUpdate: DateTime.parse(json['last_update']),
      purchasedAt: DateTime.parse(json['purchased_at']),
    );
  }
}
