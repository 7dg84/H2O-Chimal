import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:geolocator/geolocator.dart';
import 'package:provider/provider.dart';
import '../../core/config.dart';
import '../../providers/report_provider.dart';

class MapScreen extends StatefulWidget {
  const MapScreen({super.key});

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  final MapController _mapController = MapController();
  Position? _currentPosition;

  @override
  void initState() {
    super.initState();
    _determinePosition();
    // Cargar las coordenadas de los reportes al iniciar
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ReportProvider>().fetchReportCoordinates();
    });
  }

  Future<void> _determinePosition() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) return;

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) return;
    }

    if (permission == LocationPermission.deniedForever) return;

    final position = await Geolocator.getCurrentPosition();
    setState(() {
      _currentPosition = position;
    });

    _mapController.move(
      LatLng(position.latitude, position.longitude),
      15.0,
    );
  }

  Color _getMarkerColor(String type) {
    switch (type) {
      case 'superficial':
        return Colors.blue;
      case 'tuberia':
        return Colors.teal;
      case 'domiciliaria':
        return Colors.orange;
      case 'obstruido':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    final reportProvider = context.watch<ReportProvider>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Mapa de Reportes'),
        actions: [
          if (reportProvider.isLoading)
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16),
              child: Center(
                child: SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
              ),
            ),
        ],
      ),
      body: Stack(
        children: [
          FlutterMap(
            mapController: _mapController,
            options: const MapOptions(
              initialCenter: LatLng(19.4184, -98.9452), // Chimalhuacán
              initialZoom: 14.0,
            ),
            children: [
              TileLayer(
                urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                userAgentPackageName: 'com.h2ochimal.app',
              ),
              MarkerLayer(
                markers: [
                  // Marcador de posición actual del usuario
                  if (_currentPosition != null)
                    Marker(
                      point: LatLng(_currentPosition!.latitude, _currentPosition!.longitude),
                      width: 45,
                      height: 45,
                      child: const Icon(
                        Icons.person_pin_circle,
                        color: AppConfig.primaryBlue,
                        size: 45,
                      ),
                    ),
                  // Marcadores de los reportes de la API
                  ...reportProvider.reportCoordinates.map((coord) => Marker(
                        point: LatLng(coord.latitude, coord.longitude),
                        width: 35,
                        height: 35,
                        child: GestureDetector(
                          onTap: () {
                            // Opcional: Mostrar un snackbar o tooltip con el tipo
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text('Reporte: ${coord.reportType}'),
                                duration: const Duration(seconds: 1),
                              ),
                            );
                          },
                          child: Icon(
                            Icons.location_on,
                            color: _getMarkerColor(coord.reportType),
                            size: 35,
                          ),
                        ),
                      )),
                ],
              ),
            ],
          ),
          _buildMapLegend(),
          Positioned(
            bottom: 20,
            left: 20,
            right: 20,
            child: ElevatedButton.icon(
              onPressed: () {
                Navigator.pushNamed(
                  context,
                  '/report-fuga',
                  arguments: {
                    'latitude': _currentPosition?.latitude ?? 19.4184,
                    'longitude': _currentPosition?.longitude ?? -98.9452,
                  },
                );
              },
              icon: const Icon(Icons.add_location_alt),
              label: const Text('Reportar Fuga Aquí'),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                backgroundColor: AppConfig.primaryBlue,
                foregroundColor: Colors.white,
                elevation: 8,
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: Padding(
        padding: const EdgeInsets.only(bottom: 80.0),
        child: FloatingActionButton(
          onPressed: _determinePosition,
          backgroundColor: Colors.white,
          child: const Icon(Icons.my_location, color: AppConfig.primaryBlue),
        ),
      ),
    );
  }

  Widget _buildMapLegend() {
    return Positioned(
      top: 20,
      right: 20,
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.9),
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 10),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text("Tipos de Fuga", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
            const SizedBox(height: 8),
            _legendItem(Colors.blue, "Superficial"),
            _legendItem(Colors.teal, "Tubería"),
            _legendItem(Colors.orange, "Domiciliaria"),
            _legendItem(Colors.red, "Obstruido"),
          ],
        ),
      ),
    );
  }

  Widget _legendItem(Color color, String label) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(width: 12, height: 12, decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
          const SizedBox(width: 8),
          Text(label, style: const TextStyle(fontSize: 11)),
        ],
      ),
    );
  }
}
