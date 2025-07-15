import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:kaffi_cafe/screens/auth/login_screen.dart';

logout(BuildContext context, Widget navigationRoute) {
  return showDialog(
      context: context,
      builder: (context) => AlertDialog(
            title: const Text(
              'Logout Confirmation',
              style: TextStyle(fontFamily: 'Bold', fontWeight: FontWeight.bold),
            ),
            content: const Text(
              'Are you sure you want to Logout?',
              style: TextStyle(fontFamily: 'Regular'),
            ),
            actions: <Widget>[
              MaterialButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text(
                  'Cancel',
                  style: TextStyle(
                      fontFamily: 'Regular', fontWeight: FontWeight.bold),
                ),
              ),
              MaterialButton(
                onPressed: () async {
                  try {
                    await FirebaseAuth.instance.signOut();
                    if (context.mounted) {
                      Navigator.of(context).pushAndRemoveUntil(
                        MaterialPageRoute(builder: (context) => const LoginScreen()),
                        (route) => false,
                      );
                    }
                  } catch (e) {
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Error logging out: $e'),
                          backgroundColor: Colors.red,
                        ),
                      );
                    }
                  }
                },
                child: const Text(
                  'Logout',
                  style: TextStyle(
                      fontFamily: 'Regular', fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ));
}
