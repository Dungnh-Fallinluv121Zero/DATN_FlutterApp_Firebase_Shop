import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:untitled/model/user_model.dart';
import 'package:untitled/provider/address_provider.dart';
import 'package:untitled/provider/auth_provider.dart' as FirebaseAuthProvider;
import 'package:untitled/provider/book_provider.dart';
import 'package:untitled/provider/cart_provider.dart';
import 'package:untitled/views/wellcome_page.dart';
import 'package:untitled/views/home2_page.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  final authProvider = FirebaseAuthProvider.AuthProvider();
  await authProvider.checkSigned();

  UserModel? userModel;
  if (authProvider.isSignedIn) {
    userModel = await authProvider.getUserByUid(authProvider.email);
  }

  runApp(MyApp(authProvider: authProvider, userModel: userModel));
}

class MyApp extends StatelessWidget {
  final FirebaseAuthProvider.AuthProvider authProvider;
  final UserModel? userModel;

  const MyApp({Key? key, required this.authProvider, this.userModel})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider.value(value: authProvider),
        ChangeNotifierProxyProvider<FirebaseAuthProvider.AuthProvider,
            CartProvider>(
          create: (_) => CartProvider(userId: ''),
          update: (context, authProvider, previousCartProvider) {
            if (authProvider.isSignedIn) {
              return CartProvider(userId: userModel!.uid);
            } else {
              return previousCartProvider ?? CartProvider(userId: '');
            }
          },
        ),
        ChangeNotifierProxyProvider<FirebaseAuthProvider.AuthProvider, AddressProvider>(
          create: (_) => AddressProvider(userId: ''),
          update: (context, authProvider, previousAddressProvider) {
            if (authProvider.isSignedIn && userModel != null) {
              return AddressProvider(userId: userModel!.uid);
            } else {
              return previousAddressProvider ?? AddressProvider(userId: '');
            }
          },
        ),
        ChangeNotifierProvider(
          create: (_) => BookProvider(),
        ),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Flutter App DATN',
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
          useMaterial3: true,
        ),
        home: authProvider.isSignedIn && userModel != null
            ? HomePage2(userModel: userModel!)
            : const WellcomePage(),
      ),
    );
  }
}
