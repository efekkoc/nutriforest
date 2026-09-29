import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:provider/provider.dart';
import 'providers/ai_scan_provider.dart';
import 'providers/calorie_provider.dart';
import 'providers/settings_provider.dart';
import 'screens/forest_screen.dart';
import 'screens/home_screen.dart';
import 'screens/settings_screen.dart';
import 'services/storage_service.dart';
import 'theme/app_theme.dart';
import 'widgets/glass_card.dart';

import 'widgets/bouncy_button.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize date formatting for Turkish locale (Web & Mobile)
  await initializeDateFormatting('tr_TR', null);

  // Set immersive dark UI overlay for iOS & Android
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarBrightness: Brightness.dark,
      statusBarIconBrightness: Brightness.light,
      systemNavigationBarColor: AppColors.background,
      systemNavigationBarIconBrightness: Brightness.light,
    ),
  );
  SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);

  // Initialize local database
  await StorageService.instance.init();

  runApp(const NutriForestApp());
}

class NutriForestApp extends StatelessWidget {
  const NutriForestApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => SettingsProvider()),
        ChangeNotifierProvider(create: (_) => CalorieProvider()),
        ChangeNotifierProvider(create: (_) => AiScanProvider()),
      ],
      child: MaterialApp(
        title: 'NutriForest - AI Calorie Tracker',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.darkTheme,
        home: const MainNavigationScaffold(),
      ),
    );
  }
}

class MainNavigationScaffold extends StatefulWidget {
  const MainNavigationScaffold({super.key});

  @override
  State<MainNavigationScaffold> createState() => _MainNavigationScaffoldState();
}

class _MainNavigationScaffoldState extends State<MainNavigationScaffold> {
  int _currentIndex = 0;
  bool _handledInitialAction = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _handleIncomingUrlAction());
  }

  void _handleIncomingUrlAction() {
    if (_handledInitialAction || !mounted) return;
    _handledInitialAction = true;

    try {
      final uri = Uri.base;
      final action = (uri.queryParameters['action'] ?? uri.fragment).toLowerCase();

      if (action.contains('scan') || action.contains('camera') || action.contains('tara')) {
        setState(() => _currentIndex = 0);
        HomeScreen.openScanModal(context);
      } else if (action.contains('text') || action.contains('yaz')) {
        setState(() => _currentIndex = 0);
        HomeScreen.openTextModal(context);
      } else if (action.contains('forest') || action.contains('orman')) {
        setState(() => _currentIndex = 1);
      } else if (action.contains('settings') || action.contains('ayar')) {
        setState(() => _currentIndex = 2);
      }
    } catch (_) {}
  }

  void _onNavTap(int index) {
    if (_currentIndex == index) return;
    setState(() => _currentIndex = index);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: IndexedStack(
        index: _currentIndex,
        children: const [
          RepaintBoundary(child: HomeScreen()),
          RepaintBoundary(child: ForestScreen()),
          RepaintBoundary(child: SettingsScreen()),
        ],
      ),
      bottomNavigationBar: _buildGlassBottomNav(),
    );
  }

  Widget _buildGlassBottomNav() {
    return SafeArea(
      child: Container(
        margin: const EdgeInsets.only(left: 24, right: 24, bottom: 12),
        child: GlassCard(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          borderRadius: 28,
          backgroundColor: AppColors.surface.withAlpha(210),
          blurSigma: 20,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _NavItem(
                icon: Icons.eco_outlined,
                activeIcon: Icons.eco,
                label: 'Günlük',
                isSelected: _currentIndex == 0,
                onTap: () => _onNavTap(0),
              ),
              _NavItem(
                icon: Icons.forest_outlined,
                activeIcon: Icons.forest,
                label: '30 Günlük Orman',
                isSelected: _currentIndex == 1,
                onTap: () => _onNavTap(1),
              ),
              _NavItem(
                icon: Icons.tune_outlined,
                activeIcon: Icons.tune,
                label: 'Ayarlar',
                isSelected: _currentIndex == 2,
                onTap: () => _onNavTap(2),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  final IconData icon;
  final IconData activeIcon;
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _NavItem({
    required this.icon,
    required this.activeIcon,
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return BouncyButton(
      scaleFactor: 0.90,
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary.withAlpha(30) : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              isSelected ? activeIcon : icon,
              size: 22,
              color: isSelected ? AppColors.primary : AppColors.textSecondary,
            ),
            if (isSelected) ...[
              const SizedBox(width: 6),
              Text(
                label,
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: AppColors.primary,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
