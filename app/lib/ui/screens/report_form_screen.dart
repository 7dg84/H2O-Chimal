import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'dart:io';
import '../../core/config.dart';
import '../../providers/report_provider.dart';
import '../widgets/show_success_dialog.dart';

class ReportFormScreen extends StatefulWidget {
  const ReportFormScreen({super.key});

  @override
  State<ReportFormScreen> createState() => _ReportFormScreenState();
}

class _ReportFormScreenState extends State<ReportFormScreen> {
  final _formKey = GlobalKey<FormState>();
  String? _selectedType;
  final List<File> _images = []; // Lista para múltiples imágenes
  final _descriptionController = TextEditingController();
  late TextEditingController _locationController;
  bool _initialized = false;

  // Coordenadas iniciales (Chimalhuacán)
  double _latitude = 19.4184;
  double _longitude = -98.9452;

  final List<Map<String, String>> _reportTypes = [
    {'label': 'Superficial', 'value': 'superficial'},
    {'label': 'Tubería', 'value': 'tuberia'},
    {'label': 'Toma dom.', 'value': 'domiciliaria'},
    {'label': 'Drenaje', 'value': 'obstruido'},
  ];

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    // Capturamos los argumentos solo una vez al iniciar
    if (!_initialized) {
      final args = ModalRoute.of(context)?.settings.arguments as Map<String, double>?;
      if (args != null) {
        setState(() {
          _latitude = args['latitude'] ?? _latitude;
          _longitude = args['longitude'] ?? _longitude;
        });
      }
      _initialized = true;
    }
  }

  @override
  void initState() {
    super.initState();
    _locationController = TextEditingController();
  }

  @override
  void dispose() {
    _descriptionController.dispose();
    _locationController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.camera);
    if (pickedFile != null) {
      setState(() {
        _images.add(File(pickedFile.path));
      });
    }
  }

  void _removeImage(int index) {
    setState(() {
      _images.removeAt(index);
    });
  }

  void _openMapPicker() async {
    LatLng? result = await showDialog<LatLng>(
      context: context,
      builder: (context) => _MapPickerDialog(
        initialPoint: LatLng(_latitude, _longitude),
      ),
    );

    if (result != null) {
      setState(() {
        _latitude = result.latitude;
        _longitude = result.longitude;
      });
    }
  }

  void _handleSendReport() async {
    if (_latitude == 19.4184 && _longitude == -98.9452) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Por favor selecciona una ubicación en el mapa')),
      );
      return;
    }
    if (_selectedType == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Por favor selecciona un tipo de fuga')),
      );
      return;
    }

    if (_locationController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Por favor escribe la dirección')),
      );
      return;
    }

    if (_descriptionController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Por favor escribe la descripcion')),
      );
      return;
    }

    if (_images.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Por favor agrega al menos una imagen')),
      );
      return;
    }


    final reportProvider = context.read<ReportProvider>();

    // El provider ya se encarga de crear el reporte y luego subir cada imagen de la lista
    final report = await reportProvider.createReport(
      latitude: _latitude,
      longitude: _longitude,
      locationText: _locationController.text,
      reportType: _selectedType!,
      description: _descriptionController.text,
      images: _images,
    );

    if (report != null) {
      if (mounted) {
        showSuccessDialog(context: context, folio: report.folio, title: '¡Reporte Enviado!', message: 'Tu reporte ha sido registrado con el folio:');
      }
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Error al enviar el reporte. Inténtalo de nuevo.')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isLoading = context.watch<ReportProvider>().isLoading;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Reportar Fuga'),
      ),
      body: Stack(
        children: [
          SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildStepper(),
                  const SizedBox(height: 32),

                  _buildSectionTitle('Ubicación en Mapa'),
                  const SizedBox(height: 16),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Container(
                      height: 180,
                      child: Stack(
                        children: [
                          FlutterMap(
                            options: MapOptions(
                              initialCenter: LatLng(_latitude, _longitude),
                              initialZoom: 15,
                            ),
                            children: [
                              TileLayer(urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png'),
                              MarkerLayer(
                                markers: [
                                  Marker(
                                    point: LatLng(_latitude, _longitude),
                                    width: 40,
                                    height: 40,
                                    child: const Icon(Icons.location_on, color: Colors.blue, size: 40),
                                  ),
                                ],
                              ),
                            ],
                          ),
                          Positioned(
                            bottom: 12,
                            right: 12,
                            child: ElevatedButton.icon(
                              onPressed: _openMapPicker,
                              icon: const Icon(Icons.gps_fixed, size: 16),
                              label: const Text('Ajustar ubicación'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppConfig.primaryBlue,
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(horizontal: 12),
                                minimumSize: const Size(0, 40),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    "Lat: ${_latitude.toStringAsFixed(6)}, Long: ${_longitude.toStringAsFixed(6)}",
                    style: const TextStyle(fontSize: 11, color: Colors.grey),
                  ),

                  const SizedBox(height: 24),
                  _buildSectionTitle('Dirección Detallada'),
                  const SizedBox(height: 8),
                  TextField(
                    controller: _locationController,
                    enabled: !isLoading,
                    decoration: const InputDecoration(
                      hintText: 'Colonia, calle, manzana, número...',
                      prefixIcon: Icon(Icons.location_on_outlined),
                    ),
                  ),

                  const SizedBox(height: 32),
                  _buildSectionTitle('Evidencias Fotográficas'),
                  const SizedBox(height: 16),

                  // Galería de imágenes con opción de añadir más
                  SizedBox(
                    height: 100,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: _images.length + 1,
                      itemBuilder: (context, index) {
                        if (index == _images.length) {
                          return _buildAddImageButton(isLoading);
                        }
                        return _buildImageThumbnail(index);
                      },
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
                        onTap: isLoading ? null : () => setState(() => _selectedType = type['value']),
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
                    enabled: !isLoading,
                    decoration: const InputDecoration(
                      hintText: 'Ej: La fuga comenzó ayer por la tarde...',
                    ),
                  ),

                  const SizedBox(height: 40),
                  ElevatedButton(
                    onPressed: isLoading ? null : _handleSendReport,
                    child: isLoading
                        ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2)
                    )
                        : const Text('Enviar Reporte'),
                  ),
                  const SizedBox(height: 12),
                  TextButton(
                    onPressed: isLoading ? null : () => Navigator.pop(context),
                    child: const Center(child: Text('Cancelar', style: TextStyle(color: Colors.grey))),
                  ),
                  const SizedBox(height: 40),
                ],
              ),
            ),
          ),
          if (isLoading)
            Container(
              color: Colors.black.withOpacity(0.1),
              child: const Center(child: CircularProgressIndicator()),
            ),
        ],
      ),
    );
  }

  Widget _buildImageThumbnail(int index) {
    return Stack(
      children: [
        Container(
          margin: const EdgeInsets.only(right: 12),
          width: 100,
          height: 100,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            image: DecorationImage(
              image: FileImage(_images[index]),
              fit: BoxFit.cover,
            ),
          ),
        ),
        Positioned(
          top: 0,
          right: 12,
          child: GestureDetector(
            onTap: () => _removeImage(index),
            child: Container(
              padding: const EdgeInsets.all(4),
              decoration: const BoxDecoration(color: Colors.red, shape: BoxShape.circle),
              child: const Icon(Icons.close, size: 14, color: Colors.white),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildAddImageButton(bool isLoading) {
    return GestureDetector(
      onTap: isLoading ? null : _pickImage,
      child: Container(
        width: 100,
        height: 100,
        decoration: BoxDecoration(
          border: Border.all(color: AppConfig.cardBorder, style: BorderStyle.solid),
          borderRadius: BorderRadius.circular(12),
          color: Colors.white,
        ),
        child: const Icon(Icons.add_a_photo_outlined, color: Colors.grey),
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

}

class _MapPickerDialog extends StatefulWidget {
  final LatLng initialPoint;
  const _MapPickerDialog({required this.initialPoint});

  @override
  State<_MapPickerDialog> createState() => __MapPickerDialogState();
}

class __MapPickerDialogState extends State<_MapPickerDialog> {
  late LatLng _selectedPoint;
  final MapController _mapController = MapController();

  @override
  void initState() {
    super.initState();
    _selectedPoint = widget.initialPoint;
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      insetPadding: const EdgeInsets.all(10),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: SizedBox(
        height: 500,
        width: double.infinity,
        child: Column(
          children: [
            Expanded(
              child: ClipRRect(
                borderRadius: const BorderRadius.vertical(top: Radius.circular(15)),
                child: FlutterMap(
                  mapController: _mapController,
                  options: MapOptions(
                    initialCenter: _selectedPoint,
                    initialZoom: 15,
                    onTap: (_, point) => setState(() => _selectedPoint = point),
                  ),
                  children: [
                    TileLayer(
                      urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                      userAgentPackageName: 'com.h2ochimal.app',
                    ),
                    MarkerLayer(
                      markers: [
                        Marker(
                          point: _selectedPoint,
                          width: 40,
                          height: 40,
                          child: const Icon(Icons.location_on, color: Colors.red, size: 40),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(15.0),
              child: Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text("Cancelar"),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () => Navigator.pop(context, _selectedPoint),
                      child: const Text("Confirmar"),
                    ),
                  ),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}