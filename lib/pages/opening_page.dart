import 'package:flutter/material.dart';
import 'package:dollar_dollar/pages/create_account_page.dart';
import 'package:dollar_dollar/pages/sign_in_account_page.dart';
import 'package:flutter/widgets.dart';





class OpeningPage extends StatelessWidget {
  const OpeningPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
              const Text(
                "Dollar-Dollar", 
                style: TextStyle( 
                  fontSize: 60,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'MadimiOne',
                    color: Colors.red,
                ),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const CreateAccountPage()),);
                }, 
                style: ElevatedButton.styleFrom(
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.0),),
                  backgroundColor: Colors.red[600],
                ),
                child: const Text("Create Account", style: TextStyle(color: Colors.black),)
                
              ),
              ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const SignInAccountPage()),);
                }, 
                style: ElevatedButton.styleFrom(
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.0),),
                  backgroundColor: Colors.white,
                ),
                child: const Text("Sign In", style: TextStyle(color: Colors.black),)
              ),
                
            ],
          
        ),
      ),
    );
  }
}
