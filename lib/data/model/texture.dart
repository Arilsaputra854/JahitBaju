
class TextureLook {
  String id;
  String title;
  String? urlTexture;
  String? hex;
  String? description;
  final DateTime? lastUpdate;

  TextureLook({
    required this.id,
    required this.title,
    this.urlTexture,
    this.hex,
    this.description,
    required this.lastUpdate,
  });

  factory TextureLook.fromJson(Map<String, dynamic> json) {
    return TextureLook(
      id: json['id'],
      title: json['title'],
      urlTexture: json['url_texture'],
      hex: json['hex'],
      description: json['description'],
      lastUpdate: json['last_update'] != null ? DateTime.parse(json['last_update']) : null,
    );
  }
}
