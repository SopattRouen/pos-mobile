import 'package:flutter/material.dart';
import 'package:mobile/entity/model/response_structure_model.dart';
import 'package:mobile/services/home_service.dart';


class HomeProvider extends ChangeNotifier {
  // Feilds
  bool _isLoading = false;
  String? _error;
  ResponseStructure<Map<String, dynamic>>? _homeListData;

  // Services

  // Getters
  bool get isLoading => _isLoading;
  String? get error => _error;
  ResponseStructure<Map<String, dynamic>>? get homeListData => _homeListData;

  // Setters
  final HomeService _homeService = HomeService();

  // Initialize
  HomeProvider() {
    getHome();
  }

  // Functions
  Future<void> getHome() async {
    _isLoading = true;
    notifyListeners();
    try {
      // =================================================
      final response = await _homeService.homeServiceList();
      _homeListData = response;
    } catch (e) {
      _error = "Invalid Credential.";
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
