
class Texture {
  String id;
  String title;
  String? urlTexture;
  String? hex;
  String? description;

  Texture({
    required this.id,
    required this.title,
    this.urlTexture,
    this.hex,
    this.description,
  });

  factory Texture.fromJson(Map<String, dynamic> json) {
    return Texture(
      id: json['id'],
      title: json['title'],
      urlTexture: json['url_texture'],
      hex: json['hex'],
      description: json['description'],
    );
  }
}
