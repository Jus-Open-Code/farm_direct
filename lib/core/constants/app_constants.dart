class AppConstants {
  // Supabase Configuration Placeholders
  // Replace these with your actual Supabase project credentials
  static const String supabaseUrl = 'YOUR_SUPABASE_PROJECT_URL';
  static const String supabaseAnonKey = 'YOUR_SUPABASE_ANON_KEY';

  // Navigation Routes
  static const String routeSplash = '/';
  static const String routeLogin = '/login';
  static const String routeSignup = '/signup';
  static const String routeSelectRole = '/select-role';
  static const String routeFarmerProfileSetup = '/farmer-profile-setup';
  static const String routeBuyerProfileSetup = '/buyer-profile-setup';
  static const String routeFarmerDashboard = '/farmer-dashboard';
  static const String routeBuyerDashboard = '/buyer-dashboard';
  static const String routeProductDetails = '/product-details';

  // Product Categories
  static const List<String> productCategories = [
    'Vegetables',
    'Fruits',
    'Grains',
    'Pulses',
    'Organic',
    'Spices',
    'Other'
  ];

  // Units
  static const List<String> productUnits = [
    'kg',
    'quintal',
    'ton',
    'piece',
    'dozen',
    'litre'
  ];

  // States & Districts for Farmer Profile and Market Rates
  static const List<String> indianStates = [
    'Maharashtra',
    'Punjab',
    'Uttar Pradesh',
    'West Bengal',
    'Himachal Pradesh',
    'Karnataka',
    'Tamil Nadu',
    'Gujarat'
  ];

  static const Map<String, List<String>> stateDistricts = {
    'Maharashtra': ['Pune', 'Nashik', 'Mumbai', 'Nagpur', 'Aurangabad'],
    'Punjab': ['Ludhiana', 'Amritsar', 'Jalandhar', 'Patiala', 'Bathinda'],
    'Uttar Pradesh': ['Agra', 'Kanpur', 'Lucknow', 'Varanasi', 'Meerut'],
    'West Bengal': ['Bardhaman', 'Kolkata', 'Darjeeling', 'Howrah', 'Hooghly'],
    'Himachal Pradesh': ['Shimla', 'Manali', 'Dharamshala', 'Solan', 'Kangra'],
    'Karnataka': ['Bangalore', 'Mysore', 'Hubli', 'Mangalore', 'Belgaum'],
    'Tamil Nadu': ['Chennai', 'Coimbatore', 'Madurai', 'Trichy', 'Salem'],
    'Gujarat': ['Ahmedabad', 'Surat', 'Vadodara', 'Rajkot', 'Gandhinagar']
  };
}
