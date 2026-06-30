import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:intl/intl.dart';
import 'package:farm_direct/domain/entities/product_entity.dart';
import 'package:farm_direct/presentation/viewmodels/auth_viewmodel.dart';
import 'package:farm_direct/presentation/viewmodels/buyer_viewmodel.dart';
import 'package:farm_direct/presentation/widgets/common_button.dart';

class ProductDetailsView extends StatefulWidget {
  const ProductDetailsView({super.key});

  @override
  State<ProductDetailsView> createState() => _ProductDetailsViewState();
}

class _ProductDetailsViewState extends State<ProductDetailsView> {
  double _quantity = 1.0;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final product = ModalRoute.of(context)!.settings.arguments as ProductEntity;
    final authViewModel = Provider.of<AuthViewModel>(context);
    final buyerViewModel = Provider.of<BuyerViewModel>(context);
    final buyerId = authViewModel.user!.id;
    final isFav = buyerViewModel.isFavorite(product.id);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        foregroundColor: theme.brightness == Brightness.dark ? Colors.white : Colors.black,
        elevation: 0,
        title: Text(product.name),
        actions: [
          IconButton(
            icon: Icon(
              isFav ? Icons.favorite : Icons.favorite_border,
              color: isFav ? Colors.red : Colors.grey,
            ),
            onPressed: () => buyerViewModel.toggleWishlist(buyerId, product),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image Box
            SizedBox(
              height: 250,
              width: double.infinity,
              child: product.imageUrl != null && product.imageUrl!.isNotEmpty
                  ? CachedNetworkImage(
                      imageUrl: product.imageUrl!,
                      fit: BoxFit.cover,
                      placeholder: (context, url) => Container(
                        color: Colors.grey[200],
                        child: const Center(child: CircularProgressIndicator()),
                      ),
                      errorWidget: (context, url, error) => Container(
                        color: Colors.orange[50],
                        child: Icon(Icons.eco, size: 80, color: Colors.orange[700]),
                      ),
                    )
                  : Container(
                      color: Colors.orange[50],
                      child: Icon(Icons.eco, size: 80, color: Colors.orange[700]),
                    ),
            ),

            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Category & Stock Badge
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.orange[50],
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: Colors.orange[100]!),
                        ),
                        child: Text(
                          product.category.toUpperCase(),
                          style: TextStyle(
                            color: Colors.orange[800],
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      Text(
                        'Available Stock: ${product.quantity} ${product.unit}',
                        style: const TextStyle(fontSize: 12, color: Colors.grey, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),

                  // Crop Name & Harvest date
                  Text(
                    product.name,
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      const Icon(Icons.calendar_month, size: 14, color: Colors.grey),
                      const SizedBox(width: 4),
                      Text(
                        'Harvest Date: ${DateFormat('yyyy-MM-dd').format(product.harvestDate)}',
                        style: const TextStyle(fontSize: 12, color: Colors.grey),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Price Tag
                  Text(
                    '₹${product.price} / ${product.unit}',
                    style: TextStyle(
                      fontSize: 24,
                      color: Colors.orange[700],
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Description
                  const Text(
                    'Description',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    product.description != null && product.description!.isNotEmpty
                        ? product.description!
                        : 'No description provided by the farmer. This crop is grown naturally and listed fresh directly from local farmlands.',
                    style: const TextStyle(
                      fontSize: 14,
                      color: Colors.grey,
                      height: 1.5,
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Contact / Location Info Card
                  Card(
                    color: Colors.grey[50],
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                      side: BorderSide(color: Colors.grey[200]!),
                    ),
                    child: const Padding(
                      padding: EdgeInsets.all(16),
                      child: Row(
                        children: [
                          Icon(Icons.verified_user, color: Colors.green, size: 36),
                          SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Direct Farm Verification',
                                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                                ),
                                SizedBox(height: 4),
                                Text(
                                  'This crop is verified, sourced directly, and completely free from broker margins.',
                                  style: TextStyle(fontSize: 11, color: Colors.grey),
                                ),
                              ],
                            ),
                          )
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 32),

                  // Quantity Picker
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Select Quantity',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                      Row(
                        children: [
                          IconButton(
                            icon: const Icon(Icons.remove_circle_outline),
                            onPressed: () {
                              if (_quantity > 1.0) {
                                setState(() {
                                    _quantity -= 1.0;
                                });
                              }
                            },
                          ),
                          Text(
                            '$_quantity ${product.unit}',
                            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                          ),
                          IconButton(
                            icon: const Icon(Icons.add_circle_outline),
                            onPressed: () {
                              if (_quantity < product.quantity) {
                                setState(() {
                                    _quantity += 1.0;
                                });
                              }
                            },
                          ),
                        ],
                      )
                    ],
                  ),
                  const SizedBox(height: 24),

                  // Add To Cart Button
                  CommonButton(
                    text: 'Add to Cart (₹${(product.price * _quantity).toStringAsFixed(2)})',
                    backgroundColor: Colors.orange[700],
                    onPressed: () async {
                      await buyerViewModel.addToCart(buyerId, product, _quantity);
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Added to Cart!'),
                            backgroundColor: Colors.green,
                          ),
                        );
                        Navigator.pop(context);
                      }
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
