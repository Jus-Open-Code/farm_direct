import 'package:flutter/material.dart';
import '../../domain/entities/market_rate_entity.dart';
import '../../domain/usecases/market_rate_usecases.dart';

class MarketRateViewModel extends ChangeNotifier {
  final GetMarketRatesUseCase _getMarketRatesUseCase;
  final GetTrendingCropsUseCase _getTrendingCropsUseCase;

  MarketRateViewModel({
    required GetMarketRatesUseCase getMarketRatesUseCase,
    required GetTrendingCropsUseCase getTrendingCropsUseCase,
  })  : _getMarketRatesUseCase = getMarketRatesUseCase,
        _getTrendingCropsUseCase = getTrendingCropsUseCase;

  List<MarketRateEntity> _marketRates = [];
  List<MarketRateEntity> _trendingCrops = [];
  bool _isLoading = false;
  String? _errorMessage;

  List<MarketRateEntity> get marketRates => _marketRates;
  List<MarketRateEntity> get trendingCrops => _trendingCrops;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  void _setError(String? message) {
    _errorMessage = message;
    notifyListeners();
  }

  Future<void> fetchMarketRates({
    String? search,
    String? state,
    String? district,
  }) async {
    _setLoading(true);
    _setError(null);
    try {
      _marketRates = await _getMarketRatesUseCase(
        search: search,
        state: state,
        district: district,
      );
      _setLoading(false);
    } catch (e) {
      _setError(e.toString());
      _setLoading(false);
    }
  }

  Future<void> fetchTrendingCrops() async {
    _setLoading(true);
    _setError(null);
    try {
      _trendingCrops = await _getTrendingCropsUseCase();
      _setLoading(false);
    } catch (e) {
      _setError(e.toString());
      _setLoading(false);
    }
  }
}
