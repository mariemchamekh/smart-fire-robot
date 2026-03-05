import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'user_model.dart';

/// Résultat d'une opération d'authentification
class AuthResult {
  final bool success;
  final String? error;
  final AppUser? user;

  const AuthResult.success(this.user)
      : success = true,
        error = null;

  const AuthResult.failure(this.error)
      : success = false,
        user = null;
}

/// Service d'authentification Firebase.
/// Remplace l'ancienne version en mémoire.
class AuthService {
  AuthService._();
  static final AuthService instance = AuthService._();

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // ── Utilisateur connecté actuellement ─────────────────────
  AppUser? _currentUser;
  AppUser? get currentUser => _currentUser;
  bool get isLoggedIn => _currentUser != null;

  // ── Permissions ───────────────────────────────────────────
  bool get canAccessAdmin    => _currentUser?.isAdmin ?? false;
  bool get canAccessCamera   => _currentUser != null;
  bool get canAccessEmergency => _currentUser != null;
  bool get canAccessMap      => _currentUser != null;

  // ── Vérifier session existante au démarrage ───────────────
  /// À appeler dans main.dart ou LoginScreen pour auto-login
  Future<AppUser?> checkCurrentSession() async {
    final firebaseUser = _auth.currentUser;
    if (firebaseUser == null) return null;

    try {
      final doc = await _db.collection('users').doc(firebaseUser.uid).get();
      if (!doc.exists) return null;
      _currentUser = AppUser.fromFirestore(firebaseUser.uid, doc.data()!);
      return _currentUser;
    } catch (_) {
      return null;
    }
  }

  // ── LOGIN ──────────────────────────────────────────────────
  Future<AuthResult> login(String email, String password) async {
    final trimmedEmail = email.trim().toLowerCase();
    final trimmedPass = password.trim();

    if (trimmedEmail.isEmpty || trimmedPass.isEmpty) {
      return const AuthResult.failure("Veuillez remplir tous les champs.");
    }

    try {
      // 1. Connexion Firebase Auth
      final credential = await _auth.signInWithEmailAndPassword(
        email: trimmedEmail,
        password: trimmedPass,
      );

      final uid = credential.user!.uid;

      // 2. Récupérer le profil depuis Firestore
      final doc = await _db.collection('users').doc(uid).get();

      if (!doc.exists) {
        await _auth.signOut();
        return const AuthResult.failure("Profil utilisateur introuvable.");
      }

      _currentUser = AppUser.fromFirestore(uid, doc.data()!);
      return AuthResult.success(_currentUser);

    } on FirebaseAuthException catch (e) {
      return AuthResult.failure(_mapFirebaseError(e.code));
    } catch (e) {
      return AuthResult.failure("Erreur inattendue. Réessayez.");
    }
  }

  // ── SIGN UP ────────────────────────────────────────────────
  Future<AuthResult> signUp({
    required String name,
    required String email,
    required String password,
    required String confirmPassword,
    UserRole role = UserRole.owner,
  }) async {
    final trimmedName  = name.trim();
    final trimmedEmail = email.trim().toLowerCase();
    final trimmedPass  = password.trim();

    // Validations locales (rapides, avant appel Firebase)
    if (trimmedName.isEmpty || trimmedEmail.isEmpty || trimmedPass.isEmpty) {
      return const AuthResult.failure("Veuillez remplir tous les champs.");
    }
    if (trimmedName.length < 2) {
      return const AuthResult.failure("Le nom doit contenir au moins 2 caractères.");
    }
    if (!trimmedEmail.contains('@') || !trimmedEmail.contains('.')) {
      return const AuthResult.failure("Adresse email invalide.");
    }
    if (trimmedPass.length < 6) {
      return const AuthResult.failure("Le mot de passe doit contenir au moins 6 caractères.");
    }
    if (password != confirmPassword) {
      return const AuthResult.failure("Les mots de passe ne correspondent pas.");
    }

    try {
      // 1. Créer le compte Firebase Auth
      final credential = await _auth.createUserWithEmailAndPassword(
        email: trimmedEmail,
        password: trimmedPass,
      );

      final uid = credential.user!.uid;

      // 2. Créer le profil dans Firestore
      final newUser = AppUser(
        id: uid,
        name: trimmedName,
        email: trimmedEmail,
        role: role,
      );

      await _db.collection('users').doc(uid).set(newUser.toFirestore());

      _currentUser = newUser;
      return AuthResult.success(_currentUser);

    } on FirebaseAuthException catch (e) {
      return AuthResult.failure(_mapFirebaseError(e.code));
    } catch (e) {
      return AuthResult.failure("Erreur inattendue. Réessayez.");
    }
  }

  // ── LOGOUT ─────────────────────────────────────────────────
  Future<void> logout() async {
    await _auth.signOut();
    _currentUser = null;
  }

  // ── Traduction des erreurs Firebase ───────────────────────
  String _mapFirebaseError(String code) {
    switch (code) {
      case 'user-not-found':
        return "Aucun compte trouvé avec cet email.";
      case 'wrong-password':
        return "Mot de passe incorrect.";
      case 'invalid-credential':
        return "Email ou mot de passe incorrect.";
      case 'email-already-in-use':
        return "Cet email est déjà utilisé.";
      case 'weak-password':
        return "Le mot de passe est trop faible (min. 6 caractères).";
      case 'invalid-email':
        return "Adresse email invalide.";
      case 'too-many-requests':
        return "Trop de tentatives. Réessayez plus tard.";
      case 'network-request-failed':
        return "Pas de connexion internet.";
      case 'user-disabled':
        return "Ce compte a été désactivé.";
      default:
        return "Erreur : $code";
    }
  }
}

// Instance globale accessible partout
final authService = AuthService.instance;