import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../core/config.dart';
import '../../providers/auth_provider.dart';
import '../../providers/report_provider.dart';
import '../../providers/tramite_provider.dart';
import '../widgets/report_card.dart';
import '../widgets/tramite_card.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadData();
    });
  }

  void _loadData() {
    context.read<ReportProvider>().fetchAllReports();
    context.read<TramiteProvider>().fetchTramites();
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final reportProvider = context.watch<ReportProvider>();
    final tramiteProvider = context.watch<TramiteProvider>();
    final user = auth.user;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Mi Cuenta'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout, color: Colors.red),
            onPressed: () => auth.logout(),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          _loadData();
        },
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // User Profile Header
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppConfig.cardBorder),
                ),
                child: Column(
                  children: [
                    Row(
                      children: [
                        CircleAvatar(
                          radius: 35,
                          backgroundColor: AppConfig.primaryBlue.withOpacity(0.1),
                          child: const Icon(Icons.person, size: 40, color: AppConfig.primaryBlue),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                user?.name ?? 'Nombre No Disponible',
                                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                              ),
                              Text(user?.email ?? '', style: const TextStyle(color: Colors.grey)),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const Divider(height: 32),
                    _buildInfoRow(Icons.badge_outlined, 'CURP', user?.curp ?? 'N/A'),
                    const SizedBox(height: 12),
                    _buildInfoRow(Icons.phone_outlined, 'Teléfono', user?.phone ?? 'N/A'),
                    const SizedBox(height: 12),
                    _buildInfoRow(Icons.location_on_outlined, 'Dirección', 
                      '${user?.street} ${user?.exteriorNumber}, ${user?.colonia}'),
                    const SizedBox(height: 24),
                    OutlinedButton.icon(
                      onPressed: () {},
                      icon: const Icon(Icons.edit_outlined, size: 18),
                      label: const Text('Editar Perfil'),
                      style: OutlinedButton.styleFrom(
                        minimumSize: const Size(double.infinity, 45),
                        side: const BorderSide(color: AppConfig.primaryBlue),
                      ),
                    ),
                  ],
                ),
              ),
              
              const SizedBox(height: 32),
              const Text(
                'Mis Reportes',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppConfig.primaryBlue),
              ),
              const SizedBox(height: 16),
              
              if (reportProvider.isLoading)
                const Center(child: Padding(
                  padding: EdgeInsets.all(20.0),
                  child: CircularProgressIndicator(),
                ))
              else if (reportProvider.recentReports.isEmpty)
                const Center(
                  child: Padding(
                    padding: EdgeInsets.all(20.0),
                    child: Text('No tienes reportes registrados.', style: TextStyle(color: Colors.grey)),
                  ),
                )
              else
                ...reportProvider.allReports.map((report) => ReportCard(report: report)),
              
              const SizedBox(height: 32),
              const Text(
                'Mis Trámites',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppConfig.primaryBlue),
              ),
              const SizedBox(height: 16),

              if (tramiteProvider.isLoading)
                const Center(child: Padding(
                  padding: EdgeInsets.all(20.0),
                  child: CircularProgressIndicator(),
                ))
              else if (tramiteProvider.tramites.isEmpty)
                const Center(
                  child: Padding(
                    padding: EdgeInsets.all(20.0),
                    child: Text('No tienes trámites registrados.', style: TextStyle(color: Colors.grey)),
                  ),
                )
              else
                ...tramiteProvider.tramites.map((tramite) => TramiteCard(tramite: tramite,)),
                //     _buildTramiteListItem(
                //   folio: tramite.folio,
                //   service: tramite.serviceName,
                //   date: DateFormat('dd MMM yyyy').format(tramite.createdAt),
                //   status: tramite.statusText,
                //   statusColor: tramite.statusColor,
                // )),
                const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(icon, size: 20, color: Colors.grey),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: const TextStyle(fontSize: 12, color: Colors.grey)),
              Text(value, style: const TextStyle(fontWeight: FontWeight.w500)),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildTramiteListItem({
    required String folio,
    required String service,
    required String date,
    required String status,
    required Color statusColor,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppConfig.cardBorder),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Folio: $folio', style: const TextStyle(fontSize: 12, color: Colors.grey)),
                const SizedBox(height: 4),
                Text(service, style: const TextStyle(fontWeight: FontWeight.bold)),
                Text(date, style: const TextStyle(fontSize: 12, color: Colors.grey)),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: statusColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              status,
              style: TextStyle(color: statusColor, fontSize: 11, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }
}
