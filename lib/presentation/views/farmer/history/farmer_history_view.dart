import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:farm_direct/domain/entities/order_entity.dart';
import 'package:farm_direct/presentation/viewmodels/auth_viewmodel.dart';
import 'package:farm_direct/presentation/viewmodels/farmer_viewmodel.dart';

class FarmerHistoryView extends StatelessWidget {
  const FarmerHistoryView({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final authViewModel = Provider.of<AuthViewModel>(context);
    final farmerViewModel = Provider.of<FarmerViewModel>(context);
    final orders = farmerViewModel.myOrders;

    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: const PreferredSize(
          preferredSize: Size.fromHeight(50),
          child: TabBar(
            tabs: [
              Tab(text: 'Active Orders'),
              Tab(text: 'Completed / Cancelled'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            _buildOrderList(
              context,
              orders.where((o) => o.status == 'pending' || o.status == 'processing').toList(),
              farmerViewModel,
              authViewModel.user!.id,
            ),
            _buildOrderList(
              context,
              orders.where((o) => o.status == 'completed' || o.status == 'cancelled').toList(),
              farmerViewModel,
              authViewModel.user!.id,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOrderList(
    BuildContext context,
    List<OrderEntity> list,
    FarmerViewModel vm,
    String farmerId,
  ) {
    final theme = Theme.of(context);

    if (vm.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (list.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.inventory_2_outlined, size: 48, color: Colors.grey),
            SizedBox(height: 8),
            Text('No orders in this category.', style: TextStyle(color: Colors.grey)),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: list.length,
      itemBuilder: (context, index) {
        final order = list[index];

        return Card(
          margin: const EdgeInsets.only(bottom: 16),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Order ID: #${order.id.substring(0, 8).toUpperCase()}',
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    _buildStatusBadge(order.status),
                  ],
                ),
                const SizedBox(height: 8),
                Text('Buyer: ${order.buyerName}', style: const TextStyle(fontSize: 13, color: Colors.grey)),
                const Divider(height: 24),
                // Items
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
                const Divider(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Total Amount:', style: TextStyle(fontWeight: FontWeight.bold)),
                    Text(
                      '₹${order.totalAmount.toStringAsFixed(2)}',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: theme.colorScheme.primary,
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
                if (order.status == 'pending' || order.status == 'processing') ...[
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      if (order.status == 'pending') ...[
                        TextButton(
                          onPressed: () => vm.updateStatus(order.id, 'cancelled', farmerId),
                          style: TextButton.styleFrom(foregroundColor: Colors.red),
                          child: const Text('Cancel'),
                        ),
                        const SizedBox(width: 8),
                        ElevatedButton(
                          onPressed: () => vm.updateStatus(order.id, 'processing', farmerId),
                          child: const Text('Accept Order'),
                        ),
                      ] else if (order.status == 'processing') ...[
                        ElevatedButton(
                          onPressed: () => vm.updateStatus(order.id, 'completed', farmerId),
                          child: const Text('Mark Completed'),
                        ),
                      ]
                    ],
                  ),
                ],
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildStatusBadge(String status) {
    Color bg;
    Color fg;

    switch (status) {
      case 'completed':
        bg = Colors.green[50]!;
        fg = Colors.green[800]!;
        break;
      case 'cancelled':
        bg = Colors.red[50]!;
        fg = Colors.red[800]!;
        break;
      case 'processing':
        bg = Colors.blue[50]!;
        fg = Colors.blue[800]!;
        break;
      default:
        bg = Colors.orange[50]!;
        fg = Colors.orange[800]!;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        status.toUpperCase(),
        style: TextStyle(color: fg, fontSize: 10, fontWeight: FontWeight.bold),
      ),
    );
  }
}
