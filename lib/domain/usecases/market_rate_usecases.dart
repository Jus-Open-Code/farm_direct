import '../entities/market_rate_entity.dart';
import '../repositories/market_rate_repository.dart';

class GetMarketRatesUseCase {
  final MarketRateRepository repository;
  GetMarketRatesUseCase(this.repository);

  Future<List<MarketRateEntity>> call({
    String? search,
    String? state,
    String? district,
  }) {
    return repository.getDailyMarketRates(
      search: search,
      state: state,
      district: district,
    );
  }
}

class GetTrendingCropsUseCase {
  final MarketRateRepository repository;
  GetTrendingCropsUseCase(this.repository);

  Future<List<MarketRateEntity>> call() {
    return repository.getTrendingCrops();
  }
}
