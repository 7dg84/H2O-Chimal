import 'dart:io';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/config.dart';
import '../../models/service_model.dart';
import '../../providers/service_provider.dart';

class ServicesScreen extends StatefulWidget {
  const ServicesScreen({super.key});

  @override
  State<ServicesScreen> createState() => _ServicesScreenState();
}

class _ServicesScreenState extends State<ServicesScreen> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    // Carga inicial de servicios
    Future.microtask(() => context.read<ServiceProvider>().fetchServices());
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final serviceProvider = context.watch<ServiceProvider>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Catálogo de Servicios'),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(20.0),
            child: TextField(
              controller: _searchController,
              onChanged: (value) {
                // TODO: Add debounce
                // Buscamos en la API cada vez que el texto cambie
                context.read<ServiceProvider>().fetchServices(search: value);
              },
              decoration: InputDecoration(
                hintText: 'Buscar servicio (ej. Contrato, Pipa...)',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          _searchController.clear();
                          context.read<ServiceProvider>().fetchServices();
                          setState(() {});
                        },
                      )
                    : null,
              ),
            ),
          ),
          Expanded(
            child: serviceProvider.isLoading
                ? const Center(child: CircularProgressIndicator())
                : serviceProvider.services.isEmpty
                    ? const Center(child: Text('No se encontraron servicios'))
                    : RefreshIndicator(
                        onRefresh: () => context.read<ServiceProvider>().fetchServices(search: _searchController.text),
                        child: ListView.builder(
                          padding: const EdgeInsets.symmetric(horizontal: 20.0),
                          itemCount: serviceProvider.services.length,
                          itemBuilder: (context, index) {
                            final service = serviceProvider.services[index];
                            return _buildServiceCard(context, service);
                          },
                        ),
                      ),
          ),
        ],
      ),
    );
  }

  Widget _buildServiceCard(BuildContext context, ServiceModel service) {
    // Icono dinámico basado en el nombre
    IconData serviceIcon = Icons.plumbing;
    String name = service.name.toLowerCase();
    if (name.contains('agua') || name.contains('red')) {
      serviceIcon = Icons.water_drop;
    } else if (name.contains('pipa')) {
      serviceIcon = Icons.local_shipping;
    } else if (name.contains('drenaje')) {
      serviceIcon = Icons.waves;
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppConfig.cardBorder),
      ),
      child: ExpansionTile(
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: AppConfig.primaryBlue.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(serviceIcon, color: AppConfig.primaryBlue),
        ),
        title: Text(service.name, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text('Tiempo: ${service.responseTime}', style: const TextStyle(color: AppConfig.secondaryAzure, fontSize: 12)),
        childrenPadding: const EdgeInsets.all(16),
        expandedCrossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(service.description, style: const TextStyle(color: Colors.black87)),
          const SizedBox(height: 16),
          if (service.requirements.isNotEmpty) ...[
            const Text('Requisitos:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
            const SizedBox(height: 8),
            ...service.requirements.map((req) => Padding(
                  padding: const EdgeInsets.only(bottom: 4),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(
                        req.isRequired ? Icons.check_circle_outline : Icons.info_outline,
                        size: 14,
                        color: req.isRequired ? Colors.green : Colors.grey,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          '${req.documentTypeName}${req.isRequired ? ' (Obligatorio)' : ''}',
                          style: const TextStyle(fontSize: 13),
                        ),
                      ),
                    ],
                  ),
                )),
          ],
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Iniciando trámite: ${service.name}')),
              );
            },
            child: const Text('Iniciar Trámite'),
          ),
        ],
      ),
    );
  }
}
