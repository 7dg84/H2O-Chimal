import 'package:app/providers/navigation_provider.dart';
import 'package:app/providers/report_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import '../../core/config.dart';
import '../../providers/auth_provider.dart';
import '../widgets/report_card.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  void initState() {
    super.initState();
    // Cargamos los reportes recientes al iniciar la pantalla
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ReportProvider>().fetchRecentReports();
    });
  }

  @override
  Widget build(BuildContext context) {
    final user = context.watch<AuthProvider>().user;
    final reportProvider = context.watch<ReportProvider>();

    // Coordenadas por defecto (Chimalhuacán)
    LatLng center = const LatLng(19.4172, -98.9483);
    
    // Si hay reportes, centramos en el primero para dar contexto local
    if (reportProvider.recentReports.isNotEmpty) {
      center = LatLng(
        reportProvider.recentReports.first.latitude,
        reportProvider.recentReports.first.longitude,
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('H2O Chimal', style: TextStyle(fontWeight: FontWeight.bold)),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_outlined),
            onPressed: () {},
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () => context.read<ReportProvider>().fetchRecentReports(),
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '¡Hola, ${user?.name?.split(' ').first ?? 'Usuario'}!',
                style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: AppConfig.primaryBlue),
              ),
              const SizedBox(height: 8),
              const Text(
                'Mantengamos nuestra ciudad fluyendo.\nReporta cualquier problema hoy.',
                style: TextStyle(fontSize: 16, color: Colors.black54),
              ),
              const SizedBox(height: 32),
              
              // Fast Action Button
              GestureDetector(
                onTap: () {
                  Navigator.pushNamed(context, '/report-fuga');
                },
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: AppConfig.primaryBlue,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: AppConfig.primaryBlue.withOpacity(0.3),
                        blurRadius: 15,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: const Column(
                    children: [
                      Icon(Icons.home_repair_service, color: Colors.white, size: 48),
                      SizedBox(height: 12),
                      Text(
                        'Reportar Fuga',
                        style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
                      ),
                      Text(
                        'Menos de 2 minutos',
                        style: TextStyle(color: Colors.white70, fontSize: 14),
                      ),
                    ],
                  ),
                ),
              ),
              
              const SizedBox(height: 32),
              Row(
                children: [
                  Expanded(
                    child: _buildQuickAction(
                      icon: Icons.plumbing,
                      label: 'Servicios',
                      onTap: () {
                        context.read<NavigationProvider>().setIndex(2);
                      },
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _buildQuickAction(
                      icon: Icons.map_outlined,
                      label: 'Zonas',
                      onTap: () {
                        context.read<NavigationProvider>().setIndex(1);
                      },
                    ),
                  ),
                ],
              ),
              
              const SizedBox(height: 40),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Mis Reportes Activos',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppConfig.primaryBlue),
                  ),
                  TextButton(
                    onPressed: () {
                      context.read<NavigationProvider>().setIndex(3);
                    },
                    child: const Text('Ver todos', style: TextStyle(color: AppConfig.secondaryAzure)),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              
              if (reportProvider.isLoading)
                const Center(child: CircularProgressIndicator())
              else if (reportProvider.recentReports.isEmpty)
                const Center(
                  child: Padding(
                    padding: EdgeInsets.all(20.0),
                    child: Text('No tienes reportes recientes.', style: TextStyle(color: Colors.grey)),
                  ),
                )
              else
                ...reportProvider.recentReports.map((report) => ReportCard(report: report)),
              
              const SizedBox(height: 32),
              const Text(
                'Zonas Afectadas Cercanas',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppConfig.primaryBlue),
              ),
              const SizedBox(height: 16),
              SizedBox(
                height: 250,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: FlutterMap(
                    options: MapOptions(
                      initialCenter: center,
                      initialZoom: 13.0,
                      interactionOptions: const InteractionOptions(
                        flags: InteractiveFlag.none,
                      ),
                    ),
                    children: [
                      TileLayer(
                        urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                        userAgentPackageName: 'com.h2ochimal.app',
                      ),
                      MarkerLayer(
                        markers: reportProvider.recentReports.map((report) {
                          return Marker(
                            point: LatLng(report.latitude, report.longitude),
                            width: 40,
                            height: 40,
                            child: const Icon(
                              Icons.location_on,
                              color: Colors.red,
                              size: 40,
                            ),
                          );
                        }).toList(),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildQuickAction({required IconData icon, required String label, required VoidCallback onTap}) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppConfig.cardBorder),
        ),
        child: Column(
          children: [
            Icon(icon, color: AppConfig.primaryBlue),
            const SizedBox(height: 8),
            Text(label, style: const TextStyle(fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
  }
}
