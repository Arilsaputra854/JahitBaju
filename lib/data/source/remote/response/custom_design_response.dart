class CustomDesignResponse {
  bool error;
  String message;
  UploadedFile? file;

  CustomDesignResponse({
    required this.error,
    required this.message,
    this.file,
  });

  factory CustomDesignResponse.fromJson(Map<String, dynamic> json) {
    return CustomDesignResponse(
      error: json['error'] ?? false,
      message: json['message'] ?? '',
      file: json['file'] != null ? UploadedFile.fromJson(json['file']) : null,
    );
  }
}

class UploadedFile {
  String fieldname;
  String originalname;
  String encoding;
  String mimetype;
  String destination;
  String filename;
  String path;
  int size;

  UploadedFile({
    required this.fieldname,
    required this.originalname,
    required this.encoding,
    required this.mimetype,
    required this.destination,
    required this.filename,
    required this.path,
    required this.size,
  });

  factory UploadedFile.fromJson(Map<String, dynamic> json) {
    return UploadedFile(
      fieldname: json['fieldname'] ?? '',
      originalname: json['originalname'] ?? '',
      encoding: json['encoding'] ?? '',
      mimetype: json['mimetype'] ?? '',
      destination: json['destination'] ?? '',
      filename: json['filename'] ?? '',
      path: json['path'] ?? '',
      size: json['size'] ?? 0,
    );
  }
}
