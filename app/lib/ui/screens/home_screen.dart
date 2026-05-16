import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/config.dart';
import '../../providers/auth_provider.dart';
import '../widgets/report_card.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final user = context.watch<AuthProvider>().user;

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
      body: SingleChildScrollView(
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
                // Navigate to report form
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
                    onTap: () {},
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildQuickAction(
                    icon: Icons.map_outlined,
                    label: 'Zonas',
                    onTap: () {},
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 40),
            const Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Mis Reportes Activos',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppConfig.primaryBlue),
                ),
                Text('Ver todos', style: TextStyle(color: AppConfig.secondaryAzure)),
              ],
            ),
            const SizedBox(height: 16),
            // Placeholder for active reports
            const ReportCardPlaceholder(
              folio: '#CH-8821',
              title: 'Fuga de Banqueta',
              address: 'Calle Morelos 12, Centro',
              status: 'PENDIENTE',
              statusColor: AppConfig.statusPending,
            ),
            const ReportCardPlaceholder(
              folio: '#CH-8790',
              title: 'Falta de Presión',
              address: 'Av. Chimalhuacán 405',
              status: 'EN ATENCIÓN',
              statusColor: AppConfig.statusInAttention,
            ),
            
            const SizedBox(height: 32),
            const Text(
              'Zonas Afectadas Cercanas',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppConfig.primaryBlue),
            ),
            const SizedBox(height: 16),
            Container(
              height: 200,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                image: const DecorationImage(
                  image: NetworkImage('https://via.placeholder.com/400x200?text=Mapa+Zonas+Afectadas'),
                  fit: BoxFit.cover,
                ),
              ),
              child: Center(
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.location_on, color: Colors.red, size: 16),
                      SizedBox(width: 4),
                      Text('2 Reportes en tu zona', style: TextStyle(fontWeight: FontWeight.bold)),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 24),
          ],
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

class ReportCardPlaceholder extends StatelessWidget {
  final String folio;
  final String title;
  final String address;
  final String status;
  final Color statusColor;

  const ReportCardPlaceholder({
    super.key,
    required this.folio,
    required this.title,
    required this.address,
    required this.status,
    required this.statusColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: const Border(left: BorderSide(color: Colors.red, width: 4)), // Simplified for UI
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(folio, style: const TextStyle(fontSize: 12, color: Colors.grey)),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: statusColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  status,
                  style: TextStyle(color: statusColor, fontSize: 10, fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          const SizedBox(height: 4),
          Text(address, style: const TextStyle(color: Colors.grey, fontSize: 14)),
        ],
      ),
    );
  }
}
