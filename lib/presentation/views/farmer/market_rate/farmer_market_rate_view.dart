import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:farm_direct/core/constants/app_constants.dart';
import 'package:farm_direct/presentation/viewmodels/market_rate_viewmodel.dart';

class FarmerMarketRateView extends StatefulWidget {
  const FarmerMarketRateView({super.key});

  @override
  State<FarmerMarketRateView> createState() => _FarmerMarketRateViewState();
}

class _FarmerMarketRateViewState extends State<FarmerMarketRateView> {
  final _searchController = TextEditingController();
  String? _selectedState;
  String? _selectedDistrict;
  List<String> _districts = [];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final vm = Provider.of<MarketRateViewModel>(context, listen: false);
      vm.fetchMarketRates();
      vm.fetchTrendingCrops();
    });
  }

  void _onFilterChanged() {
    Provider.of<MarketRateViewModel>(context, listen: false).fetchMarketRates(
      search: _searchController.text.trim(),
      state: _selectedState,
      district: _selectedDistrict,
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final vm = Provider.of<MarketRateViewModel>(context);

    return Scaffold(
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Trending Mandi Crops Today',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),

            // Horizontal trending list
            SizedBox(
              height: 110,
              child: vm.trendingCrops.isEmpty
                  ? const Center(child: Text('Loading trends...', style: TextStyle(color: Colors.grey)))
                  : ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: vm.trendingCrops.length,
                      itemBuilder: (context, index) {
                        final crop = vm.trendingCrops[index];
                        return Container(
                          width: 140,
                          margin: const EdgeInsets.only(right: 12),
                          child: Card(
                            color: theme.colorScheme.primaryContainer,
                            child: Padding(
                              padding: const EdgeInsets.all(12),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    crop.cropName,
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: theme.colorScheme.onPrimaryContainer,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    '₹${crop.modalPrice}/kg',
                                    style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                                  ),
                                  const SizedBox(height: 4),
                                  Row(
                                    children: [
                                      const Icon(Icons.trending_up, size: 12, color: Colors.green),
                                      const SizedBox(width: 4),
                                      Text(
                                        '${crop.district}',
                                        style: const TextStyle(fontSize: 9, color: Colors.grey),
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      },
                    ),
            ),
            const SizedBox(height: 24),

            // MANDI LIST FILTERING
            const Text(
              'Mandi Rate Query',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),

            // Search crop
            TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search Crop (e.g. Tomato, Onion)',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: IconButton(
                  icon: const Icon(Icons.arrow_forward),
                  onPressed: _onFilterChanged,
                ),
              ),
              onSubmitted: (_) => _onFilterChanged(),
            ),
            const SizedBox(height: 12),

            // State & District selectors side by side
            Row(
              children: [
                Expanded(
                  child: DropdownButtonFormField<String>(
                    value: _selectedState,
                    decoration: const InputDecoration(
                      labelText: 'State',
                      contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                    ),
                    items: AppConstants.indianStates.map((state) {
                      return DropdownMenuItem(value: state, child: Text(state, style: const TextStyle(fontSize: 12)));
                    }).toList(),
                    onChanged: (val) {
                      setState(() {
                        _selectedState = val;
                        _selectedDistrict = null;
                        _districts = AppConstants.stateDistricts[val!] ?? [];
                      });
                      _onFilterChanged();
                    },
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: DropdownButtonFormField<String>(
                    value: _selectedDistrict,
                    decoration: const InputDecoration(
                      labelText: 'District',
                      contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                    ),
                    items: _districts.map((dist) {
                      return DropdownMenuItem(value: dist, child: Text(dist, style: const TextStyle(fontSize: 12)));
                    }).toList(),
                    onChanged: (val) {
                      setState(() {
                        _selectedDistrict = val;
                      });
                      _onFilterChanged();
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Mandi list output
            if (vm.isLoading)
              const Center(child: CircularProgressIndicator())
            else if (vm.marketRates.isEmpty)
              const Center(
                child: Padding(
                  padding: EdgeInsets.all(32.0),
                  child: Text('No mandi rates found for selected filters.', style: TextStyle(color: Colors.grey)),
                ),
              )
            else
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: vm.marketRates.length,
                itemBuilder: (context, index) {
                  final rate = vm.marketRates[index];
                  return Card(
                    margin: const EdgeInsets.only(bottom: 10),
                    child: ListTile(
                      title: Text(rate.cropName, style: const TextStyle(fontWeight: FontWeight.bold)),
                      subtitle: Text('${rate.district}, ${rate.state}'),
                      trailing: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            '₹${rate.modalPrice} / kg',
                            style: TextStyle(
                              color: theme.colorScheme.primary,
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                          Text(
                            'Range: ₹${rate.minPrice} - ₹${rate.maxPrice}',
                            style: const TextStyle(fontSize: 10, color: Colors.grey),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
          ],
        ),
      ),
    );
  }
}
