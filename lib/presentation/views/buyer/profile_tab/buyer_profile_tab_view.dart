import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:farm_direct/core/constants/app_constants.dart';
import 'package:farm_direct/presentation/viewmodels/auth_viewmodel.dart';
import 'package:farm_direct/presentation/viewmodels/buyer_viewmodel.dart';

class BuyerProfileTabView extends StatelessWidget {
  const BuyerProfileTabView({super.key});

  void _logout(BuildContext context) async {
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

    if (confirm == true && context.mounted) {
      await Provider.of<AuthViewModel>(context, listen: false).signOut();
      if (!context.mounted) return;
      Navigator.pushReplacementNamed(context, AppConstants.routeLogin);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final authViewModel = Provider.of<AuthViewModel>(context);
    final buyerViewModel = Provider.of<BuyerViewModel>(context);
    final buyer = authViewModel.buyerProfile;
    final orders = buyerViewModel.orders;

    return RefreshIndicator(
      onRefresh: () => buyerViewModel.fetchOrders(authViewModel.user!.id),
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // User Header Info
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 36,
                      backgroundColor: Colors.orange[50],
                      backgroundImage: buyer?.profilePhoto != null
                          ? NetworkImage(buyer!.profilePhoto!)
                          : null,
                      child: buyer?.profilePhoto == null
                          ? Icon(Icons.person, size: 36, color: Colors.orange[700])
                          : null,
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            buyer?.name ?? 'Buyer Name',
                            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            buyer?.phone ?? 'Phone Number',
                            style: const TextStyle(color: Colors.grey, fontSize: 13),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            authViewModel.user?.email ?? 'Email',
                            style: const TextStyle(color: Colors.grey, fontSize: 12),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),

            // Delivery Address card
            const Text('Delivery Address', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Card(
              child: ListTile(
                leading: Icon(Icons.location_on, color: Colors.orange[700]),
                title: Text(buyer?.address ?? 'No address registered'),
                subtitle: const Text('Primary Delivery Address', style: TextStyle(fontSize: 11)),
              ),
            ),
            const SizedBox(height: 20),

            // Order History Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Order History', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                Text('${orders.length} orders', style: const TextStyle(color: Colors.grey, fontSize: 12)),
              ],
            ),
            const SizedBox(height: 8),

            if (buyerViewModel.isLoading)
              const Center(child: CircularProgressIndicator())
            else if (orders.isEmpty)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Colors.grey[50],
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Column(
                  children: [
                    Icon(Icons.inventory_outlined, size: 40, color: Colors.grey),
                    SizedBox(height: 8),
                    Text('No orders placed yet.', style: TextStyle(color: Colors.grey)),
                  ],
                ),
              )
            else
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: orders.length,
                itemBuilder: (context, index) {
                  final order = orders[index];
                  return Card(
                    margin: const EdgeInsets.only(bottom: 12),
                    child: ExpansionTile(
                      leading: Icon(
                        order.status == 'completed'
                            ? Icons.check_circle
                            : order.status == 'cancelled'
                                ? Icons.cancel
                                : Icons.pending_actions,
                        color: order.status == 'completed'
                            ? Colors.green
                            : order.status == 'cancelled'
                                ? Colors.red
                                : Colors.orange[700],
                      ),
                      title: Text('Order #${order.id.substring(0, 8).toUpperCase()}'),
                      subtitle: Text('Status: ${order.status.toUpperCase()}'),
                      children: [
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              ListView.builder(
                                shrinkWrap: true,
                                physics: const NeverScrollableScrollPhysics(),
                                itemCount: order.items.length,
                                itemBuilder: (context, i) {
                                  final item = order.items[i];
                                  return Padding(
                                    padding: const EdgeInsets.symmetric(vertical: 4),
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text('${item.productName} (x${item.quantity})'),
                                        Text('₹${(item.price * item.quantity).toStringAsFixed(2)}'),
                                      ],
                                    ),
                                  );
                                },
                              ),
                              const Divider(),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  const Text('Total:', style: TextStyle(fontWeight: FontWeight.bold)),
                                  Text(
                                    '₹${order.totalAmount.toStringAsFixed(2)}',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: Colors.orange[700],
                                      fontSize: 16,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),
                            ],
                          ),
                        )
                      ],
                    ),
                  );
                },
              ),
            const SizedBox(height: 32),

            // Logout row
            ListTile(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              tileColor: Colors.red[50],
              leading: const Icon(Icons.logout, color: Colors.red),
              title: const Text('Sign Out', style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
              onTap: () => _logout(context),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}
