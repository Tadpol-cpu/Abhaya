import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'languageselection_screen.dart';
import 'login_screen.dart';
import '../theme/colors.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _loading = false;

  Future<void> _handleSignup() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _loading = true);

    try {
      // 1. Create User in Firebase Auth
      UserCredential cred = await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );

      // 2. Save Profile to Firestore
      await FirebaseFirestore.instance.collection('users').doc(cred.user!.uid).set({
        'name': _nameController.text.trim(),
        'email': _emailController.text.trim(),
        'setupComplete': false,
        'createdAt': FieldValue.serverTimestamp(),
      });

      // 3. Redirect to Language Selection
      if (mounted) {
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (_) => const LanguageSelectionScreen()),
          (route) => false,
        );
      }
    } on FirebaseAuthException catch (e) {
      setState(() => _loading = false);
      String msg = e.code == 'email-already-in-use' 
          ? "Email already exists. Try logging in." 
          : e.message ?? "Signup Error";
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
    } catch (e) {
      setState(() => _loading = false);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Error: $e")));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFDE8E8),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(32),
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                Image.asset('assets/images/abhaya_logo.png', width: 140),
                const SizedBox(height: 30),
                TextFormField(
                  controller: _nameController, 
                  decoration: const InputDecoration(labelText: "Name"),
                  validator: (v) => v!.isEmpty ? "Enter name" : null,
                ),
                TextFormField(
                  controller: _emailController, 
                  decoration: const InputDecoration(labelText: "Email"),
                  validator: (v) => v!.contains('@') ? null : "Invalid email",
                ),
                TextFormField(
                  controller: _passwordController, 
                  obscureText: true, 
                  decoration: const InputDecoration(labelText: "Password"),
                  validator: (v) => v!.length < 6 ? "Min 6 characters" : null,
                ),
                const SizedBox(height: 30),
                if (_loading) 
                  const CircularProgressIndicator()
                else ...[
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primaryRed, 
                        shape: const StadiumBorder()
                      ),
                      onPressed: _handleSignup,
                      child: const Text("Sign Up", style: TextStyle(color: Colors.white)),
                    ),
                  ),
                  const SizedBox(height: 15),
                  TextButton(
                    onPressed: () => Navigator.pushReplacement(
                      context, MaterialPageRoute(builder: (_) => const LoginScreen())
                    ),
                    child: const Text("Already have an account? Log In", 
                        style: TextStyle(color: Colors.black54)),
                  ),
                ]
              ],
            ),
          ),
        ),
      ),
    );
  }
}


