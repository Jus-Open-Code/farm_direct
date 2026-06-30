import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import 'package:farm_direct/core/constants/app_constants.dart';
import 'package:farm_direct/presentation/viewmodels/auth_viewmodel.dart';
import 'package:farm_direct/presentation/viewmodels/farmer_viewmodel.dart';
import 'package:farm_direct/presentation/widgets/common_button.dart';
import 'package:farm_direct/presentation/widgets/common_textfield.dart';

class CreateFarmerProfileView extends StatefulWidget {
  const CreateFarmerProfileView({super.key});

  @override
  State<CreateFarmerProfileView> createState() => _CreateFarmerProfileViewState();
}

class _CreateFarmerProfileViewState extends State<CreateFarmerProfileView> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _villageController = TextEditingController();
  final _pincodeController = TextEditingController();
  final _farmSizeController = TextEditingController();
  final _cropsController = TextEditingController();

  String? _selectedState;
  String? _selectedDistrict;
  List<String> _districts = [];
  XFile? _imageFile;

  Future<void> _pickImage() async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 70,
    );
    if (image != null) {
      setState(() {
        _imageFile = image;
      });
    }
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate() || _selectedState == null || _selectedDistrict == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill all fields and select State/District')),
      );
      return;
    }

    final authViewModel = Provider.of<AuthViewModel>(context, listen: false);
    final farmerViewModel = Provider.of<FarmerViewModel>(context, listen: false);

    final success = await farmerViewModel.createProfile(
      id: authViewModel.user!.id,
      name: _nameController.text.trim(),
      phone: _phoneController.text.trim(),
      village: _villageController.text.trim(),
      district: _selectedDistrict!,
      state: _selectedState!,
      pincode: _pincodeController.text.trim(),
      farmSize: double.parse(_farmSizeController.text.trim()),
      products: _cropsController.text.split(',').map((e) => e.trim()).where((e) => e.isNotEmpty).toList(),
      imageFile: _imageFile,
    );

    if (success && mounted) {
      await authViewModel.reloadFarmerProfile();
      if (!mounted) return;
      Navigator.pushReplacementNamed(context, AppConstants.routeFarmerDashboard);
    } else if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(farmerViewModel.errorMessage ?? 'Failed to save profile.'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _villageController.dispose();
    _pincodeController.dispose();
    _farmSizeController.dispose();
    _cropsController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final size = MediaQuery.of(context).size;
    final isWeb = size.width > 600;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Farmer Profile Setup'),
        automaticallyImplyLeading: false,
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Container(
            width: isWeb ? 550 : double.infinity,
            padding: isWeb ? const EdgeInsets.all(32) : EdgeInsets.zero,
            decoration: isWeb
                ? BoxDecoration(
                    color: theme.cardTheme.color,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 16,
                        offset: const Offset(0, 4),
                      )
                    ],
                  )
                : null,
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Photo selection
                  Center(
                    child: GestureDetector(
                      onTap: _pickImage,
                      child: Stack(
                        children: [
                          CircleAvatar(
                            radius: 50,
                            backgroundColor: Colors.green[100],
                            backgroundImage: _imageFile != null ? NetworkImage(_imageFile!.path) : null,
                            child: _imageFile == null
                                ? const Icon(Icons.camera_alt, size: 40, color: Colors.green)
                                : null,
                          ),
                          Positioned(
                            bottom: 0,
                            right: 0,
                            child: CircleAvatar(
                              radius: 16,
                              backgroundColor: theme.colorScheme.primary,
                              child: const Icon(Icons.edit, size: 16, color: Colors.white),
                            ),
                          )
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Name
                  CommonTextField(
                    controller: _nameController,
                    labelText: 'Full Name',
                    prefixIcon: Icons.person_outline,
                    validator: (val) => val == null || val.isEmpty ? 'Please enter name' : null,
                  ),
                  const SizedBox(height: 16),

                  // Phone
                  CommonTextField(
                    controller: _phoneController,
                    labelText: 'Phone Number',
                    prefixIcon: Icons.phone_outlined,
                    keyboardType: TextInputType.phone,
                    validator: (val) => val == null || val.isEmpty ? 'Please enter phone' : null,
                  ),
                  const SizedBox(height: 16),

                  // State Selector
                  DropdownButtonFormField<String>(
                    value: _selectedState,
                    decoration: const InputDecoration(
                      labelText: 'State',
                      prefixIcon: Icon(Icons.map_outlined),
                    ),
                    items: AppConstants.indianStates.map((state) {
                      return DropdownMenuItem(value: state, child: Text(state));
                    }).toList(),
                    onChanged: (val) {
                      setState(() {
                        _selectedState = val;
                        _selectedDistrict = null;
                        _districts = AppConstants.stateDistricts[val!] ?? [];
                      });
                    },
                    validator: (val) => val == null ? 'Please select state' : null,
                  ),
                  const SizedBox(height: 16),

                  // District Selector
                  DropdownButtonFormField<String>(
                    value: _selectedDistrict,
                    decoration: const InputDecoration(
                      labelText: 'District',
                      prefixIcon: Icon(Icons.location_city_outlined),
                    ),
                    items: _districts.map((district) {
                      return DropdownMenuItem(value: district, child: Text(district));
                    }).toList(),
                    onChanged: (val) {
                      setState(() {
                        _selectedDistrict = val;
                      });
                    },
                    validator: (val) => val == null ? 'Please select district' : null,
                  ),
                  const SizedBox(height: 16),

                  // Village
                  CommonTextField(
                    controller: _villageController,
                    labelText: 'Village',
                    prefixIcon: Icons.home_outlined,
                    validator: (val) => val == null || val.isEmpty ? 'Please enter village name' : null,
                  ),
                  const SizedBox(height: 16),

                  // Pincode
                  CommonTextField(
                    controller: _pincodeController,
                    labelText: 'Pincode',
                    prefixIcon: Icons.pin_outlined,
                    keyboardType: TextInputType.number,
                    validator: (val) => val == null || val.isEmpty ? 'Please enter pincode' : null,
                  ),
                  const SizedBox(height: 16),

                  // Farm Size
                  CommonTextField(
                    controller: _farmSizeController,
                    labelText: 'Farm Size (in Acres)',
                    prefixIcon: Icons.landscape_outlined,
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    validator: (val) {
                      if (val == null || val.isEmpty) return 'Please enter farm size';
                      if (double.tryParse(val) == null) return 'Please enter a valid number';
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),

                  // Crops grown
                  CommonTextField(
                    controller: _cropsController,
                    labelText: 'Crops Grown (Comma separated)',
                    hintText: 'e.g. Tomato, Rice, Wheat',
                    prefixIcon: Icons.eco_outlined,
                    validator: (val) => val == null || val.isEmpty ? 'Please list some crops' : null,
                  ),
                  const SizedBox(height: 32),

                  // Submit Button
                  Consumer<FarmerViewModel>(
                    builder: (context, vm, child) {
                      return CommonButton(
                        text: 'Complete Setup',
                        isLoading: vm.isLoading,
                        onPressed: _submit,
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
