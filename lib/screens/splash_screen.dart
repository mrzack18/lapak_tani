import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:lapak_tani/providers/auth_provider.dart';
import 'package:lapak_tani/screens/auth/login_screen.dart';
import 'package:lapak_tani/screens/buyer/home_screen.dart';
import 'package:lapak_tani/screens/seller/seller_dashboard_screen.dart';
import 'package:lapak_tani/screens/admin/admin_dashboard_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _checkAuth();
  }

  Future<void> _checkAuth() async {
    await Future.delayed(const Duration(seconds: 2));

    if (!mounted) return;

    final authProvider = context.read<AuthProvider>();
    await authProvider.checkAuth();

    if (!mounted) return;

    if (authProvider.isLoggedIn) {
      Widget nextScreen;
      switch (authProvider.userRole) {
        case 'pembeli':
          nextScreen = const HomeScreen();
          break;
        case 'petani':
          nextScreen = const SellerDashboardScreen();
          break;
        case 'admin':
          nextScreen = const AdminDashboardScreen();
          break;
        default:
          nextScreen = const LoginScreen();
      }
      Navigator.of(
        context,
      ).pushReplacement(MaterialPageRoute(builder: (_) => nextScreen));
    } else {
      Navigator.of(
        context,
      ).pushReplacement(MaterialPageRoute(builder: (_) => const LoginScreen()));
    }
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // ── Logo Modern ──────────────────────────────────────────────
            Icon(Icons.eco_rounded, size: 100, color: Color(0xFF1B8040)),
            SizedBox(height: 24),
            Text(
              'Lapak Tani',
              style: TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.bold,
                color: Color(0xFF1B8040),
                letterSpacing: -0.5,
              ),
            ),
            SizedBox(height: 8),
            Text(
              'Solusi Pertanian Masa Kini',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey,
                letterSpacing: 0.5,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
