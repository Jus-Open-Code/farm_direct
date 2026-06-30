import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:farm_direct/presentation/viewmodels/auth_viewmodel.dart';
import 'package:farm_direct/presentation/viewmodels/farmer_viewmodel.dart';
import 'package:farm_direct/presentation/widgets/product_card.dart';

class FarmerHomeView extends StatelessWidget {
  const FarmerHomeView({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final authViewModel = Provider.of<AuthViewModel>(context);
    final farmerViewModel = Provider.of<FarmerViewModel>(context);
    final farmer = authViewModel.farmerProfile;

    return RefreshIndicator(
      onRefresh: () => farmerViewModel.fetchDashboardData(authViewModel.user!.id),
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Farmer Welcoming Message
            Text(
              'Welcome Back,',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey[600],
              ),
            ),
            Text(
              farmer?.name ?? 'Farmer Name',
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 20),

            // Performance Cards (Today's Orders / Today's Earnings)
            Row(
              children: [
                Expanded(
                  child: _buildStatCard(
                    title: "Today's Orders",
                    value: farmerViewModel.todayOrdersCount.toString(),
                    icon: Icons.receipt_long,
                    color: theme.colorScheme.primary,
                    context: context,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildStatCard(
                    title: "Today's Earnings",
                    value: '₹${farmerViewModel.todayEarnings.toStringAsFixed(2)}',
                    icon: Icons.currency_rupee,
                    color: Colors.orange[700]!,
                    context: context,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Recent Crops Listed
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Recent Products',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                if (farmerViewModel.myProducts.isNotEmpty)
                  TextButton(
                    onPressed: () {
                      // Navigate to dashboard tab index 2 (Add product) or list
                    },
                    child: const Text('View All'),
                  ),
              ],
            ),
            const SizedBox(height: 12),

            if (farmerViewModel.isLoading)
              const Center(
                child: Padding(
                  padding: EdgeInsets.all(32.0),
                  child: CircularProgressIndicator(),
                ),
              )
            else if (farmerViewModel.myProducts.isEmpty)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Column(
                  children: [
                    Icon(Icons.eco_outlined, size: 48, color: Colors.grey),
                    SizedBox(height: 8),
                    Text(
                      'No products listed yet.',
                      style: TextStyle(color: Colors.grey, fontWeight: FontWeight.bold),
                    ),
                    Text(
                      'Tap "Add Crop" below to list your first product.',
                      style: TextStyle(color: Colors.grey, fontSize: 12),
                    ),
                  ],
                ),
              )
            else
              GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: farmerViewModel.recentProducts.length,
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                  childAspectRatio: 0.8,
                ),
                itemBuilder: (context, index) {
                  final product = farmerViewModel.recentProducts[index];
                  return ProductCard(
                    product: product,
                    onTap: () {},
                    trailing: IconButton(
                      icon: const Icon(Icons.delete_outline, color: Colors.red, size: 20),
                      onPressed: () => _confirmDelete(context, farmerViewModel, product.id, authViewModel.user!.id),
                    ),
                  );
                },
              ),
            const SizedBox(height: 24),

            // Quick Actions Panel
            const Text(
              'Quick Actions',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildQuickAction(
                  label: 'Add Crop',
                  icon: Icons.add_circle,
                  color: Colors.green,
                  onTap: () {
                    // Navigate to index 2
                  },
                ),
                _buildQuickAction(
                  label: 'Rates',
                  icon: Icons.analytics,
                  color: Colors.blue,
                  onTap: () {
                    // Navigate to index 3
                  },
                ),
                _buildQuickAction(
                  label: 'Profile',
                  icon: Icons.account_circle,
                  color: Colors.amber[800]!,
                  onTap: () {
                    // Quick profile view dialog
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatCard({
    required String title,
    required String value,
    required IconData icon,
    required Color color,
    required BuildContext context,
  }) {
    final theme = Theme.of(context);
    return Card(
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          border: Border(left: BorderSide(color: color, width: 4)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  title,
                  style: const TextStyle(fontSize: 12, color: Colors.grey, fontWeight: FontWeight.bold),
                ),
                Icon(icon, color: color, size: 20),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              value,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: theme.brightness == Brightness.dark ? Colors.white : Colors.black87,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickAction({
    required String label,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Column(
        children: [
          CircleAvatar(
            radius: 26,
            backgroundColor: color.withOpacity(0.1),
            child: Icon(icon, color: color, size: 28),
          ),
          const SizedBox(height: 6),
          Text(
            label,
            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }

  void _confirmDelete(
    BuildContext context,
    FarmerViewModel vm,
    String productId,
    String farmerId,
  ) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Product'),
        content: const Text('Are you sure you want to remove this product listing?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')),
          TextButton(onPressed: () => Navigator.pop(context, true), child: const Text('Delete')),
        ],
      ),
    );

    if (confirm == true) {
      await vm.removeProduct(productId, farmerId);
    }
  }
}
