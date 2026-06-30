import '../entities/market_rate_entity.dart';

abstract class MarketRateRepository {
  Future<List<MarketRateEntity>> getDailyMarketRates({
    String? search,
    String? state,
    String? district,
  });

  Future<List<MarketRateEntity>> getTrendingCrops();
}
