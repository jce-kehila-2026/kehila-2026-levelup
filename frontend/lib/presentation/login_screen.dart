import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:frontend/logic/auth_controller.dart'; 
import 'dashboard_screen.dart'; 

class AppColors {
  static const Color purple = Color(0xFF663D99);
  static const Color purpleDark = Color(0xFF422969);
  static const Color purpleDeep = Color(0xFF26266A);
  static const Color gold = Color(0xFFF0C230);
  static const Color goldDark = Color(0xFFC9A01F);
  static const Color bg = Color(0xFFF0F5F7);
  static const Color white = Color(0xFFFFFFFF);
  static const Color text = Color(0xFF1A1A2E);
  static const Color muted = Color(0xFF6B7280);
  static const Color border = Color(0xFFD9D3E8);
  static const Color inputBorder = Color(0xFFC4B8DA);
  static const Color error = Color(0xFFDC2626);
  static const Color errorBg = Color(0xFFFEF2F2);
}

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final AuthController _authController = AuthController();
  
  String mode = 'student'; 
  
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController usernameController = TextEditingController();
  final TextEditingController pinCodeController = TextEditingController();

  bool isLoading = false;
  String errorMessage = '';

  Future<void> handleLogin() async {
    FocusScope.of(context).unfocus();

    setState(() {
      errorMessage = '';
      isLoading = true;
    });

    HapticFeedback.lightImpact();

    final result = await _authController.login(
      mode: mode,
      email: emailController.text,
      password: passwordController.text,
      username: usernameController.text,
      pinCode: pinCodeController.text,
    );

    if (!mounted) return;

    setState(() {
      isLoading = false;
    });

    if (!result.success) {
      HapticFeedback.heavyImpact();
      setState(() {
        errorMessage = result.errorMessage ?? 'حدث خطأ غير معروف';
      });
    } else {
      HapticFeedback.mediumImpact();
      debugPrint("Login Successful! Real Role: ${result.role}");
      
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => DashboardScreen(role: result.role!),
        ),
      );
    }
  }

  void switchMode(String newMode) {
    setState(() {
      mode = newMode;
      errorMessage = '';
      emailController.clear();
      passwordController.clear();
      usernameController.clear();
      pinCodeController.clear();
    });
  }

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    usernameController.dispose();
    pinCodeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 32.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Column(
                  children: [
                    Image.asset(
                      'assets/images/Shah2Range.jpeg',
                      width: 260,
                      height: 260,
                      fit: BoxFit.contain,
                      errorBuilder: (context, error, stackTrace) => 
                        const Icon(Icons.image_not_supported, size: 100, color: AppColors.muted),
                    ),
                  ],
                ),
                const SizedBox(height: 32),

                Container(
                  decoration: BoxDecoration(
                    color: AppColors.white,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: AppColors.border),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.04),
                        blurRadius: 4,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  padding: const EdgeInsets.all(4),
                  child: Row(
                    children: [
                      Expanded(child: _buildToggleButton('student', Icons.person_outline, 'Student')),
                      Expanded(child: _buildToggleButton('staff', Icons.work_outline, 'Staff')),
                    ],
                  ),
                ),
                const SizedBox(height: 20),

                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: AppColors.white,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: AppColors.border),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.05),
                        blurRadius: 12,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      if (mode == 'staff') ...[
                        _buildInputField('Email Address', 'your@institution.edu', emailController, TextInputType.emailAddress, false),
                        const SizedBox(height: 18),
                        _buildInputField('Password', 'Enter your password', passwordController, TextInputType.text, true),
                      ] else ...[
                        _buildInputField('Username', 'firstname.lastname', usernameController, TextInputType.text, false),
                        const SizedBox(height: 18),
                        _buildInputField('PIN Code', '4-digit PIN', pinCodeController, TextInputType.number, true, maxLength: 4),
                      ],
                      
                      if (errorMessage.isNotEmpty) ...[
                        const SizedBox(height: 18),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                          decoration: BoxDecoration(
                            color: AppColors.errorBg,
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(color: const Color(0xFFFCA5A5)),
                          ),
                          child: Row(
                            children: [
                              const Icon(Icons.error_outline, color: AppColors.error, size: 16),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  errorMessage,
                                  style: const TextStyle(color: AppColors.error, fontSize: 13),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],

                      const SizedBox(height: 18),
                      
                      ElevatedButton(
                        onPressed: isLoading ? null : handleLogin,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.gold,
                          disabledBackgroundColor: AppColors.gold.withValues(alpha: 0.85),
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                          elevation: 4,
                          shadowColor: AppColors.gold.withValues(alpha: 0.35),
                        ),
                        child: isLoading
                            ? const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(color: AppColors.text, strokeWidth: 2),
                              )
                            : const Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    'Sign In',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                      color: AppColors.text,
                                    ),
                                  ),
                                  SizedBox(width: 8),
                                  Icon(Icons.arrow_forward, size: 18, color: AppColors.text),
                                ],
                              ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildToggleButton(String targetMode, IconData icon, String title) {
    final isActive = mode == targetMode;
    return GestureDetector(
      onTap: () => switchMode(targetMode),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 11),
        decoration: BoxDecoration(
          color: isActive ? AppColors.purple : Colors.transparent,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 16, color: isActive ? AppColors.white : AppColors.muted),
            const SizedBox(width: 6),
            Text(
              title,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: isActive ? AppColors.white : AppColors.muted,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInputField(String label, String hint, TextEditingController controller, TextInputType keyboardType, bool isPassword, {int? maxLength}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.purpleDark, letterSpacing: 0.4),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          keyboardType: keyboardType,
          obscureText: isPassword,
          maxLength: maxLength,
          style: const TextStyle(fontSize: 15, color: AppColors.text),
          onChanged: (val) {
            if (errorMessage.isNotEmpty) {
              setState(() => errorMessage = '');
            }
          },
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: const TextStyle(color: AppColors.muted),
            filled: true,
            fillColor: AppColors.bg,
            counterText: '',
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 13),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: AppColors.inputBorder, width: 1.5),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: AppColors.purple, width: 1.5),
            ),
          ),
        ),
      ],
    );
  }
}