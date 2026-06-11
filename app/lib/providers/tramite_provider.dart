import 'dart:io';
import 'package:flutter/material.dart';
import '../models/tramite_model.dart';
import '../models/document_model.dart';
import '../services/tramite_service.dart';

class TramiteProvider with ChangeNotifier {
  final TramiteService _tramiteService;
  List<TramiteModel> _tramites = [];
  bool _isLoading = false;

  TramiteProvider(this._tramiteService);

  List<TramiteModel> get tramites => _tramites;
  bool get isLoading => _isLoading;

  Future<void> fetchTramites() async {
    _isLoading = true;
    notifyListeners();
    try {
      _tramites = await _tramiteService.getTramites();
    } catch (e) {
      print("Error fetching tramites: $e");
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<TramiteModel?> getTramiteDetail(String id) async {
    _isLoading = true;
    // Usamos microtask para evitar el error de notifyListeners durante el build si se llama desde initState
    Future.microtask(() => notifyListeners());
    try {
      return await _tramiteService.getTramiteDetail(id);
    } catch (e) {
      print("Error fetching tramite detail: $e");
      return null;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<DocumentModel?> getDocumentDetail(String documentId) async {
    try {
      return await _tramiteService.getDocumentDetail(documentId);
    } catch (e) {
      print("Error fetching document detail: $e");
      return null;
    }
  }

  Future<TramiteModel?> createTramite(String serviceId, Map<String, File> documents) async {
    _isLoading = true;
    notifyListeners();
    try {
      // 1. Crear el trámite
      final tramite = await _tramiteService.createTramite(serviceId);
      
      // 2. Subir cada documento
      for (var entry in documents.entries) {
        await _tramiteService.uploadDocument(tramite.id, entry.key, entry.value);
      }
      
      await fetchTramites();
      return tramite;
    } catch (e) {
      print("Error creating tramite: $e");
      return null;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
