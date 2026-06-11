import 'package:flutter/material.dart';
import '../models/service_model.dart';
import '../services/service_service.dart';

class ServiceProvider with ChangeNotifier {
  final ServiceService _serviceService;
  List<ServiceModel> _services = [];
  bool _isLoading = false;

  ServiceProvider(this._serviceService);

  List<ServiceModel> get services => _services;
  bool get isLoading => _isLoading;

  Future<void> fetchServices({String? search}) async {
    _isLoading = true;
    notifyListeners();
    try {
      _services = await _serviceService.getServices(search: search);
    } catch (e) {
      print("Error fetching services: $e");
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<ServiceModel?> getServiceDetail(String id) async {
    _isLoading = true;
    notifyListeners();
    try {
      return await _serviceService.getServiceDetail(id);
    } catch (e) {
      print("Error fetching service detail: $e");
      return null;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
