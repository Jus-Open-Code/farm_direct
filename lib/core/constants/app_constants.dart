class AppConstants {
  // Supabase Configuration Placeholders
  // Replace these with your actual Supabase project credentials
  static const String supabaseUrl = 'https://tjntuhyxrmwgvoymsdyk.supabase.co';
  static const String supabaseAnonKey = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InRqbnR1aHl4cm13Z3ZveW1zZHlrIiwicm9sZSI6ImFub24iLCJpYXQiOjE3ODI4MzM5MjIsImV4cCI6MjA5ODQwOTkyMn0.100jacMbOWFZKQdUhhYMjr3_TnvPa4GWD933-HPuguw';

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
