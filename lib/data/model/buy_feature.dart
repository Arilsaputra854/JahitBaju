class BuyFeature {
  final String invoiceUrl;
  final DateTime expiryDate; // Diubah ke DateTime
  final String status;
  final String payerEmail;
  final String description;
  final String externalId;
  final int amount;

  BuyFeature({
    required this.invoiceUrl,
    required this.expiryDate,
    required this.status,
    required this.payerEmail,
    required this.description,
    required this.externalId,
    required this.amount,
  });

  factory BuyFeature.fromJson(Map<String, dynamic> json) {
    return BuyFeature(
      invoiceUrl: json['invoice_url'],
      expiryDate: DateTime.parse(json['expiry_date']), // Konversi dari String ke DateTime
      status: json['status'],
      payerEmail: json['payer_email'],
      description: json['description'],
      externalId: json['external_id'],
      amount: json['amount'],
    );
  }
}
