import 'package:flutter/material.dart';
import 'package:grocery_app/models/product_model.dart';
import 'package:grocery_app/providers/admin_provider.dart';
import 'package:grocery_app/providers/product_provider.dart';
import 'package:grocery_app/utils/app_theme.dart';
import 'package:grocery_app/widgets/custom_button.dart';
import 'package:grocery_app/widgets/custom_text_field.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;

class EditProductScreen extends StatefulWidget {
  final Product? product;

  const EditProductScreen({Key? key, this.product}) : super(key: key);

  @override
  State<EditProductScreen> createState() => _EditProductScreenState();
}

class _EditProductScreenState extends State<EditProductScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _priceController;
  late TextEditingController _descriptionController;
  String _selectedCategory = 'Fruits';
  File? _imageFile;
  String? _currentImagePath;
  bool _isUploading = false;
  double _rating = 0.0;

  final List<String> _categories = [
    'Fruits',
    'Vegetables',
    'Dairy',
    'Bakery',
    'Meat',
    'Beverages',
    'Snacks',
    'Frozen',
    'Canned',
    'Other',
  ];

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.product?.name ?? '');
    _priceController = TextEditingController(
      text:
          widget.product?.price != null ? widget.product!.price.toString() : '',
    );
    _descriptionController = TextEditingController(
      text: widget.product?.description ?? '',
    );
    _selectedCategory = widget.product?.category ?? 'Fruits';
    _currentImagePath = widget.product?.imagePath;
    _rating = widget.product?.rating ?? 0.0;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _priceController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      setState(() {
        _imageFile = File(pickedFile.path);
      });
    }
  }

  Future<String?> _saveImage() async {
    if (_imageFile == null) return _currentImagePath;

    setState(() {
      _isUploading = true;
    });

    try {
      final directory = await getApplicationDocumentsDirectory();
      final fileName =
          'product_${DateTime.now().millisecondsSinceEpoch}${path.extension(_imageFile!.path)}';
      final savedImage = await _imageFile!.copy('${directory.path}/$fileName');

      setState(() {
        _isUploading = false;
      });

      return 'assets/images/$fileName';
    } catch (e) {
      debugPrint('Error saving image: $e');
      setState(() {
        _isUploading = false;
      });
      return null;
    }
  }

  Future<void> _saveProduct() async {
    if (_formKey.currentState!.validate()) {
      final imagePath = await _saveImage() ?? 'assets/images/placeholder.png';
      final adminProvider = Provider.of<AdminProvider>(context, listen: false);

      final product = Product(
        id: widget.product?.id,
        name: _nameController.text.trim(),
        price: double.parse(_priceController.text.trim()),
        imagePath: imagePath,
        category: _selectedCategory,
        description: _descriptionController.text.trim(),
        rating: _rating,
        isFavorite: widget.product?.isFavorite ?? false,
      );

      bool success;
      if (widget.product == null) {
        // Add new product
        success = await adminProvider.addProduct(product);
      } else {
        // Update existing product
        success = await adminProvider.updateProduct(product);
      }

      if (success && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              widget.product == null
                  ? 'Product added successfully'
                  : 'Product updated successfully',
            ),
            backgroundColor: AppTheme.primaryColor,
          ),
        );
        // Refresh products list
        Provider.of<ProductProvider>(context, listen: false).loadProducts();
        Navigator.of(context).pop();
      } else if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              widget.product == null
                  ? 'Failed to add product'
                  : 'Failed to update product',
            ),
            backgroundColor: AppTheme.errorColor,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.product == null ? 'Add Product' : 'Edit Product'),
      ),
      body: Consumer<AdminProvider>(
        builder: (context, adminProvider, _) {
          return SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: GestureDetector(
                      onTap: _pickImage,
                      child: Container(
                        width: 150,
                        height: 150,
                        decoration: BoxDecoration(
                          color: AppTheme.primaryColor.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: AppTheme.primaryColor.withOpacity(0.3),
                            width: 1,
                          ),
                        ),
                        child:
                            _imageFile != null
                                ? ClipRRect(
                                  borderRadius: BorderRadius.circular(12),
                                  child: Image.file(
                                    _imageFile!,
                                    fit: BoxFit.cover,
                                  ),
                                )
                                : _currentImagePath != null
                                ? ClipRRect(
                                  borderRadius: BorderRadius.circular(12),
                                  child: Image.asset(
                                    _currentImagePath!,
                                    fit: BoxFit.cover,
                                  ),
                                )
                                : Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      Icons.add_a_photo,
                                      size: 40,
                                      color: AppTheme.primaryColor,
                                    ),
                                    const SizedBox(height: 8),
                                    Text(
                                      'Add Product Image',
                                      style: Theme.of(
                                        context,
                                      ).textTheme.bodySmall?.copyWith(
                                        color: AppTheme.primaryColor,
                                      ),
                                      textAlign: TextAlign.center,
                                    ),
                                  ],
                                ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  CustomTextField(
                    controller: _nameController,
                    hintText: 'Product Name',
                    prefixIcon: Icons.shopping_bag_outlined,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter product name';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  CustomTextField(
                    controller: _priceController,
                    hintText: 'Price',
                    prefixIcon: Icons.attach_money,
                    keyboardType: const TextInputType.numberWithOptions(
                      decimal: true,
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter price';
                      }
                      if (double.tryParse(value) == null) {
                        return 'Please enter a valid price';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  DropdownButtonFormField<String>(
                    value: _selectedCategory,
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: Colors.white,
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 16,
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                      prefixIcon: const Icon(
                        Icons.category_outlined,
                        color: AppTheme.subtitleColor,
                      ),
                    ),
                    items:
                        _categories.map((category) {
                          return DropdownMenuItem<String>(
                            value: category,
                            child: Text(category),
                          );
                        }).toList(),
                    onChanged: (value) {
                      if (value != null) {
                        setState(() {
                          _selectedCategory = value;
                        });
                      }
                    },
                  ),
                  const SizedBox(height: 16),
                  CustomTextField(
                    controller: _descriptionController,
                    hintText: 'Description',
                    prefixIcon: Icons.description_outlined,
                    maxLines: 3,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter description';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Rating: ${_rating.toStringAsFixed(1)}',
                    style: Theme.of(context).textTheme.bodyLarge,
                  ),
                  Slider(
                    value: _rating,
                    min: 0,
                    max: 5,
                    divisions: 10,
                    label: _rating.toStringAsFixed(1),
                    activeColor: AppTheme.primaryColor,
                    onChanged: (value) {
                      setState(() {
                        _rating = value;
                      });
                    },
                  ),
                  const SizedBox(height: 24),
                  CustomButton(
                    text:
                        widget.product == null
                            ? 'Add Product'
                            : 'Update Product',
                    isLoading: adminProvider.isLoading || _isUploading,
                    onPressed: _saveProduct,
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
