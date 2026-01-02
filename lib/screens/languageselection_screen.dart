import 'package:flutter/material.dart';
import 'transportselection_screen.dart';
import '../theme/colors.dart';

class LanguageSelectionScreen extends StatefulWidget {
  const LanguageSelectionScreen({super.key});

  @override
  State<LanguageSelectionScreen> createState() => _LanguageSelectionScreenState();
}

class _LanguageSelectionScreenState extends State<LanguageSelectionScreen> {
  final List<String> languages = ['English', 'Hindi', 'Gujarati', 'Kannada', 'Telugu', 'Tamil'];
  String selectedLanguage = 'English';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFDE8E8),
      appBar: AppBar(title: const Text("Search Language"), backgroundColor: Colors.transparent, elevation: 0),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            const Text("Please select your language / कृपया अपनी भाषा चुनें"),
            const SizedBox(height: 20),
            Expanded(
              child: ListView.builder(
                itemCount: languages.length,
                itemBuilder: (context, index) {
                  bool isSelected = languages[index] == selectedLanguage;
                  return GestureDetector(
                    onTap: () => setState(() => selectedLanguage = languages[index]),
                    child: Container(
                      margin: const EdgeInsets.only(bottom: 10),
                      padding: const EdgeInsets.all(15),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: isSelected ? AppColors.primaryRed : Colors.transparent, width: 2),
                      ),
                      child: Text(languages[index], textAlign: TextAlign.center),
                    ),
                  );
                },
              ),
            ),
            SizedBox(
              width: double.infinity, height: 50,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: AppColors.softRed),
                onPressed: () => Navigator.push(context, MaterialPageRoute(
                  builder: (_) => TransportSelectionScreen(passedLanguage: selectedLanguage))),
                child: const Text("Next", style: TextStyle(color: Colors.white)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}