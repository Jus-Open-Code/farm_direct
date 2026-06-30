import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:farm_direct/core/constants/app_constants.dart';
import 'package:farm_direct/presentation/viewmodels/auth_viewmodel.dart';

class SelectRoleView extends StatelessWidget {
  const SelectRoleView({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final size = MediaQuery.of(context).size;
    final isWeb = size.width > 600;

    return Scaffold(
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Container(
            width: isWeb ? 500 : double.infinity,
            padding: isWeb ? const EdgeInsets.all(32) : EdgeInsets.zero,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'Choose Your Role',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: theme.colorScheme.primary,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Select how you would like to participate in the marketplace',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 14, color: Colors.grey),
                ),
                const SizedBox(height: 40),

                // Farmer Selection Card
                _RoleCard(
                  title: 'I am a Farmer',
                  description: 'I want to sell my fresh harvest, set my own prices, and connect directly with local buyers.',
                  icon: Icons.agriculture,
                  color: theme.colorScheme.primary,
                  onTap: () => _handleRoleSelect(context, 'farmer'),
                ),
                const SizedBox(height: 20),

                // Buyer Selection Card
                _RoleCard(
                  title: 'I am a Buyer',
                  description: 'I want to buy fresh products directly from local farms, explore regional rates, and purchase without middlemen.',
                  icon: Icons.shopping_basket,
                  color: Colors.orange[700]!,
                  onTap: () => _handleRoleSelect(context, 'buyer'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _handleRoleSelect(BuildContext context, String role) async {
    final authViewModel = Provider.of<AuthViewModel>(context, listen: false);
    final success = await authViewModel.selectRole(role);

    if (success && context.mounted) {
      if (role == 'farmer') {
        Navigator.pushReplacementNamed(context, AppConstants.routeFarmerProfileSetup);
      } else {
        Navigator.pushReplacementNamed(context, AppConstants.routeBuyerProfileSetup);
      }
    } else if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(authViewModel.errorMessage ?? 'Failed to select role. Please try again.'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
}

class _RoleCard extends StatelessWidget {
  final String title;
  final String description;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  const _RoleCard({
    required this.title,
    required this.description,
    required this.icon,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          border: Border.all(color: color.withOpacity(0.4), width: 1.5),
          borderRadius: BorderRadius.circular(16),
          color: theme.brightness == Brightness.dark
              ? const Color(0xFF1E1E1E)
              : Colors.white,
          boxShadow: [
            BoxShadow(
              color: color.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 4),
            )
          ],
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                color: color,
                size: 32,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: color,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    description,
                    style: TextStyle(
                      fontSize: 13,
                      color: theme.brightness == Brightness.dark
                          ? Colors.grey[400]
                          : Colors.grey[600],
                      height: 1.4,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.chevron_right,
              color: color.withOpacity(0.6),
            )
          ],
        ),
      ),
    );
  }
}
