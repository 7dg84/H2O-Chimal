import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/config.dart';
import '../../providers/auth_provider.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  
  // Controllers
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _curpController = TextEditingController();
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _postalCodeController = TextEditingController();
  final _coloniaController = TextEditingController();
  final _streetController = TextEditingController();
  final _blockController = TextEditingController();
  final _exteriorNumberController = TextEditingController();

  void _handleRegister() async {
    if (_formKey.currentState!.validate()) {
      final success = await context.read<AuthProvider>().register(
        email: _emailController.text,
        password: _passwordController.text,
        curp: _curpController.text.toUpperCase(),
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
            const SnackBar(content: Text('Cuenta creada exitosamente')),
          );
          Navigator.pop(context);
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Error al crear la cuenta. Verifique los datos.')),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Crear Cuenta'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildSectionTitle('Datos de Acceso'),
              const SizedBox(height: 16),
              _buildTextField('Correo electrónico', _emailController, Icons.email_outlined, 
                keyboardType: TextInputType.emailAddress,
                validator: (v) {
                  if (v == null || v.isEmpty) return 'Campo requerido';
                  final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
                  if (!emailRegex.hasMatch(v)) return 'Email inválido';
                  return null;
                }),
              const SizedBox(height: 16),
              _buildTextField('Contraseña', _passwordController, Icons.lock_outline, 
                obscureText: true, helperText: 'Mínimo 8 caracteres',
                validator: (v) => (v == null || v.length < 8) ? 'Mínimo 8 caracteres' : null),
              
              const SizedBox(height: 32),
              _buildSectionTitle('Datos Personales'),
              const SizedBox(height: 16),
              _buildTextField('Nombre completo', _nameController, Icons.person_outline),
              const SizedBox(height: 16),
              _buildTextField('CURP', _curpController, Icons.badge_outlined, 
                helperText: '18 caracteres alfanuméricos',
                validator: (v) {
                  if (v == null || v.isEmpty) return 'Campo requerido';
                  final curpRegex = RegExp(r'^[A-Z]{4}\d{6}[HM][A-Z]{5}[0-9A-Z]\d$');
                  if (!curpRegex.hasMatch(v.toUpperCase())) return 'Formato de CURP inválido';
                  return null;
                }),
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
                  Expanded(child: _buildTextField('Manzana (Opcional)', _blockController, null, validator: (v) => null)),
                  const SizedBox(width: 16),
                  Expanded(child: _buildTextField('Número exterior', _exteriorNumberController, null)),
                ],
              ),
              
              const SizedBox(height: 40),
              Consumer<AuthProvider>(
                builder: (context, auth, _) {
                  return ElevatedButton(
                    onPressed: auth.isLoading ? null : _handleRegister,
                    child: auth.isLoading
                        ? const CircularProgressIndicator(color: Colors.white)
                        : const Text('Guardar Registro'),
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
          textCapitalization: label == 'CURP' ? TextCapitalization.characters : TextCapitalization.none,
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
