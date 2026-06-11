import 'package:flutter/material.dart';
import '../models/tramite_model.dart';
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
}
