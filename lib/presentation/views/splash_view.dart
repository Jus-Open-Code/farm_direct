import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:farm_direct/core/constants/app_constants.dart';
import 'package:farm_direct/presentation/viewmodels/auth_viewmodel.dart';

class SplashView extends StatefulWidget {
  const SplashView({super.key});

  @override
  State<SplashView> createState() => _SplashViewState();
}

class _SplashViewState extends State<SplashView> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );
    _animation = CurvedAnimation(parent: _controller, curve: Curves.easeInOut);
    _controller.forward();

    // Check auth status
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkAuth();
    });
  }

  Future<void> _checkAuth() async {
    // Wait for the animation to complete
    await Future.delayed(const Duration(milliseconds: 2000));
    if (!mounted) return;

    final authViewModel = Provider.of<AuthViewModel>(context, listen: false);
    final nextRouteName = await authViewModel.checkSession();

    if (!mounted) return;

    switch (nextRouteName) {
      case 'farmer_dashboard':
        Navigator.pushReplacementNamed(context, AppConstants.routeFarmerDashboard);
        break;
      case 'buyer_dashboard':
        Navigator.pushReplacementNamed(context, AppConstants.routeBuyerDashboard);
        break;
      case 'farmer_profile_setup':
        Navigator.pushReplacementNamed(context, AppConstants.routeFarmerProfileSetup);
        break;
      case 'buyer_profile_setup':
        Navigator.pushReplacementNamed(context, AppConstants.routeBuyerProfileSetup);
        break;
      case 'select_role':
        Navigator.pushReplacementNamed(context, AppConstants.routeSelectRole);
        break;
      default:
        Navigator.pushReplacementNamed(context, AppConstants.routeLogin);
        break;
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF1F8E9),
      body: Center(
        child: ScaleTransition(
          scale: _animation,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 120,
                height: 120,
                decoration: const BoxDecoration(
                  color: Color(0xFF2E7D32),
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.green,
                      blurRadius: 16,
                      offset: Offset(0, 4),
                    )
                  ],
                ),
                child: const Icon(
                  Icons.agriculture,
                  size: 64,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 24),
              const Text(
                'Farm Direct',
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF2E7D32),
                  letterSpacing: 1.2,
                ),
              ),
              const SizedBox(height: 12),
              const Text(
                'Connecting Farmers & Buyers Directly',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey,
                  fontStyle: FontStyle.italic,
                ),
              ),
              const SizedBox(height: 60),
              const SizedBox(
                width: 40,
                child: LinearProgressIndicator(
                  color: Color(0xFF2E7D32),
                  backgroundColor: Color(0xFFC8E6C9),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
