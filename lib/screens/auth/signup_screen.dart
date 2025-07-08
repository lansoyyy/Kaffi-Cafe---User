import 'package:flutter/material.dart';
import 'package:kaffi_cafe/screens/auth/login_screen.dart';
import 'package:kaffi_cafe/screens/home_screen.dart';

import 'package:kaffi_cafe/utils/colors.dart';
import 'package:kaffi_cafe/widgets/button_widget.dart';
import 'package:kaffi_cafe/widgets/text_widget.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();

  final TextEditingController _nameController = TextEditingController();
  bool _isPasswordVisible = false;
  bool _isConfirmPasswordVisible = false;

  void _handleSignUp() {
    // Basic validation
    if (_emailController.text.isEmpty ||
        _passwordController.text.isEmpty ||
        _confirmPasswordController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: TextWidget(
            text: 'Please fill in all fields',
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

    if (_passwordController.text != _confirmPasswordController.text) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: TextWidget(
            text: 'Passwords do not match',
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
    // For demo, assume sign-up is successful if fields are non-empty and passwords match
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: TextWidget(
          text: 'Sign-up successful!',
          fontSize: 16,
          color: plainWhite,
          fontFamily: 'Regular',
        ),
        backgroundColor: bayanihanBlue,
        duration: const Duration(seconds: 3),
      ),
    );

    // Navigate to HomeScreen (adjust path as needed)
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const HomeScreen()),
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
              TextWidget(
                text: 'Name',
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
                    controller: _nameController,
                    keyboardType: TextInputType.text,
                    decoration: InputDecoration(
                      border: InputBorder.none,
                      hintText: 'Enter your name',
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
              const SizedBox(height: 18),
              // Confirm Password Field
              TextWidget(
                text: 'Confirm Password',
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
                    controller: _confirmPasswordController,
                    obscureText: !_isConfirmPasswordVisible,
                    decoration: InputDecoration(
                      border: InputBorder.none,
                      hintText: 'Confirm your password',
                      hintStyle: TextStyle(
                        fontSize: fontSize,
                        color: charcoalGray.withOpacity(0.6),
                        fontFamily: 'Regular',
                      ),
                      suffixIcon: IconButton(
                        icon: Icon(
                          _isConfirmPasswordVisible
                              ? Icons.visibility
                              : Icons.visibility_off,
                          color: bayanihanBlue,
                        ),
                        onPressed: () {
                          setState(() {
                            _isConfirmPasswordVisible =
                                !_isConfirmPasswordVisible;
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
              // Log In Link
              Align(
                alignment: Alignment.centerRight,
                child: GestureDetector(
                  onTap: () {
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const LoginScreen()),
                    );
                  },
                  child: TextWidget(
                    text: 'Already have an account? Log In',
                    fontSize: fontSize - 1,
                    color: bayanihanBlue,
                    isBold: true,
                    fontFamily: 'Bold',
                  ),
                ),
              ),
              const SizedBox(height: 24),
              // Sign Up Button
              Center(
                child: ButtonWidget(
                  label: 'Sign Up',
                  onPressed: _handleSignUp,
                  color: bayanihanBlue,
                  textColor: plainWhite,
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
    _confirmPasswordController.dispose();
    super.dispose();
  }
}
