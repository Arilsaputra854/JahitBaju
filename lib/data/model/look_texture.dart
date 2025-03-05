

import 'package:jahit_baju/data/model/texture.dart';

class LookTexture {
  String id;
  String lookId;
  String textureId;
  TextureLook texture;
  final DateTime? lastUpdate;

  LookTexture({
    required this.id,
    required this.lookId,
    required this.textureId,
    required this.texture,
    required this.lastUpdate,
  });

  factory LookTexture.fromJson(Map<String, dynamic> json) {
    return LookTexture(
      id: json['id'],
      lookId: json['look_id'],
      textureId: json['texture_id'],
      texture: TextureLook.fromJson(json['texture']),
      lastUpdate: json['last_update'] != null ? DateTime.parse(json['last_update']) : null,
    );
  }
}
