import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'moderator_screen.dart';

class ModeratorLoginScreen extends StatefulWidget {
  const ModeratorLoginScreen({Key? key}) : super(key: key);

  @override
  State<ModeratorLoginScreen> createState() => _ModeratorLoginScreenState();
}

class _ModeratorLoginScreenState extends State<ModeratorLoginScreen> {
  final TextEditingController _passwordController = TextEditingController();
  bool _isLoading = false;
  String? _errorMessage;
  final String _hardcodedPassword = 'abc123';

  Future<void> _login() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    await Future.delayed(const Duration(milliseconds: 300)); // Simulate delay

    if (_passwordController.text == _hardcodedPassword) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('userId', 'localModerator'); // Dummy local mod ID

      if (mounted) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (_) => const ModeratorScreen()),
        );
      }
    } else {
      setState(() {
        _errorMessage = 'كلمة المرور غير صحيحة';
        _isLoading = false;
      });
    }
  }

  @override
  void dispose() {
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('تسجيل دخول المشرف')),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              'أدخل كلمة مرور المشرف',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            TextField(
              controller: _passwordController,
              obscureText: true,
              decoration: const InputDecoration(
                labelText: 'كلمة المرور',
                border: OutlineInputBorder(),
              ),
              onSubmitted: (_) => _login(),
            ),
            const SizedBox(height: 16),
            if (_errorMessage != null)
              Text(_errorMessage!, style: const TextStyle(color: Colors.red)),
            const SizedBox(height: 16),
            _isLoading
                ? const CircularProgressIndicator()
                : ElevatedButton(
              onPressed: _login,
              child: const Text('دخول'),
            ),
          ],
        ),
      ),
    );
  }
}
