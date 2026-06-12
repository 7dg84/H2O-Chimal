import 'package:app/providers/navigation_provider.dart';
import 'package:app/providers/report_provider.dart';
import 'package:app/providers/service_provider.dart';
import 'package:app/providers/tramite_provider.dart';
import 'package:app/services/report_service.dart';
import 'package:app/services/service_service.dart';
import 'package:app/services/tramite_service.dart';
import 'package:flutter/material.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:provider/provider.dart';
import 'core/config.dart';
import 'models/report_model.dart';
import 'models/service_model.dart';
import 'providers/auth_provider.dart';
import 'services/api_service.dart';
import 'services/auth_service.dart';
import 'ui/screens/welcome_screen.dart';
import 'ui/screens/home_screen.dart';
import 'ui/screens/login_screen.dart';
import 'ui/screens/register_screen.dart';
import 'ui/screens/map_screen.dart';
import 'ui/screens/services_screen.dart';
import 'ui/screens/profile_screen.dart';
import 'ui/screens/report_form_screen.dart';
import 'ui/screens/report_detail_screen.dart';
import 'ui/screens/report_edit_screen.dart';
import 'ui/screens/tramite_form_screen.dart';
import 'ui/screens/tramite_detail_screen.dart';
import 'ui/screens/edit_profile_screen.dart';

Future<void> main() async  {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeDateFormatting('es', null);
  final apiService = ApiService();
  final authService = AuthService(apiService);
  final reportService = ReportService(apiService);
  final tramiteService = TramiteService(apiService);
  final serviceService = ServiceService(apiService);

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider(authService)),
        ChangeNotifierProvider(create: (_) => NavigationProvider()),
        ChangeNotifierProvider(create: (_) => ReportProvider(reportService)),
        ChangeNotifierProvider(create: (_) => TramiteProvider(tramiteService)),
        ChangeNotifierProvider(create: (_) => ServiceProvider(serviceService)),

      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'H2O Chimal',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: AppConfig.primaryBlue,
          primary: AppConfig.primaryBlue,
          secondary: AppConfig.secondaryAzure,
        ),
        useMaterial3: true,
        scaffoldBackgroundColor: AppConfig.backgroundGray,
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.white,
          foregroundColor: AppConfig.primaryBlue,
          elevation: 0,
          centerTitle: false,
          titleTextStyle: TextStyle(
            color: AppConfig.primaryBlue,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: AppConfig.primaryBlue,
            foregroundColor: Colors.white,
            minimumSize: const Size(double.infinity, 50),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: Colors.white,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: const BorderSide(color: AppConfig.cardBorder),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: const BorderSide(color: AppConfig.cardBorder),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: const BorderSide(color: AppConfig.primaryBlue, width: 2),
          ),
        ),
      ),
      home: Consumer<AuthProvider>(
        builder: (context, auth, _) {
          if (auth.isLoading) {
            return const Scaffold(
              body: Center(child: CircularProgressIndicator()),
            );
          }
          return auth.isAuthenticated ? const MainNavigation() : const WelcomeScreen();
        },
      ),
      onGenerateRoute: (settings) {
        if (settings.name == '/report-detail') {
          final reportId = settings.arguments as String;
          return MaterialPageRoute(
            builder: (context) => ReportDetailScreen(reportId: reportId),
          );
        }
        if (settings.name == '/report-edit') {
          final report = settings.arguments as ReportModel;
          return MaterialPageRoute(
            builder: (context) => ReportEditScreen(report: report),
          );
        }
        if (settings.name == '/tramite-form') {
          final service = settings.arguments as ServiceModel;
          return MaterialPageRoute(
            builder: (context) => TramiteFormScreen(service: service),
          );
        }
        if (settings.name == '/tramite-detail') {
          final tramiteId = settings.arguments as String;
          return MaterialPageRoute(
            builder: (context) => TramiteDetailScreen(tramiteId: tramiteId),
          );
        }
        return null;
      },
      routes: {
        '/login': (context) => const LoginScreen(),
        '/register': (context) => const RegisterScreen(),
        '/report-fuga': (context) => const ReportFormScreen(),
        '/edit-profile': (context) => const EditProfileScreen(),
      },
    );
  }
}

class MainNavigation extends StatefulWidget {
  const MainNavigation({super.key});

  @override
  State<MainNavigation> createState() => _MainNavigationState();
}

class _MainNavigationState extends State<MainNavigation> {
  final List<Widget> _screens = [
    const HomeScreen(),
    const MapScreen(),
    const ServicesScreen(),
    const ProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    final navProvider = context.watch<NavigationProvider>();
    return Scaffold(
      body: IndexedStack(
        index: navProvider.selectedIndex,
        children: _screens,
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: navProvider.selectedIndex,
        onTap: (index) => navProvider.setIndex(index),
        type: BottomNavigationBarType.fixed,
        selectedItemColor: AppConfig.secondaryAzure,
        unselectedItemColor: Colors.grey,
        showUnselectedLabels: true,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home_outlined), activeIcon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.map_outlined), activeIcon: Icon(Icons.map), label: 'Mapa'),
          BottomNavigationBarItem(icon: Icon(Icons.plumbing_outlined), activeIcon: Icon(Icons.plumbing), label: 'Servicios'),
          BottomNavigationBarItem(icon: Icon(Icons.person_outline), activeIcon: Icon(Icons.person), label: 'Usuario'),
        ],
      ),
    );
  }
}
