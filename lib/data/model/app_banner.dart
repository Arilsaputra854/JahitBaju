class AppBanner {
  String? id;
  String? link;
  String? imageUrl;

  AppBanner({this.id, this.link, this.imageUrl});

  factory AppBanner.fromJson(Map<String, dynamic> json) {
    return AppBanner(
        id: json['id'],
        link: json['link'] ?? "",
        imageUrl: json['image_url'] ?? "");
  }

  Map<String, dynamic> toJson() {
    return {'id': id, 'link': link, 'image_url': imageUrl};
  }
}
