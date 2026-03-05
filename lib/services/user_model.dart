enum UserRole { admin, owner }

class AppUser {
  final String id;
  final String name;
  final String email;
  final UserRole role;

  const AppUser({
    required this.id,
    required this.name,
    required this.email,
    required this.role,
  });

  bool get isAdmin => role == UserRole.admin;
  bool get isOwner => role == UserRole.owner;

  String get roleLabel {
    switch (role) {
      case UserRole.admin:  return "Administrateur";
      case UserRole.owner:  return "Propriétaire";
    }
  }

  // ── Conversion depuis Firestore ──────────────────────────
  factory AppUser.fromFirestore(String uid, Map<String, dynamic> data) {
    return AppUser(
      id: uid,
      name: data['name'] ?? '',
      email: data['email'] ?? '',
      role: data['role'] == 'admin' ? UserRole.admin : UserRole.owner,
    );
  }

  // ── Conversion vers Firestore ────────────────────────────
  Map<String, dynamic> toFirestore() {
    return {
      'name': name,
      'email': email,
      'role': role == UserRole.admin ? 'admin' : 'owner',
      'createdAt': DateTime.now().toIso8601String(),
    };
  }
}