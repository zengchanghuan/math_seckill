import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../core/models/user_stats.dart';
import '../../drill/controllers/drill_controller.dart';

class ProfileController extends GetxController {
  final Rx<UserStats> userStats = UserStats().obs;
  final RxBool isDarkMode = false.obs;
  final RxDouble fontSize = 16.0.obs;

  @override
  void onInit() {
    super.onInit();
    loadSettings();
    loadUserStats();
  }

  Future<void> loadUserStats() async {
    try {
      final drillController = Get.find<DrillController>();
      userStats.value = drillController.userStats.value;
    } catch (e) {
      print('Error loading user stats: $e');
    }
  }

  Future<void> loadSettings() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      isDarkMode.value = prefs.getBool('is_dark_mode') ?? false;
      fontSize.value = prefs.getDouble('font_size') ?? 16.0;
    } catch (e) {
      print('Error loading settings: $e');
    }
  }

  Future<void> toggleDarkMode() async {
    isDarkMode.value = !isDarkMode.value;
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('is_dark_mode', isDarkMode.value);
      Get.changeThemeMode(
        isDarkMode.value ? ThemeMode.dark : ThemeMode.light,
      );
    } catch (e) {
      print('Error saving dark mode setting: $e');
    }
  }

  Future<void> setFontSize(double size) async {
    fontSize.value = size;
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setDouble('font_size', size);
    } catch (e) {
      print('Error saving font size: $e');
    }
  }

  void refreshStats() {
    loadUserStats();
  }
}
