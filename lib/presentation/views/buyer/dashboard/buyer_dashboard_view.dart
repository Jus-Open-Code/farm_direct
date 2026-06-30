import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:farm_direct/core/constants/app_constants.dart';
import 'package:farm_direct/presentation/viewmodels/auth_viewmodel.dart';
import 'package:farm_direct/presentation/viewmodels/buyer_viewmodel.dart';
import 'package:farm_direct/presentation/viewmodels/market_rate_viewmodel.dart';
import '../home/buyer_home_view.dart';
import '../wishlist/wishlist_view.dart';
import '../cart/cart_view.dart';
import '../profile_tab/buyer_profile_tab_view.dart';

class BuyerDashboardView extends StatefulWidget {
  const BuyerDashboardView({super.key});

  @override
  State<BuyerDashboardView> createState() => _BuyerDashboardViewState();
}

class _BuyerDashboardViewState extends State<BuyerDashboardView> {
  int _currentIndex = 0;
  late String _buyerId;
  late List<Widget> _tabs;

  @override
  void initState() {
    super.initState();
    final authViewModel = Provider.of<AuthViewModel>(context, listen: false);
    _buyerId = authViewModel.user!.id;

    _tabs = [
      const BuyerHomeView(),
      const WishlistView(),
      const CartView(),
      const BuyerProfileTabView(),
    ];

    // Load initial buyer data
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final buyerVM = Provider.of<BuyerViewModel>(context, listen: false);
      buyerVM.fetchProducts();
      buyerVM.fetchCart(_buyerId);
      buyerVM.fetchWishlist(_buyerId);
      buyerVM.fetchOrders(_buyerId);

      // Load market rates since they are queryable by buyers too
      Provider.of<MarketRateViewModel>(context, listen: false).fetchTrendingCrops();
    });
  }

  void _onTabTapped(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final buyerViewModel = Provider.of<BuyerViewModel>(context);
    final cartCount = buyerViewModel.cartItems.length;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.orange[700],
        title: Row(
          children: const [
            Icon(Icons.shopping_basket, size: 28),
            SizedBox(width: 8),
            Text('Farm Direct', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          ],
        ),
        actions: [
          IconButton(
            icon: Stack(
              children: [
                const Icon(Icons.shopping_cart_outlined),
                if (cartCount > 0)
                  Positioned(
                    right: 0,
                    top: 0,
                    child: Container(
                      padding: const EdgeInsets.all(2),
                      decoration: BoxDecoration(
                        color: Colors.red,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      constraints: const BoxConstraints(
                        minWidth: 14,
                        minHeight: 14,
                      ),
                      child: Text(
                        '$cartCount',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 8,
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  )
              ],
            ),
            onPressed: () {
              setState(() {
                _currentIndex = 2; // Route to Cart Tab
              });
            },
          ),
          IconButton(
            icon: const Icon(Icons.notifications_outlined),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('No new notifications')),
              );
            },
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
        selectedItemColor: Colors.orange[700],
        unselectedItemColor: Colors.grey,
        type: BottomNavigationBarType.fixed,
        items: [
          const BottomNavigationBarItem(
            icon: Icon(Icons.home_outlined),
            activeIcon: Icon(Icons.home),
            label: 'Home',
          ),
          const BottomNavigationBarItem(
            icon: Icon(Icons.favorite_border),
            activeIcon: Icon(Icons.favorite),
            label: 'Wishlist',
          ),
          BottomNavigationBarItem(
            icon: Stack(
              children: [
                const Icon(Icons.shopping_cart_outlined),
                if (cartCount > 0)
                  Positioned(
                    right: 0,
                    top: 0,
                    child: Container(
                      padding: const EdgeInsets.all(2),
                      decoration: const BoxDecoration(color: Colors.red, shape: BoxShape.circle),
                      constraints: const BoxConstraints(minWidth: 8, minHeight: 8),
                    ),
                  )
              ],
            ),
            activeIcon: const Icon(Icons.shopping_cart),
            label: 'Cart',
          ),
          const BottomNavigationBarItem(
            icon: Icon(Icons.person_outline),
            activeIcon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
      ),
    );
  }
}
