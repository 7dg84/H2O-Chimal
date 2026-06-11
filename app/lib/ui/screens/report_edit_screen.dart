import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import '../../core/config.dart';
import '../../models/report_model.dart';
import '../../providers/report_provider.dart';

class ReportEditScreen extends StatefulWidget {
  final ReportModel report;

  const ReportEditScreen({super.key, required this.report});

  @override
  State<ReportEditScreen> createState() => _ReportEditScreenState();
}

class _ReportEditScreenState extends State<ReportEditScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _locationController;
  late TextEditingController _descriptionController;
  late String _selectedType;
  late double _latitude;
  late double _longitude;

  final List<Map<String, String>> _reportTypes = [
    {'label': 'superficial', 'value': 'superficial'},
    {'label': 'tuberia', 'value': 'tuberia'},
    {'label': 'domiciliaria', 'value': 'domiciliaria'},
    {'label': 'obstruido', 'value': 'obstruido'},
  ];

  @override
  void initState() {
    super.initState();
    _locationController = TextEditingController(text: widget.report.locationText);
    _descriptionController = TextEditingController(text: widget.report.description);
    _selectedType = widget.report.reportType;
    _latitude = widget.report.latitude;
    _longitude = widget.report.longitude;
  }

  @override
  void dispose() {
    _locationController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  void _openMapPicker() async {
    // Reutilizamos el diálogo de selección de mapa si está disponible globalmente
    // o definimos uno localmente. Por simplicidad, asumimos que existe el _MapPickerDialog
    // definido en report_form_screen.dart o lo movemos a un widget común.
    // Aquí implementaré la navegación al diálogo directamente.
    
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

  void _handleUpdate() async {
    if (_formKey.currentState!.validate()) {
      final success = await context.read<ReportProvider>().updateReport(
        widget.report.id,
        latitude: _latitude,
        longitude: _longitude,
        locationText: _locationController.text,
        reportType: _selectedType,
        description: _descriptionController.text,
      );

      if (success && mounted) {
        Navigator.pop(context); // Volver al detalle
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Reporte actualizado correctamente')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isLoading = context.watch<ReportProvider>().isLoading;

    return Scaffold(
      appBar: AppBar(
        title: Text('Editar Reporte #${widget.report.folio}'),
        actions: [
          IconButton(icon: const Icon(Icons.more_vert), onPressed: () {}),
        ],
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
                  const Text('Ubicación del Reporte', style: TextStyle(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 12),
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
                  const SizedBox(height: 24),
                  const Text('Dirección Exacta', style: TextStyle(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  TextFormField(
                    controller: _locationController,
                    decoration: const InputDecoration(hintText: 'Colonia, calle, manzana, numero'),
                    validator: (v) => v!.isEmpty ? 'Campo requerido' : null,
                  ),
                  const SizedBox(height: 24),
                  const Text('Tipo de Fuga', style: TextStyle(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 12),
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
                        onTap: isLoading ? null : () => setState(() => _selectedType = type['value']!),
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
                  const SizedBox(height: 24),
                  const Text('Descripción de los hechos', style: TextStyle(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  TextFormField(
                    controller: _descriptionController,
                    maxLines: 4,
                    decoration: const InputDecoration(hintText: 'descripcion'),
                    validator: (v) => v!.isEmpty ? 'Campo requerido' : null,
                  ),
                  const SizedBox(height: 32),
                  ElevatedButton(
                    onPressed: isLoading ? null : _handleUpdate,
                    child: isLoading ? const CircularProgressIndicator(color: Colors.white) : const Text('Guardar Cambios'),
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
          if (isLoading)
            Container(color: Colors.black12, child: const Center(child: CircularProgressIndicator())),
        ],
      ),
    );
  }

  IconData _getIconForType(String type) {
    switch (type) {
      case 'superficial': return Icons.water_drop;
      case 'tuberia': return Icons.engineering;
      case 'domiciliaria': return Icons.home;
      case 'obstruido': return Icons.block;
      default: return Icons.help_outline;
    }
  }
}

// Reutilizamos el selector de mapa (debería moverse a un archivo común idealmente)
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
      child: Container(
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
                  Expanded(child: OutlinedButton(onPressed: () => Navigator.pop(context), child: const Text("Cancelar"))),
                  const SizedBox(width: 10),
                  Expanded(child: ElevatedButton(onPressed: () => Navigator.pop(context, _selectedPoint), child: const Text("Confirmar"))),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}
