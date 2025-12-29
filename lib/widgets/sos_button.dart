import 'package:flutter/material.dart';
import '../screens/sos_screen.dart';

class SOSButton extends StatelessWidget {
  const SOSButton({super.key});

  @override
  Widget build(BuildContext context) {
    return FloatingActionButton(
      backgroundColor: Colors.red,
      child: const Icon(Icons.warning),
      onPressed: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const SosScreen()),
        );
      },
    );
  }
}
