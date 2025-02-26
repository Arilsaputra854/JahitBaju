
import 'package:jahit_baju/data/model/look.dart';

class Designer {
  String id;
  String name;
  List<Look>? looks;

  Designer({
    required this.id,
    required this.name,
    this.looks,
  });

  factory Designer.fromJson(Map<String, dynamic> json) {
    return Designer(
      id: json['id'],
      name: json['name'],
      looks: json['looks'] != null
          ? (json['looks'] as List).map((item) => Look.fromJson(item)).toList()
          : null,
    );
  }
}

