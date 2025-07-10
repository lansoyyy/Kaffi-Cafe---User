import 'package:flutter/material.dart';
import 'package:kaffi_cafe/screens/home_screen.dart';
import 'package:kaffi_cafe/screens/auth/signup_screen.dart';
import 'package:kaffi_cafe/utils/colors.dart';
import 'package:kaffi_cafe/widgets/button_widget.dart';
import 'package:kaffi_cafe/widgets/text_widget.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _resetEmailController = TextEditingController();

  bool _isPasswordVisible = false;

  void _handleLogin() {
    // Basic validation
    if (_emailController.text.isEmpty || _passwordController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: TextWidget(
            text: 'Please enter both email and password',
            fontSize: 16,
            color: plainWhite,
            fontFamily: 'Regular',
          ),
          backgroundColor: festiveRed,
          duration: const Duration(seconds: 3),
        ),
      );
      return;
    }

    // Placeholder for authentication logic (e.g., Firebase, Auth0)
    // For demo, assume login is successful if email and password are non-empty
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: TextWidget(
          text: 'Login successful!',
          fontSize: 16,
          color: plainWhite,
          fontFamily: 'Regular',
        ),
        backgroundColor: bayanihanBlue,
        duration: const Duration(seconds: 3),
      ),
    );

    // Navigate to HomeScreen
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const HomeScreen()),
    );
  }

  void _handleSignUp() {
    // Navigate to SignUpScreen
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const SignUpScreen()),
    );
  }

  void _showForgotPasswordDialog() {
    showDialog(
      context: context,
      builder: (context) {
        final screenWidth = MediaQuery.of(context).size.width;
        final fontSize = screenWidth * 0.036;
        final padding = screenWidth * 0.035;

        return AlertDialog(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
          backgroundColor: plainWhite,
          title: TextWidget(
            text: 'Reset Password',
            fontSize: fontSize + 4,
            color: textBlack,
            isBold: true,
            fontFamily: 'Bold',
            letterSpacing: 1.2,
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextWidget(
                text: 'Enter your email to receive a password reset link',
                fontSize: fontSize,
                color: charcoalGray,
                fontFamily: 'Regular',
              ),
              const SizedBox(height: 12),
              Card(
                elevation: 4,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(15),
                    color: plainWhite,
                    boxShadow: [
                      BoxShadow(
                        color: bayanihanBlue.withOpacity(0.1),
                        blurRadius: 6,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: TextField(
                    controller: _resetEmailController,
                    keyboardType: TextInputType.emailAddress,
                    decoration: InputDecoration(
                      border: InputBorder.none,
                      hintText: 'Enter your email',
                      hintStyle: TextStyle(
                        fontSize: fontSize,
                        color: charcoalGray.withOpacity(0.6),
                        fontFamily: 'Regular',
                      ),
                    ),
                    style: TextStyle(
                      fontSize: fontSize,
                      color: textBlack,
                      fontFamily: 'Regular',
                    ),
                  ),
                ),
              ),
            ],
          ),
          actions: [
            ButtonWidget(
              label: 'Cancel',
              onPressed: () => Navigator.of(context).pop(),
              color: ashGray,
              textColor: textBlack,
              fontSize: fontSize,
              height: 40,
              width: 100,
              radius: 10,
            ),
            ButtonWidget(
              label: 'Send Reset Link',
              onPressed: () {
                if (_resetEmailController.text.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: TextWidget(
                        text: 'Please enter your email',
                        fontSize: 16,
                        color: plainWhite,
                        fontFamily: 'Regular',
                      ),
                      backgroundColor: festiveRed,
                      duration: const Duration(seconds: 3),
                    ),
                  );
                  return;
                }

                // Placeholder for sending reset link (e.g., Firebase, Auth0)
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: TextWidget(
                      text:
                          'Password reset link sent to ${_resetEmailController.text}',
                      fontSize: 16,
                      color: plainWhite,
                      fontFamily: 'Regular',
                    ),
                    backgroundColor: bayanihanBlue,
                    duration: const Duration(seconds: 3),
                  ),
                );
                Navigator.of(context).pop();
                _resetEmailController.clear();
              },
              color: bayanihanBlue,
              textColor: plainWhite,
              fontSize: fontSize,
              height: 40,
              width: 150,
              radius: 10,
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final fontSize = screenWidth * 0.036;
    final padding = screenWidth * 0.035;

    return Scaffold(
      body: Padding(
        padding: EdgeInsets.symmetric(horizontal: padding, vertical: 12.0),
        child: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Center(
                child: Image.asset(
                  'assets/images/logo.png',
                  height: 150,
                ),
              ),
              const SizedBox(height: 12),
              // Email Field
              TextWidget(
                text: 'Email',
                fontSize: 20,
                color: textBlack,
                isBold: true,
                fontFamily: 'Bold',
                letterSpacing: 1.2,
              ),
              const SizedBox(height: 8),
              Card(
                elevation: 4,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(15),
                    color: plainWhite,
                    boxShadow: [
                      BoxShadow(
                        color: bayanihanBlue.withOpacity(0.1),
                        blurRadius: 6,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: TextField(
                    controller: _emailController,
                    keyboardType: TextInputType.emailAddress,
                    decoration: InputDecoration(
                      border: InputBorder.none,
                      hintText: 'Enter your email',
                      hintStyle: TextStyle(
                        fontSize: fontSize,
                        color: charcoalGray.withOpacity(0.6),
                        fontFamily: 'Regular',
                      ),
                    ),
                    style: TextStyle(
                      fontSize: fontSize,
                      color: textBlack,
                      fontFamily: 'Regular',
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 18),
              // Password Field
              TextWidget(
                text: 'Password',
                fontSize: 20,
                color: textBlack,
                isBold: true,
                fontFamily: 'Bold',
                letterSpacing: 1.2,
              ),
              const SizedBox(height: 8),
              Card(
                elevation: 4,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(15),
                    color: plainWhite,
                    boxShadow: [
                      BoxShadow(
                        color: bayanihanBlue.withOpacity(0.1),
                        blurRadius: 6,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: TextField(
                    controller: _passwordController,
                    obscureText: !_isPasswordVisible,
                    decoration: InputDecoration(
                      border: InputBorder.none,
                      hintText: 'Enter your password',
                      hintStyle: TextStyle(
                        fontSize: fontSize,
                        color: charcoalGray.withOpacity(0.6),
                        fontFamily: 'Regular',
                      ),
                      suffixIcon: IconButton(
                        icon: Icon(
                          _isPasswordVisible
                              ? Icons.visibility
                              : Icons.visibility_off,
                          color: bayanihanBlue,
                        ),
                        onPressed: () {
                          setState(() {
                            _isPasswordVisible = !_isPasswordVisible;
                          });
                        },
                      ),
                    ),
                    style: TextStyle(
                      fontSize: fontSize,
                      color: textBlack,
                      fontFamily: 'Regular',
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              // Forgot Password
              Align(
                alignment: Alignment.centerRight,
                child: GestureDetector(
                  onTap: _showForgotPasswordDialog,
                  child: TextWidget(
                    text: 'Forgot Password?',
                    fontSize: fontSize - 1,
                    color: bayanihanBlue,
                    isBold: true,
                    fontFamily: 'Bold',
                  ),
                ),
              ),
              const SizedBox(height: 24),
              // Login Button
              Center(
                child: ButtonWidget(
                  label: 'Log In',
                  onPressed: _handleLogin,
                  color: bayanihanBlue,
                  textColor: plainWhite,
                  fontSize: fontSize + 2,
                  height: 50,
                  radius: 12,
                  width: screenWidth * 0.6,
                ),
              ),
              const SizedBox(height: 12),
              // Sign Up Button
              Center(
                child: ButtonWidget(
                  label: 'Sign Up',
                  onPressed: _handleSignUp,
                  color: ashGray,
                  textColor: textBlack,
                  fontSize: fontSize + 2,
                  height: 50,
                  radius: 12,
                  width: screenWidth * 0.6,
                ),
              ),
              const SizedBox(height: 30),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _resetEmailController.dispose();
    super.dispose();
  }
}
