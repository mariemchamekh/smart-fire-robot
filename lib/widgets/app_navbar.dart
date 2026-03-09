import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

// ── Enum des onglets ──────────────────────────────────────────────────────────
enum NavTab { home, map, alert, profile, settings }

// ── Notifier global pour synchroniser la navbar partout ──────────────────────
class NavNotifier extends ChangeNotifier {
  NavTab _current = NavTab.home;
  int _alertCount = 3; // 🔜 sera mis à jour par MQTT/robot

  NavTab get current => _current;
  int get alertCount => _alertCount;

  void goTo(NavTab tab) {
    if (_current == tab) return;
    _current = tab;
    notifyListeners();
  }

  void setAlertCount(int count) {
    _alertCount = count;
    notifyListeners();
  }
}

final navNotifier = NavNotifier();

// ── Widget principal ─────────────────────────────────────────────────────────
class AppNavBar extends StatefulWidget {
  final NavTab currentTab;
  final Function(NavTab) onTap;
  final int alertCount;

  const AppNavBar({
    super.key,
    required this.currentTab,
    required this.onTap,
    this.alertCount = 0,
  });

  @override
  State<AppNavBar> createState() => _AppNavBarState();
}

class _AppNavBarState extends State<AppNavBar> with TickerProviderStateMixin {
  late Map<NavTab, AnimationController> _controllers;
  late Map<NavTab, Animation<double>> _scaleAnims;

  final List<_NavItem> _items = const [
    _NavItem(tab: NavTab.home,     icon: Icons.home_rounded,              label: "Home"),
    _NavItem(tab: NavTab.map,      icon: Icons.map_rounded,               label: "Map"),
    _NavItem(tab: NavTab.alert,    icon: Icons.notifications_rounded,     label: "Alertes",  hasAlert: true),
    _NavItem(tab: NavTab.profile,  icon: Icons.person_rounded,            label: "Profil"),
    _NavItem(tab: NavTab.settings, icon: Icons.settings_rounded,          label: "Paramètres"),
  ];

  @override
  void initState() {
    super.initState();
    _controllers = {
      for (final item in _items)
        item.tab: AnimationController(
          vsync: this,
          duration: const Duration(milliseconds: 250),
        )
    };
    _scaleAnims = {
      for (final entry in _controllers.entries)
        entry.key: Tween<double>(begin: 1.0, end: 1.25).animate(
          CurvedAnimation(parent: entry.value, curve: Curves.elasticOut),
        )
    };

    // Lancer l'animation du tab actif au démarrage
    _controllers[widget.currentTab]?.forward();
  }

  @override
  void didUpdateWidget(AppNavBar old) {
    super.didUpdateWidget(old);
    if (old.currentTab != widget.currentTab) {
      _controllers[old.currentTab]?.reverse();
      _controllers[widget.currentTab]?.forward();
    }
  }

  @override
  void dispose() {
    for (final c in _controllers.values) c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bg     = isDark ? AppColors.bg2   : AppColors.cardLight;
    final border = isDark
        ? AppColors.red.withOpacity(0.18)
        : AppColors.red.withOpacity(0.12);

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: border, width: 1),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(isDark ? 0.4 : 0.1),
            blurRadius: 24,
            offset: const Offset(0, 8),
          ),
          BoxShadow(
            color: AppColors.red.withOpacity(0.06),
            blurRadius: 12,
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 8),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: _items.map((item) => _buildItem(item, isDark)).toList(),
        ),
      ),
    );
  }

  Widget _buildItem(_NavItem item, bool isDark) {
    final isActive = widget.currentTab == item.tab;
    final activeColor = item.tab == NavTab.alert
        ? AppColors.redAlert
        : AppColors.orange;
    final inactiveColor = isDark
        ? AppColors.subText
        : AppColors.subTextLight;
    final color = isActive ? activeColor : inactiveColor;

    return GestureDetector(
      onTap: () => widget.onTap(item.tab),
      behavior: HitTestBehavior.opaque,
      child: AnimatedBuilder(
        animation: _scaleAnims[item.tab]!,
        builder: (context, child) => Transform.scale(
          scale: isActive ? _scaleAnims[item.tab]!.value : 1.0,
          child: child,
        ),
        child: SizedBox(
          width: 58,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Icône avec fond actif + badge
              Stack(
                clipBehavior: Clip.none,
                children: [
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 250),
                    padding: const EdgeInsets.all(9),
                    decoration: BoxDecoration(
                      color: isActive
                          ? activeColor.withOpacity(0.15)
                          : Colors.transparent,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Icon(item.icon, color: color, size: 22),
                  ),
                  // Badge notification
                  if (item.hasAlert && widget.alertCount > 0)
                    Positioned(
                      top: -2,
                      right: -2,
                      child: _buildBadge(widget.alertCount),
                    ),
                ],
              ),
              const SizedBox(height: 2),
              // Label animé
              AnimatedDefaultTextStyle(
                duration: const Duration(milliseconds: 200),
                style: TextStyle(
                  color: color,
                  fontSize: isActive ? 10 : 9,
                  fontWeight: isActive ? FontWeight.w800 : FontWeight.w500,
                  letterSpacing: 0.2,
                ),
                child: Text(item.label, overflow: TextOverflow.ellipsis),
              ),
              // Indicateur actif (point)
              const SizedBox(height: 3),
              AnimatedContainer(
                duration: const Duration(milliseconds: 250),
                width: isActive ? 18 : 0,
                height: 3,
                decoration: BoxDecoration(
                  color: activeColor,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBadge(int count) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
      decoration: BoxDecoration(
        color: AppColors.redAlert,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.white, width: 1.5),
        boxShadow: [
          BoxShadow(
            color: AppColors.redAlert.withOpacity(0.4),
            blurRadius: 6,
          ),
        ],
      ),
      child: Text(
        count > 9 ? "9+" : "$count",
        style: const TextStyle(
          color: Colors.white,
          fontSize: 9,
          fontWeight: FontWeight.w900,
        ),
      ),
    );
  }
}

// ── Modèle interne ────────────────────────────────────────────────────────────
class _NavItem {
  final NavTab tab;
  final IconData icon;
  final String label;
  final bool hasAlert;

  const _NavItem({
    required this.tab,
    required this.icon,
    required this.label,
    this.hasAlert = false,
  });
}