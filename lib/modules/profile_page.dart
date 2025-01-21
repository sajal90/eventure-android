import 'package:clerk_flutter/clerk_flutter.dart';
import 'package:flutter/material.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({
    super.key,
    required this.publishableKey,
  });

  final String publishableKey;

  @override
  Widget build(BuildContext context) {
    return ClerkAuth(
      publishableKey: publishableKey,
      child: MaterialApp(
        builder: (BuildContext context, Widget? child) {
          return ClerkErrorListener(child: child!);
        },
        home: Scaffold(
          backgroundColor: ClerkColors.whiteSmoke,
          body: SafeArea(
            child: Padding(
              padding: horizontalPadding32,
              child: Center(
                child: ClerkAuthBuilder(
                  signedInBuilder: (context, auth) => const ClerkUserButton(),
                  signedOutBuilder: (context, auth) {
                    return const ClerkAuthenticationWidget();
                  },
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
