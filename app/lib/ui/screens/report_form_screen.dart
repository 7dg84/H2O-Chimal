import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import '../../core/config.dart';

class ReportFormScreen extends StatefulWidget {
  const ReportFormScreen({super.key});

  @override
  State<ReportFormScreen> createState() => _ReportFormScreenState();
}

class _ReportFormScreenState extends State<ReportFormScreen> {
  final _formKey = GlobalKey<FormState>();
  String? _selectedType;
  File? _image;
  final _descriptionController = TextEditingController();
  
  final List<Map<String, String>> _reportTypes = [
    {'label': 'Superficial', 'value': 'superficial'},
    {'label': 'Tubería', 'value': 'tuberia'},
    {'label': 'Toma dom.', 'value': 'domiciliaria'},
    {'label': 'Drenaje', 'value': 'obstruido'},
  ];

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.camera);
    if (pickedFile != null) {
      setState(() {
        _image = File(pickedFile.path);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Reportar Fuga'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildStepper(),
              const SizedBox(height: 32),
              
              _buildSectionTitle('Ubicación de la fuga'),
              const SizedBox(height: 16),
              Container(
                height: 150,
                width: double.infinity,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  color: Colors.grey[200],
                ),
                child: Center(
                  child: ElevatedButton.icon(
                    onPressed: () {},
                    icon: const Icon(Icons.map),
                    label: const Text('Ajustar ubicación en mapa'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: AppConfig.primaryBlue,
                      minimumSize: const Size(200, 40),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 8),
              const Row(
                children: [
                  Icon(Icons.location_on, size: 14, color: Colors.grey),
                  SizedBox(width: 4),
                  Expanded(
                    child: Text(
                      'Av. Las Torres 123, Barrio San Pedro, Chimalhuacán',
                      style: TextStyle(fontSize: 12, color: Colors.grey),
                    ),
                  ),
                ],
              ),
              
              const SizedBox(height: 32),
              _buildSectionTitle('Evidencia Fotográfica'),
              const SizedBox(height: 16),
              GestureDetector(
                onTap: _pickImage,
                child: Container(
                  height: 120,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    border: Border.all(color: AppConfig.cardBorder),
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: _image != null 
                    ? ClipRRect(borderRadius: BorderRadius.circular(12), child: Image.file(_image!, fit: BoxFit.cover))
                    : const Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.add_a_photo_outlined, size: 40, color: Colors.grey),
                        SizedBox(height: 8),
                        Text('Toca para tomar o subir una foto', style: TextStyle(color: Colors.grey, fontSize: 13)),
                        Text('Formato JPG o PNG, máx 5MB', style: TextStyle(color: Colors.grey.withOpacity(0.6), fontSize: 11)),
                      ],
                    ),
                ),
              ),
              
              const SizedBox(height: 32),
              _buildSectionTitle('Tipo de Fuga'),
              const SizedBox(height: 16),
              GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  childAspectRatio: 3,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                ),
                itemCount: _reportTypes.length,
                itemBuilder: (context, index) {
                  final type = _reportTypes[index];
                  final isSelected = _selectedType == type['value'];
                  return InkWell(
                    onTap: () => setState(() => _selectedType = type['value']),
                    child: Container(
                      decoration: BoxDecoration(
                        color: isSelected ? AppConfig.primaryBlue : Colors.white,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: isSelected ? AppConfig.primaryBlue : AppConfig.cardBorder),
                      ),
                      child: Center(
                        child: Text(
                          type['label']!,
                          style: TextStyle(
                            color: isSelected ? Colors.white : Colors.black87,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
              
              const SizedBox(height: 32),
              _buildSectionTitle('Descripción Adicional (Opcional)'),
              const SizedBox(height: 16),
              TextField(
                controller: _descriptionController,
                maxLines: 3,
                decoration: const InputDecoration(
                  hintText: 'Ej: La fuga comenzó ayer por la tarde...',
                ),
              ),
              
              const SizedBox(height: 40),
              ElevatedButton(
                onPressed: () {
                  _showSuccessDialog();
                },
                child: const Text('Enviar Reporte'),
              ),
              const SizedBox(height: 12),
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Center(child: Text('Cancelar', style: TextStyle(color: Colors.grey))),
              ),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppConfig.primaryBlue),
    );
  }

  Widget _buildStepper() {
    return Row(
      children: [
        _buildStepIndicator(1, 'Datos', true),
        _buildStepLine(true),
        _buildStepIndicator(2, 'Reporte', true),
        _buildStepLine(false),
        _buildStepIndicator(3, 'Listo', false),
      ],
    );
  }

  Widget _buildStepIndicator(int num, String label, bool active) {
    return Column(
      children: [
        CircleAvatar(
          radius: 12,
          backgroundColor: active ? AppConfig.primaryBlue : Colors.grey[300],
          child: Text(num.toString(), style: const TextStyle(color: Colors.white, fontSize: 12)),
        ),
        const SizedBox(height: 4),
        Text(label, style: TextStyle(fontSize: 10, color: active ? AppConfig.primaryBlue : Colors.grey)),
      ],
    );
  }

  Widget _buildStepLine(bool active) {
    return Expanded(
      child: Container(
        height: 2,
        margin: const EdgeInsets.only(bottom: 15),
        color: active ? AppConfig.primaryBlue : Colors.grey[300],
      ),
    );
  }

  void _showSuccessDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.check_circle, color: Colors.green, size: 64),
            const SizedBox(height: 16),
            const Text('¡Reporte Enviado!', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            const Text('Tu reporte ha sido registrado con el folio:', textAlign: TextAlign.center),
            const SizedBox(height: 4),
            const Text('#F-24081', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: AppConfig.primaryBlue)),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop(); 
                Navigator.of(context).pop();
              },
              child: const Text('Aceptar'),
            ),
          ],
        ),
      ),
    );
  }
}
