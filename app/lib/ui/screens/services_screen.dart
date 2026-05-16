import 'package:flutter/material.dart';
import '../../core/config.dart';

class ServicesScreen extends StatelessWidget {
  const ServicesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Catálogo de Servicios'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            TextField(
              decoration: InputDecoration(
                hintText: 'Buscar servicio (ej. Contrato, Pipa...)',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
            const SizedBox(height: 24),
            _buildServiceCard(
              context,
              icon: Icons.water_drop,
              title: 'Contrato de agua',
              description: 'Solicitud de nueva toma domiciliaria para predios regulares.',
              time: '3 a 5 días hábiles',
              requirements: [
                'Identificación oficial vigente',
                'Comprobante de domicilio (no mayor a 3 meses)',
                'Documento que acredite la propiedad',
              ],
            ),
            _buildServiceCard(
              context,
              icon: Icons.plumbing,
              title: 'Contrato de drenaje',
              description: 'Conexión a la red municipal de alcantarillado sanitario.',
              time: '5 a 7 días hábiles',
              requirements: [
                'Identificación oficial vigente',
                'Croquis de localización de la descarga',
                'Pago de derechos correspondientes',
              ],
            ),
            _buildServiceCard(
              context,
              icon: Icons.local_shipping,
              title: 'Suministro de pipa',
              description: 'Solicitud de agua potable en camión-cisterna ante escasez.',
              time: '24 a 48 horas',
              requirements: [
                'Estar al corriente en pagos',
                'Ubicación exacta del domicilio',
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildServiceCard(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String description,
    required String time,
    required List<String> requirements,
  }) {
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
          child: Icon(icon, color: AppConfig.primaryBlue),
        ),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text(time, style: const TextStyle(color: AppConfig.secondaryAzure, fontSize: 12)),
        childrenPadding: const EdgeInsets.all(16),
        children: [
          Text(description, style: const TextStyle(color: Colors.black87)),
          const SizedBox(height: 16),
          const Text('Requisitos principales:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
          const SizedBox(height: 8),
          ...requirements.map((req) => Padding(
                padding: const EdgeInsets.only(bottom: 4),
                child: Row(
                  children: [
                    const Icon(Icons.check_circle_outline, size: 14, color: Colors.green),
                    const SizedBox(width: 8),
                    Expanded(child: Text(req, style: const TextStyle(fontSize: 13))),
                  ],
                ),
              )),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () {
              // Navigate to specific service form
            },
            child: const Text('Iniciar Trámite'),
          ),
        ],
      ),
    );
  }
}
