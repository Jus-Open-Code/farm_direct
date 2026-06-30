import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

// Core Configurations
import 'package:farm_direct/core/constants/app_constants.dart';
import 'package:farm_direct/core/theme/app_theme.dart';

// Data layer
import 'package:farm_direct/data/datasources/supabase_remote_datasource.dart';
import 'package:farm_direct/data/repositories/auth_repository_impl.dart';
import 'package:farm_direct/data/repositories/profile_repository_impl.dart';
import 'package:farm_direct/data/repositories/product_repository_impl.dart';
import 'package:farm_direct/data/repositories/order_repository_impl.dart';
import 'package:farm_direct/data/repositories/market_rate_repository_impl.dart';

// Domain Use Cases
import 'package:farm_direct/domain/usecases/auth_usecases.dart';
import 'package:farm_direct/domain/usecases/profile_usecases.dart';
import 'package:farm_direct/domain/usecases/product_usecases.dart';
import 'package:farm_direct/domain/usecases/order_usecases.dart';
import 'package:farm_direct/domain/usecases/market_rate_usecases.dart';

// Presentation ViewModels
import 'package:farm_direct/presentation/viewmodels/auth_viewmodel.dart';
import 'package:farm_direct/presentation/viewmodels/farmer_viewmodel.dart';
import 'package:farm_direct/presentation/viewmodels/buyer_viewmodel.dart';
import 'package:farm_direct/presentation/viewmodels/market_rate_viewmodel.dart';

// Presentation Views
import 'package:farm_direct/presentation/views/splash_view.dart';
import 'package:farm_direct/presentation/views/auth/login_view.dart';
import 'package:farm_direct/presentation/views/auth/signup_view.dart';
import 'package:farm_direct/presentation/views/auth/select_role_view.dart';
import 'package:farm_direct/presentation/views/farmer/profile/create_farmer_profile_view.dart';
import 'package:farm_direct/presentation/views/buyer/profile/create_buyer_profile_view.dart';
import 'package:farm_direct/presentation/views/farmer/dashboard/farmer_dashboard_view.dart';
import 'package:farm_direct/presentation/views/buyer/dashboard/buyer_dashboard_view.dart';
import 'package:farm_direct/presentation/views/buyer/product_details/product_details_view.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Supabase.
  // Make sure you replace YOUR_SUPABASE_PROJECT_URL and YOUR_SUPABASE_ANON_KEY in AppConstants
  // before building or running the project.
  await Supabase.initialize(
    url: AppConstants.supabaseUrl,
    anonKey: AppConstants.supabaseAnonKey,
  );

  // Initialize Repositories and Use Cases for Dependency Injection
  final supabaseClient = Supabase.instance.client;
  final remoteDataSource = SupabaseRemoteDataSource(supabaseClient);

  final authRepository = AuthRepositoryImpl(remoteDataSource);
  final profileRepository = ProfileRepositoryImpl(remoteDataSource);
  final productRepository = ProductRepositoryImpl(remoteDataSource);
  final orderRepository = OrderRepositoryImpl(remoteDataSource);
  final marketRateRepository = MarketRateRepositoryImpl(remoteDataSource);

  runApp(
    MultiProvider(
      providers: [
        // Auth UseCases & ViewModel
        Provider<SignInUseCase>(create: (_) => SignInUseCase(authRepository)),
        Provider<SignUpUseCase>(create: (_) => SignUpUseCase(authRepository)),
        Provider<SignOutUseCase>(create: (_) => SignOutUseCase(authRepository)),
        Provider<GetCurrentUserUseCase>(create: (_) => GetCurrentUserUseCase(authRepository)),
        Provider<UpdateUserRoleUseCase>(create: (_) => UpdateUserRoleUseCase(authRepository)),
        Provider<GetFarmerProfileUseCase>(create: (_) => GetFarmerProfileUseCase(profileRepository)),
        Provider<GetBuyerProfileUseCase>(create: (_) => GetBuyerProfileUseCase(profileRepository)),
        ChangeNotifierProvider<AuthViewModel>(
          create: (context) => AuthViewModel(
            signInUseCase: context.read<SignInUseCase>(),
            signUpUseCase: context.read<SignUpUseCase>(),
            signOutUseCase: context.read<SignOutUseCase>(),
            getCurrentUserUseCase: context.read<GetCurrentUserUseCase>(),
            updateUserRoleUseCase: context.read<UpdateUserRoleUseCase>(),
            getFarmerProfileUseCase: context.read<GetFarmerProfileUseCase>(),
            getBuyerProfileUseCase: context.read<GetBuyerProfileUseCase>(),
          ),
        ),

        // Farmer UseCases & ViewModel
        Provider<CreateFarmerProfileUseCase>(create: (_) => CreateFarmerProfileUseCase(profileRepository)),
        Provider<GetFarmerProductsUseCase>(create: (_) => GetFarmerProductsUseCase(productRepository)),
        Provider<CreateProductUseCase>(create: (_) => CreateProductUseCase(productRepository)),
        Provider<DeleteProductUseCase>(create: (_) => DeleteProductUseCase(productRepository)),
        Provider<GetFarmerOrdersUseCase>(create: (_) => GetFarmerOrdersUseCase(orderRepository)),
        Provider<UpdateOrderStatusUseCase>(create: (_) => UpdateOrderStatusUseCase(orderRepository)),
        ChangeNotifierProvider<FarmerViewModel>(
          create: (context) => FarmerViewModel(
            createFarmerProfileUseCase: context.read<CreateFarmerProfileUseCase>(),
            getFarmerProductsUseCase: context.read<GetFarmerProductsUseCase>(),
            createProductUseCase: context.read<CreateProductUseCase>(),
            deleteProductUseCase: context.read<DeleteProductUseCase>(),
            getFarmerOrdersUseCase: context.read<GetFarmerOrdersUseCase>(),
            updateOrderStatusUseCase: context.read<UpdateOrderStatusUseCase>(),
          ),
        ),

        // Buyer UseCases & ViewModel
        Provider<CreateBuyerProfileUseCase>(create: (_) => CreateBuyerProfileUseCase(profileRepository)),
        Provider<GetAllProductsUseCase>(create: (_) => GetAllProductsUseCase(productRepository)),
        Provider<SearchProductsUseCase>(create: (_) => SearchProductsUseCase(productRepository)),
        Provider<GetProductsByCategoryUseCase>(create: (_) => GetProductsByCategoryUseCase(productRepository)),
        Provider<CreateOrderUseCase>(create: (_) => CreateOrderUseCase(orderRepository)),
        Provider<GetBuyerOrdersUseCase>(create: (_) => GetBuyerOrdersUseCase(orderRepository)),
        ChangeNotifierProvider<BuyerViewModel>(
          create: (context) => BuyerViewModel(
            createBuyerProfileUseCase: context.read<CreateBuyerProfileUseCase>(),
            getAllProductsUseCase: context.read<GetAllProductsUseCase>(),
            searchProductsUseCase: context.read<SearchProductsUseCase>(),
            getProductsByCategoryUseCase: context.read<GetProductsByCategoryUseCase>(),
            createOrderUseCase: context.read<CreateOrderUseCase>(),
            getBuyerOrdersUseCase: context.read<GetBuyerOrdersUseCase>(),
          ),
        ),

        // Market Rates UseCases & ViewModel
        Provider<GetMarketRatesUseCase>(create: (_) => GetMarketRatesUseCase(marketRateRepository)),
        Provider<GetTrendingCropsUseCase>(create: (_) => GetTrendingCropsUseCase(marketRateRepository)),
        ChangeNotifierProvider<MarketRateViewModel>(
          create: (context) => MarketRateViewModel(
            getMarketRatesUseCase: context.read<GetMarketRatesUseCase>(),
            getTrendingCropsUseCase: context.read<GetTrendingCropsUseCase>(),
          ),
        ),
      ],
      child: const FarmDirectApp(),
    ),
  );
}

class FarmDirectApp extends StatelessWidget {
  const FarmDirectApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Farm Direct',
      debugShowCheckedModeBanner: false,
      themeMode: ThemeMode.system, // Supports automatic light/dark mode
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      initialRoute: AppConstants.routeSplash,
      routes: {
        AppConstants.routeSplash: (context) => const SplashView(),
        AppConstants.routeLogin: (context) => const LoginView(),
        AppConstants.routeSignup: (context) => const SignupView(),
        AppConstants.routeSelectRole: (context) => const SelectRoleView(),
        AppConstants.routeFarmerProfileSetup: (context) => const CreateFarmerProfileView(),
        AppConstants.routeBuyerProfileSetup: (context) => const CreateBuyerProfileView(),
        AppConstants.routeFarmerDashboard: (context) => const FarmerDashboardView(),
        AppConstants.routeBuyerDashboard: (context) => const BuyerDashboardView(),
        AppConstants.routeProductDetails: (context) => const ProductDetailsView(),
      },
    );
  }
}
