import '../../domain/entities/market_rate_entity.dart';
import '../../domain/repositories/market_rate_repository.dart';
import '../datasources/supabase_remote_datasource.dart';

class MarketRateRepositoryImpl implements MarketRateRepository {
  final SupabaseRemoteDataSource dataSource;

  MarketRateRepositoryImpl(this.dataSource);

  @override
  Future<List<MarketRateEntity>> getDailyMarketRates({
    String? search,
    String? state,
    String? district,
  }) async {
    try {
      return await dataSource.getDailyMarketRates(
        search: search,
        state: state,
        district: district,
      );
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<List<MarketRateEntity>> getTrendingCrops() async {
    try {
      return await dataSource.getTrendingCrops();
    } catch (e) {
      rethrow;
    }
  }
}
