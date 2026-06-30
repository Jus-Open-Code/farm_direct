import '../../domain/entities/market_rate_entity.dart';

class MarketRateModel extends MarketRateEntity {
  MarketRateModel({
    required super.id,
    required super.cropName,
    required super.state,
    required super.district,
    required super.minPrice,
    required super.maxPrice,
    required super.modalPrice,
    required super.date,
  });

  factory MarketRateModel.fromJson(Map<String, dynamic> json) {
    return MarketRateModel(
      id: json['id'] as String,
      cropName: json['crop_name'] as String,
      state: json['state'] as String,
      district: json['district'] as String,
      minPrice: (json['min_price'] as num).toDouble(),
      maxPrice: (json['max_price'] as num).toDouble(),
      modalPrice: (json['modal_price'] as num).toDouble(),
      date: DateTime.parse(json['date'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'crop_name': cropName,
      'state': state,
      'district': district,
      'min_price': minPrice,
      'max_price': maxPrice,
      'modal_price': modalPrice,
      'date': date.toIso8601String().split('T')[0],
    };
  }
}
