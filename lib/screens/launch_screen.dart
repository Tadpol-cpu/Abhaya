
import 'package:flutter/material.dart';
import 'login_screen.dart';
import 'signup_screen.dart';
import '../theme/colors.dart';

class LaunchScreen extends StatelessWidget {
  const LaunchScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset('assets/images/abhaya_logo.png', width: 180),
            const SizedBox(height: 10),
            const Text("We don't monetize fear — we make\nplatforms responsible for safety.",
                textAlign: TextAlign.center, style: TextStyle(color: Colors.black54)),
            const SizedBox(height: 50),
            _btn(context, "Log In", AppColors.softRed, Colors.white, const LoginScreen()),
            const SizedBox(height: 15),
            _btn(context, "Sign Up", const Color(0xFFE8FDF5), Colors.black, const SignupScreen()),
          ],
        ),
      ),
    );
  }

  Widget _btn(BuildContext context, String txt, Color bg, Color tc, Widget page) {
    return SizedBox(
      width: 280, height: 50,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(backgroundColor: bg, shape: const StadiumBorder()),
        onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => page)),
        child: Text(txt, style: TextStyle(color: tc, fontWeight: FontWeight.bold)),
      ),
    );
  }
}