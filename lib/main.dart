import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'core/services/api_service.dart';
import 'core/services/problem_service.dart';
import 'core/services/storage_service.dart';
import 'core/services/config_service.dart';
import 'features/drill/controllers/drill_controller.dart';
import 'features/profile/controllers/profile_controller.dart';
import 'features/recommendation/controllers/recommend_controller.dart';
import 'features/home/views/home_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // 初始化服务
  await initServices();

  runApp(const MyApp());
}

/// 初始化所有服务
Future<void> initServices() async {
  // 初始化存储服务
  await Get.putAsync(() => StorageService().init());

  // 初始化其他服务
  Get.put(ApiService());
  Get.put(ProblemService());

  // 初始化配置服务（会自动从服务器同步配置）
  Get.put(ConfigService());

  // 初始化控制器
  Get.put(DrillController());
  Get.put(ProfileController());
  Get.put(RecommendController());

  // 从存储中恢复设置
  final storage = Get.find<StorageService>();
  final api = Get.find<ApiService>();

  final savedStudentId = storage.getStudentId();
  if (savedStudentId != null) {
    api.setStudentId(savedStudentId);
  }

  final savedServerUrl = storage.getServerUrl();
  api.setServerUrl(savedServerUrl);
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: '数学秒杀',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true,
        appBarTheme: const AppBarTheme(
          centerTitle: true,
          elevation: 0,
        ),
      ),
      darkTheme: ThemeData.dark().copyWith(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.blue,
          brightness: Brightness.dark,
        ),
        useMaterial3: true,
      ),
      themeMode: Get.find<StorageService>().isDarkMode()
          ? ThemeMode.dark
          : ThemeMode.light,
      home: const HomePage(),
      debugShowCheckedModeBanner: false,
    );
  }
}
