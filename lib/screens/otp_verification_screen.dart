import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import 'main_app_screen.dart';

class OTPVerificationScreen extends StatefulWidget {
  final String name;
  final String email;
  final String phoneNumber;
  final String password;

  const OTPVerificationScreen({
    Key? key,
    required this.name,
    required this.email,
    required this.phoneNumber,
    required this.password,
  }) : super(key: key);

  @override
  _OTPVerificationScreenState createState() => _OTPVerificationScreenState();
}

class _OTPVerificationScreenState extends State<OTPVerificationScreen> {
  final _formKey = GlobalKey<FormState>();
  final List<TextEditingController> _otpControllers = List.generate(6, (_) => TextEditingController());
  final List<FocusNode> _focusNodes = List.generate(6, (_) => FocusNode());
  bool _isLoading = false;
  int _resendTimer = 60;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _startTimer();
  }

  @override
  void dispose() {
    _timer?.cancel();
    for (var controller in _otpControllers) {
      controller.dispose();
    }
    for (var node in _focusNodes) {
      node.dispose();
    }
    super.dispose();
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_resendTimer > 0) {
        setState(() {
          _resendTimer--;
        });
      } else {
        _timer?.cancel();
      }
    });
  }

  void _resendOTP() async {
    if (_resendTimer > 0) return;

    setState(() {
      _isLoading = true;
    });

    final success = await Provider.of<AuthProvider>(context, listen: false)
        .requestOTP(widget.phoneNumber);

    setState(() {
      _isLoading = false;
      if (success) {
        _resendTimer = 60;
        _startTimer();
      }
    });
  }

  void _verifyOTP() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    final otp = _otpControllers.map((c) => c.text).join();

    final success = await Provider.of<AuthProvider>(context, listen: false)
        .verifyOTPAndRegister(
      otp: otp,
      name: widget.name,
      email: widget.email,
      phoneNumber: widget.phoneNumber,
      password: widget.password,
    );

    setState(() => _isLoading = false);

    if (success && mounted) {
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => const MainAppScreen()),
            (route) => false,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('التحقق من رقم الهاتف'),
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.message,
                  size: 70,
                  color: Colors.green,
                ),
                const SizedBox(height: 24),
                const Text(
                  'أدخل رمز التحقق',
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 12),
                Text(
                  'تم إرسال رمز التحقق إلى ${widget.phoneNumber}',
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 16,
                    color: Colors.grey,
                  ),
                ),
                const SizedBox(height: 32),

                // OTP fields
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: List.generate(
                    6,
                        (index) => SizedBox(
                      width: 40,
                      child: TextFormField(
                        controller: _otpControllers[index],
                        focusNode: _focusNodes[index],
                        keyboardType: TextInputType.number,
                        textAlign: TextAlign.center,
                        maxLength: 1,
                        decoration: InputDecoration(
                          counterText: '',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          contentPadding: EdgeInsets.zero,
                        ),
                        validator: (value) =>
                        value!.isEmpty ? '' : null,
                        onChanged: (value) {
                          if (value.length == 1 && index < 5) {
                            _focusNodes[index + 1].requestFocus();
                          }
                        },
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 32),

                // Resend button
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text('لم تستلم الرمز؟'),
                    TextButton(
                      onPressed: _resendTimer > 0 ? null : _resendOTP,
                      child: Text(
                        _resendTimer > 0
                            ? 'إعادة الإرسال (${_resendTimer})'
                            : 'إعادة الإرسال',
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 32),

                // Verify button
                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _verifyOTP,
                    child: _isLoading
                        ? const CircularProgressIndicator(color: Colors.white)
                        : const Text('تأكيد'),
                  ),
                ),

                if (authProvider.errorMessage.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(top: 16.0),
                    child: Text(
                      authProvider.errorMessage,
                      style: const TextStyle(color: Colors.red),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}