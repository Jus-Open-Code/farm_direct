import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:farm_direct/core/constants/app_constants.dart';
import 'package:farm_direct/presentation/viewmodels/auth_viewmodel.dart';
import 'package:farm_direct/presentation/viewmodels/farmer_viewmodel.dart';
import '../home/farmer_home_view.dart';
import '../history/farmer_history_view.dart';
import '../add_product/add_product_view.dart';
import '../market_rate/farmer_market_rate_view.dart';

class FarmerDashboardView extends StatefulWidget {
  const FarmerDashboardView({super.key});

  @override
  State<FarmerDashboardView> createState() => _FarmerDashboardViewState();
}

class _FarmerDashboardViewState extends State<FarmerDashboardView> {
  int _currentIndex = 0;
  late String _farmerId;

  late List<Widget> _tabs;

  @override
  void initState() {
    super.initState();
    final authViewModel = Provider.of<AuthViewModel>(context, listen: false);
    _farmerId = authViewModel.user!.id;

    _tabs = [
      const FarmerHomeView(),
      const FarmerHistoryView(),
      const AddProductView(),
      const FarmerMarketRateView(),
    ];

    // Initial load
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<FarmerViewModel>(context, listen: false).fetchDashboardData(_farmerId);
    });
  }

  void _onTabTapped(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  void _logout() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirm Logout'),
        content: const Text('Are you sure you want to log out?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')),
          TextButton(onPressed: () => Navigator.pop(context, true), child: const Text('Logout')),
        ],
      ),
    );

    if (confirm == true && mounted) {
      await Provider.of<AuthViewModel>(context, listen: false).signOut();
      if (!mounted) return;
      Navigator.pushReplacementNamed(context, AppConstants.routeLogin);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final authViewModel = Provider.of<AuthViewModel>(context);
    final farmer = authViewModel.farmerProfile;

    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            const Icon(Icons.agriculture, size: 28),
            const SizedBox(width: 8),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Farm Direct', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                Text(
                  farmer?.farmerId ?? 'Farmer ID',
                  style: const TextStyle(fontSize: 10, color: Colors.white70),
                )
              ],
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_outlined),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('No new notifications')),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: _logout,
          ),
        ],
      ),
      body: IndexedStack(
        index: _currentIndex,
        children: _tabs,
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: _onTabTapped,
        selectedItemColor: theme.colorScheme.primary,
        unselectedItemColor: Colors.grey,
        type: BottomNavigationBarType.fixed,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home_outlined),
            activeIcon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.history),
            activeIcon: Icon(Icons.history_toggle_off),
            label: 'History',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.add_circle_outline),
            activeIcon: Icon(Icons.add_circle),
            label: 'Add Crop',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.trending_up),
            activeIcon: Icon(Icons.trending_up_rounded),
            label: 'Market Rates',
          ),
        ],
      ),
    );
  }
}
