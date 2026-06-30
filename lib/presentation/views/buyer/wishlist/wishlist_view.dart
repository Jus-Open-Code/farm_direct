import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:farm_direct/core/constants/app_constants.dart';
import 'package:farm_direct/presentation/viewmodels/auth_viewmodel.dart';
import 'package:farm_direct/presentation/viewmodels/buyer_viewmodel.dart';
import 'package:farm_direct/presentation/widgets/product_card.dart';

class WishlistView extends StatelessWidget {
  const WishlistView({super.key});

  @override
  Widget build(BuildContext context) {
    final authViewModel = Provider.of<AuthViewModel>(context);
    final buyerViewModel = Provider.of<BuyerViewModel>(context);
    final buyerId = authViewModel.user!.id;
    final list = buyerViewModel.wishlist;

    if (buyerViewModel.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (list.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: const [
            Icon(Icons.favorite_border, size: 64, color: Colors.grey),
            SizedBox(height: 12),
            Text(
              'Your wishlist is empty',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.grey),
            ),
            Text(
              'Save crops you are interested in.',
              style: TextStyle(fontSize: 12, color: Colors.grey),
            ),
          ],
        ),
      );
    }

    return Scaffold(
      body: GridView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: list.length,
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
          childAspectRatio: 0.8,
        ),
        itemBuilder: (context, index) {
          final product = list[index];

          return ProductCard(
            product: product,
            onTap: () {
              Navigator.pushNamed(
                context,
                AppConstants.routeProductDetails,
                arguments: product,
              );
            },
            trailing: IconButton(
              icon: const Icon(Icons.favorite, color: Colors.red, size: 20),
              onPressed: () => buyerViewModel.toggleWishlist(buyerId, product),
            ),
          );
        },
      ),
    );
  }
}
