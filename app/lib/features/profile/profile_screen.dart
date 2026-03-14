import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  Future<void> _signOut(BuildContext context) async {
    await GoogleSignIn().signOut();
    await FirebaseAuth.instance.signOut();
    if (context.mounted) context.go('/login');
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(title: const Text('Profile'), backgroundColor: AppTheme.background),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            const SizedBox(height: 16),
            // Avatar
            Stack(
              alignment: Alignment.bottomRight,
              children: [
                CircleAvatar(
                  radius: 48,
                  backgroundImage: user?.photoURL != null ? NetworkImage(user!.photoURL!) : null,
                  backgroundColor: AppTheme.yellow,
                  child: user?.photoURL == null
                      ? Text(
                          (user?.displayName?.substring(0, 1) ?? 'U').toUpperCase(),
                          style: const TextStyle(fontSize: 36, color: Colors.black, fontWeight: FontWeight.w800),
                        )
                      : null,
                ),
                Container(
                  padding: const EdgeInsets.all(6),
                  decoration: const BoxDecoration(
                    color: AppTheme.yellow,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.verified_rounded, size: 16, color: Colors.black),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Text(
              user?.displayName ?? 'User',
              style: GoogleFonts.outfit(
                color: AppTheme.textPrimary, fontSize: 24, fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 4),
            Text(
              user?.email ?? '',
              style: GoogleFonts.outfit(color: AppTheme.textSecondary, fontSize: 14),
            ),
            const SizedBox(height: 32),

            // Info tiles
            _InfoTile(icon: Icons.person_outline, label: 'Account', value: 'Google Sign-In'),
            _InfoTile(icon: Icons.security_rounded, label: 'Security', value: 'Firebase Auth'),
            _InfoTile(icon: Icons.storage_rounded, label: 'Data', value: 'Stored on our server'),
            _InfoTile(icon: Icons.info_outline, label: 'Version', value: '1.0.0'),

            const SizedBox(height: 32),
            // Sign out
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () => _signOut(context),
                icon: const Icon(Icons.logout_rounded),
                label: const Text('Sign Out'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red.withOpacity(0.15),
                  foregroundColor: Colors.red,
                  side: const BorderSide(color: Colors.red, width: 1),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _InfoTile extends StatelessWidget {
  final IconData icon;
  final String label, value;
  const _InfoTile({required this.icon, required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.cardDark,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          Icon(icon, color: AppTheme.yellow, size: 20),
          const SizedBox(width: 14),
          Text(label, style: GoogleFonts.outfit(color: AppTheme.textPrimary, fontSize: 14)),
          const Spacer(),
          Text(value, style: GoogleFonts.outfit(color: AppTheme.textSecondary, fontSize: 13)),
        ],
      ),
    );
  }
}
