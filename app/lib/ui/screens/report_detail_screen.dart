import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import '../../core/config.dart';
import '../../models/report_model.dart';
import '../../models/media_model.dart';
import '../../providers/report_provider.dart';

class ReportDetailScreen extends StatefulWidget {
  final String reportId;

  const ReportDetailScreen({super.key, required this.reportId});

  @override
  State<ReportDetailScreen> createState() => _ReportDetailScreenState();
}

class _ReportDetailScreenState extends State<ReportDetailScreen> {
  ReportModel? _report;
  List<MediaModel> _mediaList = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    Future.microtask(() => _loadReport());
  }

  Future<void> _loadReport() async {
    final reportProvider = context.read<ReportProvider>();
    final report = await reportProvider.getReportDetail(widget.reportId);
    
    if (report != null) {
      final media = await reportProvider.getReportMedia(report.media);
      if (mounted) {
        setState(() {
          _report = report;
          _mediaList = media;
          _isLoading = false;
        });
      }
    } else {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void _confirmDelete() {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('¿Eliminar Reporte?'),
        content: const Text('Esta acción no se puede deshacer.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () async {
              // 1. Cerramos el diálogo usando su propio contexto
              Navigator.pop(dialogContext);

              // 2. Ejecutamos la eliminación usando el contexto de la pantalla ('context')
              final success = await context.read<ReportProvider>().deleteReport(widget.reportId);

              // 3. Si tuvo éxito y la pantalla sigue montada, la cerramos
              if (success && mounted) {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Reporte eliminado con éxito')),
                );
              }
            },
            child: const Text('Eliminar', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    if (_report == null) {
      return const Scaffold(body: Center(child: Text('Reporte no encontrado')));
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Detalle de Reporte'),
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
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Reporte Folio #${_report!.folio}',
                      style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                    ),
                    Text(
                      'Registrado el ${DateFormat('dd/MM/yyyy').format(_report!.reportedAt)}',
                      style: const TextStyle(color: Colors.grey),
                    ),
                  ],
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: _report!.statusColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    _report!.statusText,
                    style: TextStyle(color: _report!.statusColor, fontWeight: FontWeight.bold, fontSize: 12),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            _buildStatusTimeline(),
            const SizedBox(height: 24),
            _buildSection(
              title: 'DETALLES TÉCNICOS',
              icon: Icons.info_outline,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(child: _buildDetailItem('TIPO', _report!.reportType)),
                      Expanded(child: _buildDetailItem('TIEMPO ESTIMADO', _report!.estimatedTime ?? '---')),
                    ],
                  ),
                  const SizedBox(height: 16),
                  _buildDetailItem('DESCRIPCIÓN', _report!.description),
                ],
              ),
            ),
            const SizedBox(height: 24),
            _buildSection(
              title: 'UBICACIÓN',
              icon: Icons.location_on_outlined,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(_report!.locationText),
                  const SizedBox(height: 12),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: SizedBox(
                      height: 150,
                      child: FlutterMap(
                        options: MapOptions(
                          initialCenter: LatLng(_report!.latitude, _report!.longitude),
                          initialZoom: 15,
                          interactionOptions: const InteractionOptions(flags: MultiFingerGesture.none),
                        ),
                        children: [
                          TileLayer(
                            urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                          ),
                          MarkerLayer(
                            markers: [
                              Marker(
                                point: LatLng(_report!.latitude, _report!.longitude),
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
                ],
              ),
            ),
            const SizedBox(height: 24),
            if (_mediaList.isNotEmpty)
              _buildSection(
                title: 'EVIDENCIA FOTOGRÁFICA',
                icon: Icons.camera_alt_outlined,
                child: Column(
                  children: _mediaList.map((media) => Padding(
                    padding: const EdgeInsets.only(bottom: 8.0),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: Image.network(
                        media.presignedUrl,
                        height: 200,
                        width: double.infinity,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => Container(
                          height: 200,
                          color: Colors.grey[200],
                          child: const Icon(Icons.broken_image_outlined, color: Colors.grey),
                        ),
                      ),
                    ),
                  )).toList(),
                ),
              ),
            const SizedBox(height: 32),
            ElevatedButton(
              onPressed: () {
                Navigator.pushNamed(context, '/report-edit', arguments: _report);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: AppConfig.primaryBlue,
                side: const BorderSide(color: AppConfig.primaryBlue),
                minimumSize: const Size(double.infinity, 50),
              ),
              child: const Text('Editar Reporte'),
            ),
            const SizedBox(height: 12),
            OutlinedButton.icon(
              onPressed: _confirmDelete,
              icon: const Icon(Icons.delete_outline, color: Colors.red),
              label: const Text('Eliminar Reporte', style: TextStyle(color: Colors.red)),
              style: OutlinedButton.styleFrom(
                minimumSize: const Size(double.infinity, 50),
                side: const BorderSide(color: Colors.red),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildSection({required String title, required IconData icon, required Widget child}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppConfig.cardBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 18, color: AppConfig.primaryBlue),
              const SizedBox(width: 8),
              Text(title, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: AppConfig.primaryBlue)),
            ],
          ),
          const SizedBox(height: 16),
          child,
        ],
      ),
    );
  }

  Widget _buildDetailItem(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontSize: 10, color: Colors.grey, fontWeight: FontWeight.bold)),
        Text(value, style: const TextStyle(fontSize: 14)),
      ],
    );
  }

  Widget _buildStatusTimeline() {
    final status = _report!.status;

    bool isStepDone(ReportStatus step) => status.index >= step.index;

    String getSubtitle(ReportStatus step) {
      if (step == ReportStatus.recibido) {
        return DateFormat('dd/MM/yyyy - hh:mm a').format(_report!.reportedAt);
      }
      if (step == status) {
        switch (step) {
          case ReportStatus.recibido:
            return 'Reporte recibido correctamente';
          case ReportStatus.enRevision:
            return 'Pendiente de validación por equipo técnico';
          case ReportStatus.enAtencion:
            return 'Personal asignado en proceso de atención';
          case ReportStatus.resuelto:
            return 'El problema ha sido solucionado';
          case ReportStatus.cerrado:
            return 'Reporte finalizado y archivado';
        }
      }
      return '';
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppConfig.cardBorder),
      ),
      child: Column(
        children: [
          const Row(children: [
            Icon(Icons.assignment_outlined, size: 18, color: AppConfig.primaryBlue),
            SizedBox(width: 8),
            Text('ESTADO DEL REPORTE',
                style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: AppConfig.primaryBlue)),
          ]),
          const SizedBox(height: 16),
          _buildTimelineItem('Recibido', getSubtitle(ReportStatus.recibido),
              isDone: isStepDone(ReportStatus.recibido), isLast: false),
          _buildTimelineItem('En revisión', getSubtitle(ReportStatus.enRevision),
              isDone: isStepDone(ReportStatus.enRevision), isLast: false),
          _buildTimelineItem('En atención', getSubtitle(ReportStatus.enAtencion),
              isDone: isStepDone(ReportStatus.enAtencion), isLast: false),
          _buildTimelineItem('Resuelto', getSubtitle(ReportStatus.resuelto),
              isDone: isStepDone(ReportStatus.resuelto), isLast: false),
          _buildTimelineItem('Cerrado', getSubtitle(ReportStatus.cerrado),
              isDone: isStepDone(ReportStatus.cerrado), isLast: true),
        ],
      ),
    );
  }

  Widget _buildTimelineItem(String title, String subtitle, {required bool isDone, required bool isLast}) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Column(
          children: [
            Container(
              width: 24,
              height: 24,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isDone ? AppConfig.primaryBlue : Colors.white,
                border: Border.all(color: isDone ? AppConfig.primaryBlue : Colors.grey[300]!, width: 2),
              ),
              child: isDone ? const Icon(Icons.check, size: 16, color: Colors.white) : null,
            ),
            if (!isLast)
              Container(
                width: 2,
                height: 30,
                color: Colors.grey[200],
              ),
          ],
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: TextStyle(fontWeight: FontWeight.bold, color: isDone ? Colors.black : Colors.grey)),
              if (subtitle.isNotEmpty)
                Text(subtitle, style: const TextStyle(fontSize: 12, color: Colors.grey)),
              const SizedBox(height: 15),
            ],
          ),
        ),
      ],
    );
  }
}
