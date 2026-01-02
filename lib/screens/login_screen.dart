import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'home_screen.dart';
import 'signup_screen.dart';
import '../theme/colors.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _loading = false;

  Future<void> _handleLogin() async {
    setState(() => _loading = true);
    try {
      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );
      if (mounted) {
        Navigator.pushReplacement(
          context, MaterialPageRoute(builder: (_) => const HomeScreen())
        );
      }
    } on FirebaseAuthException catch (e) {
      setState(() => _loading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.message ?? "Login Failed"))
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFDE8E8),
      body: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset('assets/images/abhaya_logo.png', width: 140),
            const SizedBox(height: 30),
            TextField(controller: _emailController, decoration: const InputDecoration(labelText: "Email")),
            TextField(controller: _passwordController, obscureText: true, decoration: const InputDecoration(labelText: "Password")),
            const SizedBox(height: 30),
            if (_loading) const CircularProgressIndicator() 
            else SizedBox(
              width: double.infinity, height: 50,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: AppColors.softRed, shape: const StadiumBorder()),
                onPressed: _handleLogin,
                child: const Text("Log In", style: TextStyle(color: Colors.white)),
              ),
            ),
            TextButton(
              onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const SignupScreen())),
              child: const Text("Don't have an account? Sign Up"),
            )
          ],
        ),
      ),
    );
  }
}



