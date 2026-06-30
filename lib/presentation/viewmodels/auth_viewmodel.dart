import 'package:flutter/material.dart';
import '../../domain/entities/user_entity.dart';
import '../../domain/entities/farmer_profile_entity.dart';
import '../../domain/entities/buyer_profile_entity.dart';
import '../../domain/usecases/auth_usecases.dart';
import '../../domain/usecases/profile_usecases.dart';

class AuthViewModel extends ChangeNotifier {
  final SignInUseCase _signInUseCase;
  final SignUpUseCase _signUpUseCase;
  final SignOutUseCase _signOutUseCase;
  final GetCurrentUserUseCase _getCurrentUserUseCase;
  final UpdateUserRoleUseCase _updateUserRoleUseCase;
  final GetFarmerProfileUseCase _getFarmerProfileUseCase;
  final GetBuyerProfileUseCase _getBuyerProfileUseCase;

  AuthViewModel({
    required SignInUseCase signInUseCase,
    required SignUpUseCase signUpUseCase,
    required SignOutUseCase signOutUseCase,
    required GetCurrentUserUseCase getCurrentUserUseCase,
    required UpdateUserRoleUseCase updateUserRoleUseCase,
    required GetFarmerProfileUseCase getFarmerProfileUseCase,
    required GetBuyerProfileUseCase getBuyerProfileUseCase,
  })  : _signInUseCase = signInUseCase,
        _signUpUseCase = signUpUseCase,
        _signOutUseCase = signOutUseCase,
        _getCurrentUserUseCase = getCurrentUserUseCase,
        _updateUserRoleUseCase = updateUserRoleUseCase,
        _getFarmerProfileUseCase = getFarmerProfileUseCase,
        _getBuyerProfileUseCase = getBuyerProfileUseCase;

  UserEntity? _user;
  FarmerProfileEntity? _farmerProfile;
  BuyerProfileEntity? _buyerProfile;
  bool _isLoading = false;
  String? _errorMessage;

  UserEntity? get user => _user;
  FarmerProfileEntity? get farmerProfile => _farmerProfile;
  BuyerProfileEntity? get buyerProfile => _buyerProfile;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  void _setError(String? message) {
    _errorMessage = message;
    notifyListeners();
  }

  // Check current session on app start
  Future<String?> checkSession() async {
    _setLoading(true);
    _setError(null);
    try {
      _user = await _getCurrentUserUseCase();
      if (_user != null) {
        // Load respective profiles
        if (_user!.role == 'farmer') {
          _farmerProfile = await _getFarmerProfileUseCase(_user!.id);
          _setLoading(false);
          return _farmerProfile != null ? 'farmer_dashboard' : 'farmer_profile_setup';
        } else if (_user!.role == 'buyer') {
          _buyerProfile = await _getBuyerProfileUseCase(_user!.id);
          _setLoading(false);
          return _buyerProfile != null ? 'buyer_dashboard' : 'buyer_profile_setup';
        } else {
          _setLoading(false);
          return 'select_role';
        }
      }
      _setLoading(false);
      return 'login';
    } catch (e) {
      _setError(e.toString());
      _setLoading(false);
      return 'login';
    }
  }

  // Sign In
  Future<bool> signIn(String email, String password) async {
    _setLoading(true);
    _setError(null);
    try {
      _user = await _signInUseCase(email, password);
      if (_user != null) {
        if (_user!.role == 'farmer') {
          _farmerProfile = await _getFarmerProfileUseCase(_user!.id);
        } else if (_user!.role == 'buyer') {
          _buyerProfile = await _getBuyerProfileUseCase(_user!.id);
        }
        _setLoading(false);
        return true;
      }
      _setLoading(false);
      return false;
    } catch (e) {
      _setError(e.toString());
      _setLoading(false);
      return false;
    }
  }

  // Sign Up
  Future<bool> signUp(String email, String password) async {
    _setLoading(true);
    _setError(null);
    try {
      _user = await _signUpUseCase(email, password);
      _setLoading(false);
      return _user != null;
    } catch (e) {
      _setError(e.toString());
      _setLoading(false);
      return false;
    }
  }

  // Select User Type (Farmer / Buyer)
  Future<bool> selectRole(String role) async {
    if (_user == null) return false;
    _setLoading(true);
    _setError(null);
    try {
      await _updateUserRoleUseCase(_user!.id, role);
      // Re-fetch user model with updated role
      _user = await _getCurrentUserUseCase();
      _setLoading(false);
      return true;
    } catch (e) {
      _setError(e.toString());
      _setLoading(false);
      return false;
    }
  }

  // Load Farmer Profile
  Future<void> reloadFarmerProfile() async {
    if (_user == null) return;
    _farmerProfile = await _getFarmerProfileUseCase(_user!.id);
    notifyListeners();
  }

  // Load Buyer Profile
  Future<void> reloadBuyerProfile() async {
    if (_user == null) return;
    _buyerProfile = await _getBuyerProfileUseCase(_user!.id);
    notifyListeners();
  }

  // Sign Out
  Future<void> signOut() async {
    _setLoading(true);
    try {
      await _signOutUseCase();
      _user = null;
      _farmerProfile = null;
      _buyerProfile = null;
      _setLoading(false);
    } catch (e) {
      _setError(e.toString());
      _setLoading(false);
    }
  }
}
