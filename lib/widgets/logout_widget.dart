import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';

logout(BuildContext context, Widget navigationRoute) {
  final box = GetStorage();

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
                onPressed: () => Navigator.of(context).pop(true),
                child: const Text(
                  'Close',
                  style: TextStyle(
                      fontFamily: 'Regular', fontWeight: FontWeight.bold),
                ),
              ),
              MaterialButton(
                onPressed: () async {
                  box.erase();
                  // Get.off(LandingScreen(),
                  //     transition: Transition.circularReveal);
                },
                child: const Text(
                  'Continue',
                  style: TextStyle(
                      fontFamily: 'Regular', fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ));
}
