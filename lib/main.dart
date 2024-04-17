// import 'package:dollar_dollar/pages/MyHomePage.dart';
import 'package:dollar_dollar/controllers/auth_controller.dart';
import 'package:dollar_dollar/pages/MyHomePage.dart';
import 'package:dollar_dollar/pages/opening_page.dart';
// import 'package:dollar_dollar/pages/sign_in_account_page.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(const MyApp());
}

class IncomeItem {
  final String name;
  final double amount;
  final String catagory;

  IncomeItem({required this.name, required this.amount, required this.catagory});
}

class ExpenseItem {
  final String name;
  final double amount;
  final String catagory;

  ExpenseItem({required this.name, required this.amount, required this.catagory});
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key});

  @override
  Widget build(BuildContext context) {
    final stream = AuthController().loggedInStream;

    return StreamBuilder(
      stream: stream, 
      builder: (context, AsyncSnapshot<bool> snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          // While waiting for the stream to emit a value, show a loading indicator or splash screen
          return MaterialApp(
            title: 'Dollar-Dollar',
            home: Scaffold(body: Center(child: CircularProgressIndicator())),
          );
        } else {
          if (snapshot.hasError) {
            // If there's an error with the stream, handle it appropriately
            return MaterialApp(
              title: 'Dollar-Dollar',
              home: Scaffold(body: Center(child: Text('Error: ${snapshot.error}'))),
            );
          } else {
            return  MaterialApp(
                title: 'Dollar-Dollar',
                home: snapshot.data == true?MyHomePage(title: 'Dollar-Dollar',): OpeningPage(),
              );
  
          }
        }
      },
    );
  }
}



