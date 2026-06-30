import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:farm_direct/presentation/viewmodels/auth_viewmodel.dart';
import 'package:farm_direct/presentation/viewmodels/buyer_viewmodel.dart';
import 'package:farm_direct/presentation/widgets/common_button.dart';

class CartView extends StatelessWidget {
  const CartView({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final authViewModel = Provider.of<AuthViewModel>(context);
    final buyerViewModel = Provider.of<BuyerViewModel>(context);
    final buyerId = authViewModel.user!.id;
    final items = buyerViewModel.cartItems;

    if (buyerViewModel.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (items.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.shopping_cart_outlined, size: 64, color: Colors.grey),
            SizedBox(height: 12),
            Text(
              'Your cart is empty',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.grey),
            ),
            Text(
              'Add fresh products from the homepage.',
              style: TextStyle(fontSize: 12, color: Colors.grey),
            ),
          ],
        ),
      );
    }

    return Scaffold(
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: items.length,
              itemBuilder: (context, index) {
                final item = items[index];

                return Card(
                  margin: const EdgeInsets.only(bottom: 12),
                  child: Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: Row(
                      children: [
                        // Thumbnail Image
                        ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: SizedBox(
                            width: 60,
                            height: 60,
                            child: item.product.imageUrl != null && item.product.imageUrl!.isNotEmpty
                                ? CachedNetworkImage(
                                    imageUrl: item.product.imageUrl!,
                                    fit: BoxFit.cover,
                                    errorWidget: (context, url, err) => Container(
                                      color: Colors.orange[50],
                                      child: Icon(Icons.eco, color: Colors.orange[700]),
                                    ),
                                  )
                                : Container(
                                    color: Colors.orange[50],
                                    child: Icon(Icons.eco, color: Colors.orange[700]),
                                  ),
                          ),
                        ),
                        const SizedBox(width: 12),

                        // Title / Price details
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                item.product.name,
                                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: 4),
                              Text(
                                '₹${item.product.price} / ${item.product.unit}',
                                style: TextStyle(color: Colors.orange[700], fontSize: 13, fontWeight: FontWeight.bold),
                              ),
                            ],
                          ),
                        ),

                        // Quantity +/- Control
                        Row(
                          children: [
                            IconButton(
                              icon: const Icon(Icons.remove_circle_outline, size: 20),
                              onPressed: () => buyerViewModel.updateCartQuantity(
                                buyerId,
                                item.product.id,
                                item.quantity - 1.0,
                              ),
                            ),
                            Text(
                              '${item.quantity.toInt()}',
                              style: const TextStyle(fontWeight: FontWeight.bold),
                            ),
                            IconButton(
                              icon: const Icon(Icons.add_circle_outline, size: 20),
                              onPressed: () => buyerViewModel.updateCartQuantity(
                                buyerId,
                                item.product.id,
                                item.quantity + 1.0,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),

          // Total & Checkout card
          Card(
            margin: const EdgeInsets.all(16),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Total Amount:', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                      Text(
                        '₹${buyerViewModel.cartTotal.toStringAsFixed(2)}',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.orange[700],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  CommonButton(
                    text: 'Place Order (COD)',
                    backgroundColor: Colors.orange[700],
                    onPressed: () async {
                      final name = authViewModel.buyerProfile?.name ?? 'Buyer';
                      final success = await buyerViewModel.checkout(buyerId, name);

                      if (success && context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Order placed successfully!'),
                            backgroundColor: Colors.green,
                          ),
                        );
                      } else if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(buyerViewModel.errorMessage ?? 'Checkout failed.'),
                            backgroundColor: Colors.red,
                          ),
                        );
                      }
                    },
                  )
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
