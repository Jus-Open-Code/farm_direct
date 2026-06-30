import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import 'package:farm_direct/core/constants/app_constants.dart';
import 'package:farm_direct/presentation/viewmodels/auth_viewmodel.dart';
import 'package:farm_direct/presentation/viewmodels/buyer_viewmodel.dart';
import 'package:farm_direct/presentation/widgets/common_button.dart';
import 'package:farm_direct/presentation/widgets/common_textfield.dart';

class CreateBuyerProfileView extends StatefulWidget {
  const CreateBuyerProfileView({super.key});

  @override
  State<CreateBuyerProfileView> createState() => _CreateBuyerProfileViewState();
}

class _CreateBuyerProfileViewState extends State<CreateBuyerProfileView> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _addressController = TextEditingController();
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
    if (!_formKey.currentState!.validate()) return;

    final authViewModel = Provider.of<AuthViewModel>(context, listen: false);
    final buyerViewModel = Provider.of<BuyerViewModel>(context, listen: false);

    final success = await buyerViewModel.createProfile(
      id: authViewModel.user!.id,
      name: _nameController.text.trim(),
      phone: _phoneController.text.trim(),
      address: _addressController.text.trim(),
      imageFile: _imageFile,
    );

    if (success && mounted) {
      await authViewModel.reloadBuyerProfile();
      if (!mounted) return;
      Navigator.pushReplacementNamed(context, AppConstants.routeBuyerDashboard);
    } else if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(buyerViewModel.errorMessage ?? 'Failed to save profile.'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final size = MediaQuery.of(context).size;
    final isWeb = size.width > 600;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Buyer Profile Setup'),
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
                  // Photo selector
                  Center(
                    child: GestureDetector(
                      onTap: _pickImage,
                      child: Stack(
                        children: [
                          CircleAvatar(
                            radius: 50,
                            backgroundColor: Colors.orange[50],
                            backgroundImage: _imageFile != null ? NetworkImage(_imageFile!.path) : null,
                            child: _imageFile == null
                                ? Icon(Icons.camera_alt, size: 40, color: Colors.orange[700])
                                : null,
                          ),
                          Positioned(
                            bottom: 0,
                            right: 0,
                            child: CircleAvatar(
                              radius: 16,
                              backgroundColor: Colors.orange[700],
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

                  // Address
                  CommonTextField(
                    controller: _addressController,
                    labelText: 'Delivery Address',
                    prefixIcon: Icons.location_on_outlined,
                    maxLines: 3,
                    validator: (val) => val == null || val.isEmpty ? 'Please enter address' : null,
                  ),
                  const SizedBox(height: 32),

                  // Submit
                  Consumer<BuyerViewModel>(
                    builder: (context, vm, child) {
                      return CommonButton(
                        text: 'Complete Setup',
                        isLoading: vm.isLoading,
                        backgroundColor: Colors.orange[700],
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
