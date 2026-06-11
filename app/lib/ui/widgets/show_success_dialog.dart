import 'package:flutter/material.dart';
import '../../core/config.dart';

void showSuccessDialog({
  required BuildContext context,
  required String folio,
  String title = '¡Solicitud Enviada!',
  String message = 'Tu solicitud ha sido registrada con el folio:',
  VoidCallback? onConfirm,
}) {
  showDialog(
    context: context,
    barrierDismissible: false,
    builder: (dialogContext) => AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.check_circle, color: Colors.green, size: 64),
          const SizedBox(height: 16),
          Text(
            title,
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            message,
            textAlign: TextAlign.center,
            style: const TextStyle(color: Colors.grey),
          ),
          const SizedBox(height: 8),
          Text(
            '#$folio',
            style: const TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: AppConfig.primaryBlue,
            ),
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: () {
              Navigator.of(dialogContext).pop(); // Cierra el diálogo
              if (onConfirm != null) {
                onConfirm();
              } else {
                Navigator.of(context).pop(); // Regresa a la pantalla anterior por defecto
              }
            },
            child: const Text('Aceptar'),
          ),
        ],
      ),
    ),
  );
}
