class MarketRateEntity {
  final String id;
  final String cropName;
  final String state;
  final String district;
  final double minPrice;
  final double maxPrice;
  final double modalPrice;
  final DateTime date;

  MarketRateEntity({
    required this.id,
    required this.cropName,
    required this.state,
    required this.district,
    required this.minPrice,
    required this.maxPrice,
    required this.modalPrice,
    required this.date,
  });
}
