import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import '../../core/config.dart';
import '../../models/service_model.dart';
import '../../providers/tramite_provider.dart';
import '../widgets/show_success_dialog.dart';

class TramiteFormScreen extends StatefulWidget {
  final ServiceModel service;

  const TramiteFormScreen({super.key, required this.service});

  @override
  State<TramiteFormScreen> createState() => _TramiteFormScreenState();
}

class _TramiteFormScreenState extends State<TramiteFormScreen> {
  final Map<String, File> _pickedFiles = {};
  final ImagePicker _picker = ImagePicker();
  bool _isSubmitting = false;

  Future<void> _pickFile(String documentTypeId) async {
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      setState(() {
        _pickedFiles[documentTypeId] = File(image.path);
      });
    }
  }

  Future<void> _submit() async {
    // Validar que todos los requeridos tengan archivo
    for (var req in widget.service.requirements) {
      if (req.isRequired && !_pickedFiles.containsKey(req.documentTypeId)) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Por favor adjunta: ${req.documentTypeName}')),
        );
        return;
      }
    }

    setState(() => _isSubmitting = true);

    final tramite = await context.read<TramiteProvider>().createTramite(
      widget.service.id,
      _pickedFiles,
    );

    if (mounted) {
      setState(() => _isSubmitting = false);
      if (tramite != null) {
        showSuccessDialog(context: context, folio: tramite.folio, title: '¡Solicitud Enviada!', message: 'Tu tramite ha sido registrado con el folio:');
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Error al crear el trámite. Inténtalo de nuevo.')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text('Catalogo', style: TextStyle(fontSize: 18)),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_none),
            onPressed: () {},
          ),
        ],
      ),
      body: Stack(
        children: [
          SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 12),
                Text(
                  widget.service.name,
                  style: const TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: AppConfig.primaryBlue,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Completa el formulario y adjunta la documentación solicitada para iniciar tu trámite.',
                  style: TextStyle(color: Colors.grey[600], fontSize: 15),
                ),
                const SizedBox(height: 24),
                Row(
                  children: [
                    Expanded(
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(10),
                        child: const LinearProgressIndicator(
                          value: 0.5,
                          minHeight: 8,
                          backgroundColor: Color(0xFFE2E8F0),
                          valueColor: AlwaysStoppedAnimation<Color>(AppConfig.primaryBlue),
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    const Text('Paso 1 de 2', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500)),
                  ],
                ),
                const SizedBox(height: 32),
                const Text(
                  'Documentación Requerida',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 16),
                ...widget.service.requirements.map((req) => _buildRequirementCard(req)),
                const SizedBox(height: 32),
                ElevatedButton(
                  onPressed: _isSubmitting ? null : _submit,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF003D82),
                    minimumSize: const Size(double.infinity, 56),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text('Enviar Solicitud', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                      const SizedBox(width: 8),
                      Transform.rotate(angle: -0.5, child: const Icon(Icons.send, size: 18)),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
                OutlinedButton(
                  onPressed: () => Navigator.pop(context),
                  style: OutlinedButton.styleFrom(
                    minimumSize: const Size(double.infinity, 56),
                    side: const BorderSide(color: Color(0xFFD1D5DB)),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: const Text('Cancelar', style: TextStyle(color: Color(0xFF4B5563))),
                ),
                const SizedBox(height: 40),
              ],
            ),
          ),
          if (_isSubmitting)
            Container(
              color: Colors.black26,
              child: const Center(child: CircularProgressIndicator()),
            ),
        ],
      ),
    );
  }

  Widget _buildRequirementCard(ServiceRequirement req) {
    final hasFile = _pickedFiles.containsKey(req.documentTypeId);
    
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                req.isRequired ? 'REQUERIDO' : 'OPCIONAL',
                style: const TextStyle(
                  color: AppConfig.primaryBlue,
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 0.5,
                ),
              ),
              Icon(_getIconForDocType(req.documentTypeName), color: Colors.grey[400], size: 20),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            req.documentTypeName,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          if (req.notes.isNotEmpty) ...[
            const SizedBox(height: 4),
            Text(
              req.notes,
              style: TextStyle(color: Colors.grey[600], fontSize: 12),
            ),
          ],
          const SizedBox(height: 16),
          InkWell(
            onTap: () => _pickFile(req.documentTypeId),
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 12),
              decoration: BoxDecoration(
                color: const Color(0xFFF3F7FF),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: const Color(0xFFD1E0FF), style: BorderStyle.solid),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(hasFile ? Icons.check_circle : Icons.file_upload_outlined, 
                      size: 18, 
                      color: hasFile ? Colors.green : AppConfig.primaryBlue),
                  const SizedBox(width: 8),
                  Text(
                    hasFile ? 'Archivo seleccionado' : 'Adjuntar archivo',
                    style: TextStyle(
                      color: hasFile ? Colors.green : AppConfig.primaryBlue,
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
          ),
          if (hasFile) ...[
            const SizedBox(height: 8),
            Text(
              'Seleccionado: ${_pickedFiles[req.documentTypeId]!.path.split('/').last}',
              style: const TextStyle(fontSize: 11, color: Colors.grey),
            ),
          ]
        ],
      ),
    );
  }

  IconData _getIconForDocType(String name) {
    final n = name.toLowerCase();
    if (n.contains('ine') || n.contains('identificación')) return Icons.description_outlined;
    if (n.contains('domicilio')) return Icons.location_on_outlined;
    if (n.contains('escrituras') || n.contains('propiedad')) return Icons.assignment_outlined;
    return Icons.insert_drive_file_outlined;
  }
}
