import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/config.dart';
import '../../providers/auth_provider.dart';
import '../../models/user_model.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  
  // Controllers
  late TextEditingController _nameController;
  late TextEditingController _phoneController;
  late TextEditingController _postalCodeController;
  late TextEditingController _coloniaController;
  late TextEditingController _streetController;
  late TextEditingController _blockController;
  late TextEditingController _exteriorNumberController;

  @override
  void initState() {
    super.initState();
    final user = context.read<AuthProvider>().user;
    
    _nameController = TextEditingController(text: user?.name ?? '');
    _phoneController = TextEditingController(text: user?.phone ?? '');
    _postalCodeController = TextEditingController(text: user?.postalCode ?? '');
    _coloniaController = TextEditingController(text: user?.colonia ?? '');
    _streetController = TextEditingController(text: user?.street ?? '');
    _blockController = TextEditingController(text: user?.block ?? '');
    _exteriorNumberController = TextEditingController(text: user?.exteriorNumber ?? '');
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _postalCodeController.dispose();
    _coloniaController.dispose();
    _streetController.dispose();
    _blockController.dispose();
    _exteriorNumberController.dispose();
    super.dispose();
  }

  void _handleUpdate() async {
    if (_formKey.currentState!.validate()) {
      final success = await context.read<AuthProvider>().updateProfile(
        name: _nameController.text,
        phone: _phoneController.text,
        postalCode: _postalCodeController.text,
        colonia: _coloniaController.text,
        street: _streetController.text,
        block: _blockController.text,
        exteriorNumber: _exteriorNumberController.text,
      );

      if (success) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Perfil actualizado exitosamente')),
          );
          Navigator.pop(context);
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Error al actualizar el perfil.')),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = context.watch<AuthProvider>().user;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Editar Perfil'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildSectionTitle('Información Personal'),
              const SizedBox(height: 8),
              Text(
                'CURP: ${user?.curp ?? "No disponible"}',
                style: const TextStyle(color: Colors.grey, fontSize: 13),
              ),
              const SizedBox(height: 16),
              _buildTextField('Nombre completo', _nameController, Icons.person_outline),
              const SizedBox(height: 16),
              _buildTextField('Número telefónico', _phoneController, Icons.phone_android_outlined, 
                keyboardType: TextInputType.phone,
                validator: (v) {
                  if (v == null || v.isEmpty) return 'Campo requerido';
                  if (v.length != 10 || !RegExp(r'^[0-9]+$').hasMatch(v)) return '10 dígitos requeridos';
                  return null;
                }),
              
              const SizedBox(height: 32),
              _buildSectionTitle('Domicilio'),
              const SizedBox(height: 16),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: _buildTextField('Código postal', _postalCodeController, null, 
                      keyboardType: TextInputType.number,
                      validator: (v) {
                        if (v == null || v.isEmpty) return 'Requerido';
                        if (v.length != 5 || !RegExp(r'^[0-9]+$').hasMatch(v)) return '5 dígitos';
                        return null;
                      }),
                  ),
                  const SizedBox(width: 16),
                  Expanded(child: _buildTextField('Colonia', _coloniaController, null)),
                ],
              ),
              const SizedBox(height: 16),
              _buildTextField('Calle', _streetController, null),
              const SizedBox(height: 16),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(child: _buildTextField('Manzana', _blockController, null)),
                  const SizedBox(width: 16),
                  Expanded(child: _buildTextField('Número exterior', _exteriorNumberController, null)),
                ],
              ),
              
              const SizedBox(height: 40),
              Consumer<AuthProvider>(
                builder: (context, auth, _) {
                  return Column(
                    children: [
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: auth.isLoading ? null : _handleUpdate,
                          child: auth.isLoading
                              ? const SizedBox(
                                  height: 20, 
                                  width: 20, 
                                  child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2)
                                )
                              : const Text('Guardar Cambios'),
                        ),
                      ),
                      const SizedBox(height: 12),
                      SizedBox(
                        width: double.infinity,
                        child: OutlinedButton(
                          onPressed: () => Navigator.pop(context),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: Colors.grey[700],
                            side: BorderSide(color: Colors.grey[400]!),
                          ),
                          child: const Text('Cancelar'),
                        ),
                      ),
                    ],
                  );
                },
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.bold,
        color: AppConfig.primaryBlue,
      ),
    );
  }

  Widget _buildTextField(
    String label, 
    TextEditingController controller, 
    IconData? icon, {
    bool obscureText = false,
    String? helperText,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          obscureText: obscureText,
          keyboardType: keyboardType,
          decoration: InputDecoration(
            prefixIcon: icon != null ? Icon(icon, size: 20) : null,
            hintText: label,
            helperText: helperText,
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          ),
          validator: validator ?? (value) => (value == null || value.isEmpty) ? 'Campo requerido' : null,
        ),
      ],
    );
  }
}
