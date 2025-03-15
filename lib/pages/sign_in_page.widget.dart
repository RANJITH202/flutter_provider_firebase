import 'package:flutter/material.dart';

class UserSigninPageWidget extends StatefulWidget {
  const UserSigninPageWidget({super.key});

  @override
  State<UserSigninPageWidget> createState() => _UserSigninPageWidgetState();
}

class _UserSigninPageWidgetState extends State<UserSigninPageWidget> {
  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.blue,
      child: const Column(
        mainAxisSize: MainAxisSize.max,
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [ 
          Text(
            "Sign In"
          ),
      ]
      )
    );
  }
}