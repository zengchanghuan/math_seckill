import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../core/models/formula.dart';
import '../../../core/services/formula_service.dart';

class FormulaController extends GetxController {
  final FormulaService _formulaService = Get.find<FormulaService>();

  final RxList<Formula> filteredFormulas = <Formula>[].obs;
  final RxString searchQuery = ''.obs;
  final RxString selectedCategory = '全部'.obs;
  final RxList<String> favoriteFormulaIds = <String>[].obs;

  @override
  void onInit() {
    super.onInit();
    loadFavorites();
    filterFormulas();
  }

  void filterFormulas() {
    List<Formula> formulas;

    if (selectedCategory.value == '全部') {
      formulas = _formulaService.getAllFormulas();
    } else {
      formulas = _formulaService.getFormulasByCategory(selectedCategory.value);
    }

    if (searchQuery.value.isNotEmpty) {
      formulas = _formulaService.searchFormulas(searchQuery.value);
      // 如果选择了分类，需要再次过滤
      if (selectedCategory.value != '全部') {
        formulas = formulas
            .where((f) => f.category == selectedCategory.value)
            .toList();
      }
    }

    filteredFormulas.value = formulas;
  }

  void setSearchQuery(String query) {
    searchQuery.value = query;
    filterFormulas();
  }

  void setCategory(String category) {
    selectedCategory.value = category;
    filterFormulas();
  }

  bool isFavorite(String formulaId) {
    return favoriteFormulaIds.contains(formulaId);
  }

  void toggleFavorite(String formulaId) {
    if (favoriteFormulaIds.contains(formulaId)) {
      favoriteFormulaIds.remove(formulaId);
    } else {
      favoriteFormulaIds.add(formulaId);
    }
    saveFavorites();
  }

  Future<void> loadFavorites() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final favorites = prefs.getStringList('favorite_formulas') ?? [];
      favoriteFormulaIds.value = favorites;
    } catch (e) {
      print('Error loading favorites: $e');
    }
  }

  Future<void> saveFavorites() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setStringList(
          'favorite_formulas', favoriteFormulaIds.toList());
    } catch (e) {
      print('Error saving favorites: $e');
    }
  }
}






