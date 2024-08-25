import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:untitled/model/user_model.dart';
import 'package:untitled/provider/auth_provider.dart' as FirebaseAuthProvider;
import 'package:untitled/views/authentication/login_page.dart';
import 'package:untitled/views/home2_page.dart';
import 'package:untitled/views/user/address/location_page.dart';
import 'package:untitled/widgets/button_custom.dart';

class WellcomePage extends StatefulWidget {
  const WellcomePage({Key? key}) : super(key: key);

  @override
  State<WellcomePage> createState() => _WellcomePageState();
}

class _WellcomePageState extends State<WellcomePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: MultiProvider(
          providers: [
            ChangeNotifierProvider(
                create: (_) => FirebaseAuthProvider.AuthProvider())
          ],
          child: Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 25, horizontal: 35),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Image.asset(
                    "assets/2.png",
                  ),
                  Padding(
                    padding: const EdgeInsets.only(left: 40.0, right: 40.0),
                    child: SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ButtonCustomW(
                        text: "Get Started",
                        onPressed: () async {
                          final ap =
                              Provider.of<FirebaseAuthProvider.AuthProvider>(
                                  context,
                                  listen: false);
                          if (ap.isSignedIn) {
                            User? user = FirebaseAuth.instance.currentUser;
                            if (user != null) {
                              UserModel? userModel =
                                  await FirebaseAuthProvider.AuthProvider()
                                      .getUserByUid(user.email);
                              if (userModel != null) {
                                Navigator.pushReplacement(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) =>
                                        HomePage2(userModel: userModel),
                                  ),
                                );
                              } else {
                                print(
                                    'UserModel not found for user ${user.email}');
                                Navigator.pushReplacement(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => const LogInPage(),
                                  ),
                                );
                              }
                            } else {
                              print('Current user is null');
                            }
                          } else {
                            Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const LogInPage(),
                              ),
                            );
                          }
                        },
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
