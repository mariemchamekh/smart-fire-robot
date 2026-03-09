import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import '../services/theme_notifier.dart';
import '../services/user_model.dart';
import '../widgets/app_logo.dart';
import '../theme/app_colors.dart';
import 'main_shell.dart'; // ← MainShell au lieu de HomeScreen

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen>
    with SingleTickerProviderStateMixin {
  final _nameCtrl    = TextEditingController();
  final _emailCtrl   = TextEditingController();
  final _passCtrl    = TextEditingController();
  final _confirmCtrl = TextEditingController();

  bool _obscurePass    = true;
  bool _obscureConfirm = true;
  bool _isLoading      = false;
  String? _errorMsg;
  UserRole _selectedRole = UserRole.owner;

  late AnimationController _animCtrl;
  late Animation<double> _fadeAnim;
  late Animation<Offset> _slideAnim;

  @override
  void initState() {
    super.initState();
    _animCtrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 700));
    _fadeAnim  = CurvedAnimation(parent: _animCtrl, curve: Curves.easeOut);
    _slideAnim = Tween<Offset>(begin: const Offset(0, 0.08), end: Offset.zero)
        .animate(CurvedAnimation(parent: _animCtrl, curve: Curves.easeOut));
    _animCtrl.forward();
  }

  @override
  void dispose() {
    _animCtrl.dispose();
    _nameCtrl.dispose();
    _emailCtrl.dispose();
    _passCtrl.dispose();
    _confirmCtrl.dispose();
    super.dispose();
  }

  Future<void> _signUp() async {
    setState(() { _isLoading = true; _errorMsg = null; });
    final result = await authService.signUp(
      name: _nameCtrl.text, email: _emailCtrl.text,
      password: _passCtrl.text, confirmPassword: _confirmCtrl.text,
      role: _selectedRole,
    );
    if (!mounted) return;
    setState(() => _isLoading = false);
    if (result.success) {
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (_) => const MainShell()),
            (_) => false,
      );
    } else {
      setState(() => _errorMsg = result.error);
    }
  }

  @override
  Widget build(BuildContext context) {
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
            child: Image(image: AssetImage("assets/images/firetree2.jpg"),
                fit: BoxFit.cover, opacity: AlwaysStoppedAnimation(0.18)),
          ),
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [bgColor.withOpacity(0.98), bgColor.withOpacity(0.88), bgColor.withOpacity(0.5)],
                  begin: Alignment.bottomCenter, end: Alignment.topCenter,
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
                      color: cardColor.withOpacity(0.8), borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: AppColors.orange.withOpacity(0.4)),
                    ),
                    child: Icon(isDark ? Icons.wb_sunny_rounded : Icons.nightlight_round,
                        color: isDark ? AppColors.orange : AppColors.red, size: 18),
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
                        const AppLogo(size: 64, variant: LogoVariant.transparent),
                        const SizedBox(height: 12),
                        Text("Créer un compte",
                            style: TextStyle(fontSize: 22, fontWeight: FontWeight.w900, color: textColor)),
                        const SizedBox(height: 4),
                        Text("Rejoignez Smart Fire Robot",
                            style: TextStyle(color: subColor, fontSize: 13)),
                        const SizedBox(height: 28),
                        Container(
                          padding: const EdgeInsets.all(24),
                          decoration: BoxDecoration(
                            color: cardColor, borderRadius: BorderRadius.circular(20),
                            border: Border.all(color: AppColors.red.withOpacity(0.2)),
                            boxShadow: [BoxShadow(color: AppColors.red.withOpacity(0.07), blurRadius: 20, offset: const Offset(0, 6))],
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text("Inscription",
                                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.w900, color: textColor)),
                              const SizedBox(height: 20),
                              _label("Nom complet", subColor),
                              const SizedBox(height: 6),
                              _field(controller: _nameCtrl, hint: "Votre nom",
                                  icon: Icons.person_outline_rounded, fill: fillColor, text: textColor, sub: subColor),
                              const SizedBox(height: 14),
                              _label("Email", subColor),
                              const SizedBox(height: 6),
                              _field(controller: _emailCtrl, hint: "votre@email.com",
                                  icon: Icons.email_outlined, fill: fillColor, text: textColor, sub: subColor,
                                  keyboard: TextInputType.emailAddress),
                              const SizedBox(height: 14),
                              _label("Rôle", subColor),
                              const SizedBox(height: 8),
                              _roleSelector(textColor, subColor),
                              const SizedBox(height: 14),
                              _label("Mot de passe", subColor),
                              const SizedBox(height: 6),
                              _field(controller: _passCtrl, hint: "Min. 6 caractères",
                                  icon: Icons.lock_outline_rounded, fill: fillColor, text: textColor, sub: subColor,
                                  obscure: _obscurePass,
                                  suffix: IconButton(
                                    icon: Icon(_obscurePass ? Icons.visibility_outlined : Icons.visibility_off_outlined, color: subColor, size: 20),
                                    onPressed: () => setState(() => _obscurePass = !_obscurePass),
                                  )),
                              const SizedBox(height: 14),
                              _label("Confirmer le mot de passe", subColor),
                              const SizedBox(height: 6),
                              _field(controller: _confirmCtrl, hint: "Répétez le mot de passe",
                                  icon: Icons.lock_outline_rounded, fill: fillColor, text: textColor, sub: subColor,
                                  obscure: _obscureConfirm,
                                  suffix: IconButton(
                                    icon: Icon(_obscureConfirm ? Icons.visibility_outlined : Icons.visibility_off_outlined, color: subColor, size: 20),
                                    onPressed: () => setState(() => _obscureConfirm = !_obscureConfirm),
                                  )),
                              if (_errorMsg != null) ...[
                                const SizedBox(height: 14),
                                _errorWidget(_errorMsg!),
                              ],
                              const SizedBox(height: 24),
                              SizedBox(
                                width: double.infinity,
                                child: ElevatedButton(
                                  onPressed: _isLoading ? null : _signUp,
                                  style: ElevatedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 16)),
                                  child: _isLoading
                                      ? const SizedBox(height: 20, width: 20,
                                      child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2.5))
                                      : const Text("Créer mon compte",
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
                            Text("Déjà un compte ? ", style: TextStyle(color: subColor, fontSize: 13)),
                            GestureDetector(
                              onTap: () => Navigator.pop(context),
                              child: Text("Se connecter",
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

  Widget _roleSelector(Color textColor, Color subColor) {
    return Row(
      children: [
        _roleOption(role: UserRole.owner, label: "Propriétaire", subtitle: "Forêt",
            icon: Icons.forest_rounded, textColor: textColor, subColor: subColor),
        const SizedBox(width: 10),
        _roleOption(role: UserRole.admin, label: "Administrateur", subtitle: "Accès complet",
            icon: Icons.admin_panel_settings_outlined, textColor: textColor, subColor: subColor),
      ],
    );
  }

  Widget _roleOption({required UserRole role, required String label, required String subtitle,
    required IconData icon, required Color textColor, required Color subColor}) {
    final isSelected = _selectedRole == role;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _selectedRole = role),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 10),
          decoration: BoxDecoration(
            color: isSelected ? AppColors.red.withOpacity(0.15) : AppColors.card2.withOpacity(0.5),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isSelected ? AppColors.redAlert.withOpacity(0.7) : AppColors.subText.withOpacity(0.2),
              width: isSelected ? 1.5 : 1,
            ),
          ),
          child: Column(children: [
            Icon(icon, color: isSelected ? AppColors.redAlert : subColor, size: 22),
            const SizedBox(height: 6),
            Text(label, style: TextStyle(color: isSelected ? AppColors.redAlert : textColor,
                fontWeight: FontWeight.w700, fontSize: 12), textAlign: TextAlign.center),
            Text(subtitle, style: TextStyle(color: subColor.withOpacity(0.7), fontSize: 10)),
          ]),
        ),
      ),
    );
  }

  Widget _label(String t, Color c) => Text(t,
      style: TextStyle(color: c, fontSize: 12, fontWeight: FontWeight.w600, letterSpacing: 0.8));

  Widget _field({required TextEditingController controller, required String hint,
    required IconData icon, required Color fill, required Color text, required Color sub,
    bool obscure = false, Widget? suffix, TextInputType? keyboard}) =>
      TextField(
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