import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import '../services/user_model.dart';
import '../widgets/app_navbar.dart';
import '../widgets/app_drawer.dart';
import '../widgets/app_logo.dart';
import '../services/theme_notifier.dart';
import '../theme/app_colors.dart';
import 'home_screen.dart';
import 'robot_map_screen.dart';
import 'emergency_screen.dart';
import 'profile_screen.dart';
import 'settings_screen.dart';
import 'login_screen.dart';

/// Shell principal de l'application après connexion.
/// Contient la navbar et switche entre les écrans.
class MainShell extends StatefulWidget {
  const MainShell({super.key});

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  // Garder les pages en vie (ne pas reconstruire à chaque switch)
  late final List<Widget> _pages;

  @override
  void initState() {
    super.initState();
    _pages = const [
      HomeScreen(),         // home
      RobotMapScreen(),     // map
      EmergencyScreen(),    // alert
      ProfileScreen(),      // profile
      SettingsScreen(),     // settings
    ];
    // Écouter le navNotifier pour re-render quand la tab change
    navNotifier.addListener(_onNavChange);
  }

  @override
  void dispose() {
    navNotifier.removeListener(_onNavChange);
    super.dispose();
  }

  void _onNavChange() {
    setState(() {});
  }

  void _onNavTap(NavTab tab) {
    navNotifier.goTo(tab);
  }

  int get _pageIndex => NavTab.values.indexOf(navNotifier.current);

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final user = authService.currentUser;

    if (user == null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const LoginScreen()),
        );
      });
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      drawer: const AppDrawer(),
      appBar: _buildAppBar(context, isDark, user),
      // IndexedStack garde toutes les pages en mémoire
      body: IndexedStack(
        index: _pageIndex,
        children: _pages,
      ),
      // La navbar est dans le bottomNavigationBar pour qu'elle
      // reste visible même quand on scroll dans les pages
      bottomNavigationBar: AppNavBar(
        currentTab: navNotifier.current,
        onTap: _onNavTap,
        alertCount: navNotifier.alertCount,
      ),
    );
  }

  PreferredSizeWidget _buildAppBar(
      BuildContext context, bool isDark, AppUser user) {
    return AppBar(
      title: Row(
        children: const [
          AppLogo(size: 26, variant: LogoVariant.transparent),
          SizedBox(width: 8),
          Flexible(
            child: Text(
              "Smart Fire Robot",
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
      actions: [
        // Badge alerte rapide dans l'AppBar
        ListenableBuilder(
          listenable: navNotifier,
          builder: (context, _) {
            if (navNotifier.alertCount == 0) return const SizedBox.shrink();
            return GestureDetector(
              onTap: () => _onNavTap(NavTab.alert),
              child: Container(
                margin: const EdgeInsets.only(right: 4),
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
                decoration: BoxDecoration(
                  color: AppColors.redAlert.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppColors.redAlert.withOpacity(0.4)),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.warning_rounded,
                        color: AppColors.redAlert, size: 14),
                    const SizedBox(width: 4),
                    Text(
                      "${navNotifier.alertCount}",
                      style: const TextStyle(
                        color: AppColors.redAlert,
                        fontWeight: FontWeight.w800,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
        // Toggle thème — IconButton pour un meilleur tap target sur mobile
        IconButton(
          onPressed: () => themeNotifier.toggle(),
          icon: Icon(
            isDark ? Icons.wb_sunny_rounded : Icons.nightlight_round,
            color: isDark ? AppColors.orange : AppColors.red,
            size: 20,
          ),
          style: IconButton.styleFrom(
            backgroundColor: (isDark ? AppColors.card : AppColors.cardLight)
                .withOpacity(0.6),
            side: BorderSide(color: AppColors.orange.withOpacity(0.3)),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        ),
        const SizedBox(width: 4),
      ],
    );
  }
}