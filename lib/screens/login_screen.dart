import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import '../services/theme_notifier.dart';
import '../widgets/app_logo.dart';
import '../theme/app_colors.dart';
import 'sign_up_screen.dart';
import 'main_shell.dart'; // ← pointe vers MainShell (pas HomeScreen)

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen>
    with SingleTickerProviderStateMixin {
  final _emailCtrl = TextEditingController();
  final _passCtrl  = TextEditingController();
  bool _obscurePass      = true;
  bool _isLoading        = false;
  bool _checkingSession  = true;
  String? _errorMsg;

  late AnimationController _animCtrl;
  late Animation<double> _fadeAnim;
  late Animation<Offset> _slideAnim;

  @override
  void initState() {
    super.initState();
    _animCtrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 700));
    _fadeAnim  = CurvedAnimation(parent: _animCtrl, curve: Curves.easeOut);
    _slideAnim = Tween<Offset>(begin: const Offset(0, 0.08), end: Offset.zero)
        .animate(CurvedAnimation(parent: _animCtrl, curve: Curves.easeOut));
    _checkSession();
  }

  Future<void> _checkSession() async {
    final user = await authService.checkCurrentSession();
    if (!mounted) return;
    if (user != null) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const MainShell()),
      );
    } else {
      setState(() => _checkingSession = false);
      _animCtrl.forward();
    }
  }

  @override
  void dispose() {
    _animCtrl.dispose();
    _emailCtrl.dispose();
    _passCtrl.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    setState(() { _isLoading = true; _errorMsg = null; });
    final result = await authService.login(_emailCtrl.text, _passCtrl.text);
    if (!mounted) return;
    setState(() => _isLoading = false);
    if (result.success) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const MainShell()),
      );
    } else {
      setState(() => _errorMsg = result.error);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_checkingSession) return _buildSplash();

    final isDark    = Theme.of(context).brightness == Brightness.dark;
    final bgColor   = isDark ? AppColors.bg    : AppColors.bgLight;
    final cardColor = isDark ? AppColors.card  : AppColors.cardLight;
    final textColor = isDark ? AppColors.text  : AppColors.textLight;
    final subColor  = isDark ? AppColors.subText : AppColors.subTextLight;
    final fillColor = isDark ? AppColors.card2 : AppColors.card2Light;

    return Scaffold(
      body: Stack(
        children: [
          const Positioned.fill(
            child: Image(
              image: AssetImage("assets/images/firetree.jpg"),
              fit: BoxFit.cover,
              opacity: AlwaysStoppedAnimation(0.2),
            ),
          ),
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    bgColor.withOpacity(0.98),
                    bgColor.withOpacity(0.88),
                    bgColor.withOpacity(0.5),
                  ],
                  begin: Alignment.bottomCenter,
                  end: Alignment.topCenter,
                ),
              ),
            ),
          ),
          SafeArea(
            child: Align(
              alignment: Alignment.topRight,
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: GestureDetector(
                  onTap: () => themeNotifier.toggle(),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    decoration: BoxDecoration(
                      color: cardColor.withOpacity(0.8),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: AppColors.orange.withOpacity(0.4)),
                    ),
                    child: Icon(
                      isDark ? Icons.wb_sunny_rounded : Icons.nightlight_round,
                      color: isDark ? AppColors.orange : AppColors.red,
                      size: 18,
                    ),
                  ),
                ),
              ),
            ),
          ),
          SafeArea(
            child: Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 20),
                child: FadeTransition(
                  opacity: _fadeAnim,
                  child: SlideTransition(
                    position: _slideAnim,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const AppLogo(size: 80, variant: LogoVariant.transparent),
                        const SizedBox(height: 16),
                        Text("Smart Fire Robot",
                            style: TextStyle(fontSize: 22, fontWeight: FontWeight.w900, color: textColor)),
                        const SizedBox(height: 4),
                        Text("Connectez-vous pour continuer",
                            style: TextStyle(color: subColor, fontSize: 13)),
                        const SizedBox(height: 36),
                        Container(
                          padding: const EdgeInsets.all(24),
                          decoration: BoxDecoration(
                            color: cardColor,
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(color: AppColors.red.withOpacity(0.2)),
                            boxShadow: [BoxShadow(color: AppColors.red.withOpacity(0.08), blurRadius: 20, offset: const Offset(0, 6))],
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text("Connexion",
                                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.w900, color: textColor)),
                              const SizedBox(height: 20),
                              _label("Email", subColor),
                              const SizedBox(height: 6),
                              _field(controller: _emailCtrl, hint: "votre@email.com",
                                  icon: Icons.email_outlined, fill: fillColor,
                                  text: textColor, sub: subColor,
                                  keyboard: TextInputType.emailAddress),
                              const SizedBox(height: 16),
                              _label("Mot de passe", subColor),
                              const SizedBox(height: 6),
                              _field(
                                controller: _passCtrl, hint: "••••••••",
                                icon: Icons.lock_outline_rounded, fill: fillColor,
                                text: textColor, sub: subColor, obscure: _obscurePass,
                                suffix: IconButton(
                                  icon: Icon(_obscurePass ? Icons.visibility_outlined : Icons.visibility_off_outlined,
                                      color: subColor, size: 20),
                                  onPressed: () => setState(() => _obscurePass = !_obscurePass),
                                ),
                              ),
                              if (_errorMsg != null) ...[
                                const SizedBox(height: 14),
                                _errorWidget(_errorMsg!),
                              ],
                              const SizedBox(height: 24),
                              SizedBox(
                                width: double.infinity,
                                child: ElevatedButton(
                                  onPressed: _isLoading ? null : _login,
                                  style: ElevatedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 16)),
                                  child: _isLoading
                                      ? const SizedBox(height: 20, width: 20,
                                      child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2.5))
                                      : const Text("Se connecter",
                                      style: TextStyle(fontSize: 15, fontWeight: FontWeight.w800)),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 20),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text("Pas encore de compte ? ", style: TextStyle(color: subColor, fontSize: 13)),
                            GestureDetector(
                              onTap: () => Navigator.push(context,
                                  MaterialPageRoute(builder: (_) => const SignUpScreen())),
                              child: Text("S'inscrire",
                                  style: TextStyle(color: AppColors.orange, fontWeight: FontWeight.w800, fontSize: 13)),
                            ),
                          ],
                        ),
                        const SizedBox(height: 20),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSplash() => Scaffold(
    backgroundColor: AppColors.bg,
    body: Stack(
      children: [
        const Positioned.fill(
          child: Image(image: AssetImage("assets/images/firetree.jpg"),
              fit: BoxFit.cover, opacity: AlwaysStoppedAnimation(0.2)),
        ),
        Center(
          child: Column(mainAxisSize: MainAxisSize.min, children: const [
            AppLogo(size: 80, variant: LogoVariant.transparent),
            SizedBox(height: 24),
            SizedBox(width: 28, height: 28,
                child: CircularProgressIndicator(color: AppColors.orange, strokeWidth: 2.5)),
          ]),
        ),
      ],
    ),
  );

  Widget _label(String t, Color c) => Text(t,
      style: TextStyle(color: c, fontSize: 12, fontWeight: FontWeight.w600, letterSpacing: 0.8));

  Widget _field({
    required TextEditingController controller, required String hint,
    required IconData icon, required Color fill, required Color text,
    required Color sub, bool obscure = false, Widget? suffix, TextInputType? keyboard,
  }) => TextField(
    controller: controller, obscureText: obscure, keyboardType: keyboard,
    style: TextStyle(color: text, fontSize: 14),
    decoration: InputDecoration(
      hintText: hint, hintStyle: TextStyle(color: sub.withOpacity(0.6)),
      filled: true, fillColor: fill,
      prefixIcon: Icon(icon, color: sub, size: 20), suffixIcon: suffix,
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
      focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: AppColors.orange.withOpacity(0.6), width: 1.5)),
      contentPadding: const EdgeInsets.symmetric(vertical: 14, horizontal: 14),
    ),
  );

  Widget _errorWidget(String msg) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
    decoration: BoxDecoration(
      color: AppColors.redAlert.withOpacity(0.1), borderRadius: BorderRadius.circular(10),
      border: Border.all(color: AppColors.redAlert.withOpacity(0.4)),
    ),
    child: Row(children: [
      const Icon(Icons.error_outline_rounded, color: AppColors.redAlert, size: 16),
      const SizedBox(width: 8),
      Expanded(child: Text(msg, style: const TextStyle(color: AppColors.redAlert, fontSize: 13))),
    ]),
  );
}