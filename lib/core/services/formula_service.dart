import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import '../models/formula.dart';

class FormulaService extends GetxService {
  List<Formula> _allFormulas = [];
  final RxBool isLoading = false.obs;

  @override
  void onInit() {
    super.onInit();
    loadFormulas();
  }

  Future<void> loadFormulas() async {
    try {
      isLoading.value = true;
      final String jsonString =
          await rootBundle.loadString('assets/data/formulas.json');
      final List<dynamic> jsonData = json.decode(jsonString);
      _allFormulas = jsonData.map((json) => Formula.fromJson(json)).toList();
    } catch (e) {
      print('Error loading formulas: $e');
      _allFormulas = [];
    } finally {
      isLoading.value = false;
    }
  }

  List<Formula> getAllFormulas() {
    return List.unmodifiable(_allFormulas);
  }

  List<Formula> getFormulasByCategory(String category) {
    return _allFormulas.where((f) => f.category == category).toList();
  }

  List<Formula> searchFormulas(String query) {
    if (query.isEmpty) return getAllFormulas();
    final lowerQuery = query.toLowerCase();
    return _allFormulas
        .where((f) =>
            f.name.toLowerCase().contains(lowerQuery) ||
            f.description.toLowerCase().contains(lowerQuery) ||
            f.category.toLowerCase().contains(lowerQuery))
        .toList();
  }

  List<String> getAllCategories() {
    return _allFormulas.map((f) => f.category).toSet().toList()..sort();
  }

  Formula? getFormulaById(String id) {
    try {
      return _allFormulas.firstWhere((f) => f.id == id);
    } catch (e) {
      return null;
    }
  }
}






