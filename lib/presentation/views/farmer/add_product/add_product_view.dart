import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:farm_direct/core/constants/app_constants.dart';
import 'package:farm_direct/presentation/viewmodels/auth_viewmodel.dart';
import 'package:farm_direct/presentation/viewmodels/farmer_viewmodel.dart';
import 'package:farm_direct/presentation/widgets/common_button.dart';
import 'package:farm_direct/presentation/widgets/common_textfield.dart';

class AddProductView extends StatefulWidget {
  const AddProductView({super.key});

  @override
  State<AddProductView> createState() => _AddProductViewState();
}

class _AddProductViewState extends State<AddProductView> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _priceController = TextEditingController();
  final _quantityController = TextEditingController();
  final _descriptionController = TextEditingController();

  String? _selectedCategory;
  String? _selectedUnit;
  DateTime? _selectedDate;
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

  Future<void> _selectDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now().subtract(const Duration(days: 30)),
      lastDate: DateTime.now().add(const Duration(days: 90)),
    );
    if (picked != null) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate() ||
        _selectedCategory == null ||
        _selectedUnit == null ||
        _selectedDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please complete the form and select harvest date.')),
      );
      return;
    }

    final authViewModel = Provider.of<AuthViewModel>(context, listen: false);
    final farmerViewModel = Provider.of<FarmerViewModel>(context, listen: false);

    final success = await farmerViewModel.addProduct(
      farmerId: authViewModel.user!.id,
      name: _nameController.text.trim(),
      category: _selectedCategory!,
      quantity: double.parse(_quantityController.text.trim()),
      unit: _selectedUnit!,
      price: double.parse(_priceController.text.trim()),
      description: _descriptionController.text.trim(),
      harvestDate: _selectedDate!,
      imageFile: _imageFile,
    );

    if (success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Product added successfully!'), backgroundColor: Colors.green),
      );
      // Reset form
      _nameController.clear();
      _priceController.clear();
      _quantityController.clear();
      _descriptionController.clear();
      setState(() {
        _selectedCategory = null;
        _selectedUnit = null;
        _selectedDate = null;
        _imageFile = null;
      });
    } else if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(farmerViewModel.errorMessage ?? 'Failed to list product.'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _priceController.dispose();
    _quantityController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'List New Harvest',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),

              // Image Box
              GestureDetector(
                onTap: _pickImage,
                child: Container(
                  height: 180,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: theme.brightness == Brightness.dark ? const Color(0xFF2C2C2C) : Colors.grey[100],
                    border: Border.all(color: Colors.grey[300]!, style: BorderStyle.none),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: _imageFile == null
                      ? const Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.add_photo_alternate_outlined, size: 48, color: Colors.grey),
                            SizedBox(height: 8),
                            Text('Upload Crop Photo', style: TextStyle(color: Colors.grey)),
                          ],
                        )
                      : ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: Image.network(
                            _imageFile!.path,
                            fit: BoxFit.cover,
                            width: double.infinity,
                          ),
                        ),
                ),
              ),
              const SizedBox(height: 20),

              // Product Name
              CommonTextField(
                controller: _nameController,
                labelText: 'Crop / Product Name',
                prefixIcon: Icons.eco_outlined,
                validator: (val) => val == null || val.isEmpty ? 'Please enter crop name' : null,
              ),
              const SizedBox(height: 16),

              // Category
              DropdownButtonFormField<String>(
                value: _selectedCategory,
                decoration: const InputDecoration(
                  labelText: 'Category',
                  prefixIcon: Icon(Icons.category_outlined),
                ),
                items: AppConstants.productCategories.map((cat) {
                  return DropdownMenuItem(value: cat, child: Text(cat));
                }).toList(),
                onChanged: (val) => setState(() => _selectedCategory = val),
                validator: (val) => val == null ? 'Please select category' : null,
              ),
              const SizedBox(height: 16),

              // Price & Qty side by side
              Row(
                children: [
                  Expanded(
                    child: CommonTextField(
                      controller: _priceController,
                      labelText: 'Price (₹)',
                      prefixIcon: Icons.currency_rupee,
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      validator: (val) {
                        if (val == null || val.isEmpty) return 'Enter price';
                        if (double.tryParse(val) == null) return 'Invalid number';
                        return null;
                      },
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: CommonTextField(
                      controller: _quantityController,
                      labelText: 'Quantity',
                      prefixIcon: Icons.scale_outlined,
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      validator: (val) {
                        if (val == null || val.isEmpty) return 'Enter quantity';
                        if (double.tryParse(val) == null) return 'Invalid number';
                        return null;
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Unit
              DropdownButtonFormField<String>(
                value: _selectedUnit,
                decoration: const InputDecoration(
                  labelText: 'Unit',
                  prefixIcon: Icon(Icons.line_weight_outlined),
                ),
                items: AppConstants.productUnits.map((u) {
                  return DropdownMenuItem(value: u, child: Text(u));
                }).toList(),
                onChanged: (val) => setState(() => _selectedUnit = val),
                validator: (val) => val == null ? 'Please select unit' : null,
              ),
              const SizedBox(height: 16),

              // Harvest Date Picker
              InkWell(
                onTap: _selectDate,
                borderRadius: BorderRadius.circular(12),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey[300]!),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.calendar_month_outlined, color: Colors.grey),
                          const SizedBox(width: 12),
                          Text(
                            _selectedDate == null
                                ? 'Select Harvest Date'
                                : 'Harvest Date: ${DateFormat('yyyy-MM-dd').format(_selectedDate!)}',
                            style: TextStyle(
                              color: _selectedDate == null ? Colors.grey[600] : Colors.black87,
                            ),
                          ),
                        ],
                      ),
                      const Icon(Icons.arrow_drop_down, color: Colors.grey),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Description
              CommonTextField(
                controller: _descriptionController,
                labelText: 'Crop Description',
                prefixIcon: Icons.description_outlined,
                maxLines: 3,
              ),
              const SizedBox(height: 28),

              // Submit Button
              Consumer<FarmerViewModel>(
                builder: (context, vm, child) {
                  return CommonButton(
                    text: 'List Product',
                    isLoading: vm.isLoading,
                    onPressed: _submit,
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
