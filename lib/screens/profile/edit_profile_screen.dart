import 'package:flutter/material.dart';
import 'package:grocery_app/providers/auth_provider.dart';
import 'package:grocery_app/screens/profile/change_password_screen.dart';
import 'package:grocery_app/utils/app_theme.dart';
import 'package:grocery_app/widgets/custom_button.dart';
import 'package:grocery_app/widgets/custom_text_field.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({Key? key}) : super(key: key);

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  File? _imageFile;
  String? _currentProfileImage;
  bool _isUploading = false;

  @override
  void initState() {
    super.initState();
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    _nameController = TextEditingController(
      text: authProvider.currentUser?.name ?? '',
    );
    _currentProfileImage = authProvider.currentUser?.profileImage;
  }

  @override
  void dispose() {
    _nameController.dispose();
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
    if (_imageFile == null) return _currentProfileImage;

    setState(() {
      _isUploading = true;
    });

    try {
      final directory = await getApplicationDocumentsDirectory();
      final fileName =
          'profile_${DateTime.now().millisecondsSinceEpoch}${path.extension(_imageFile!.path)}';
      final savedImage = await _imageFile!.copy('${directory.path}/$fileName');

      setState(() {
        _isUploading = false;
      });

      return savedImage.path;
    } catch (e) {
      debugPrint('Error saving image: $e');
      setState(() {
        _isUploading = false;
      });
      return null;
    }
  }

  Future<void> _saveProfile() async {
    if (_formKey.currentState!.validate()) {
      final imagePath = await _saveImage();
      final authProvider = Provider.of<AuthProvider>(context, listen: false);

      final success = await authProvider.updateProfile(
        _nameController.text.trim(),
        imagePath,
      );

      if (success && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Profile updated successfully'),
            backgroundColor: AppTheme.primaryColor,
          ),
        );
        Navigator.of(context).pop();
      } else if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Failed to update profile'),
            backgroundColor: AppTheme.errorColor,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Edit Profile')),
      body: Consumer<AuthProvider>(
        builder: (context, authProvider, _) {
          return SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const SizedBox(height: 20),
                  GestureDetector(
                    onTap: _pickImage,
                    child: Stack(
                      children: [
                        CircleAvatar(
                          radius: 60,
                          backgroundColor: AppTheme.primaryColor.withOpacity(
                            0.2,
                          ),
                          backgroundImage:
                              _imageFile != null
                                  ? FileImage(_imageFile!)
                                  : (_currentProfileImage != null
                                      ? FileImage(File(_currentProfileImage!))
                                      : null),
                          child:
                              _imageFile == null && _currentProfileImage == null
                                  ? Text(
                                    _nameController.text.isNotEmpty
                                        ? _nameController.text[0].toUpperCase()
                                        : 'U',
                                    style: Theme.of(
                                      context,
                                    ).textTheme.displayMedium?.copyWith(
                                      color: AppTheme.primaryColor,
                                    ),
                                  )
                                  : null,
                        ),
                        Positioned(
                          bottom: 0,
                          right: 0,
                          child: Container(
                            padding: const EdgeInsets.all(4),
                            decoration: BoxDecoration(
                              color: AppTheme.primaryColor,
                              shape: BoxShape.circle,
                              border: Border.all(color: Colors.white, width: 2),
                            ),
                            child: const Icon(
                              Icons.camera_alt,
                              color: Colors.white,
                              size: 20,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 30),
                  CustomTextField(
                    controller: _nameController,
                    hintText: 'Full Name',
                    prefixIcon: Icons.person_outline,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter your name';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  CustomTextField(
                    controller: TextEditingController(
                      text: authProvider.currentUser?.email ?? '',
                    ),
                    hintText: 'Email',
                    prefixIcon: Icons.email_outlined,
                    readOnly: true,
                  ),
                  const SizedBox(height: 30),
                  CustomButton(
                    text: 'Save Changes',
                    isLoading: authProvider.isLoading || _isUploading,
                    onPressed: _saveProfile,
                  ),
                  const SizedBox(height: 16),
                  CustomButton(
                    text: 'Change Password',
                    backgroundColor: Colors.white,
                    textColor: AppTheme.primaryColor,
                    borderColor: AppTheme.primaryColor,
                    onPressed: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) => const ChangePasswordScreen(),
                        ),
                      );
                    },
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
