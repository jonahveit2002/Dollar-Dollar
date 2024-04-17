import 'package:flutter/material.dart';
import 'package:dollar_dollar/controllers/auth_controller.dart';
import 'package:dollar_dollar/utils/string_validator.dart';


class SignInAccountPage extends StatefulWidget {
  const SignInAccountPage({super.key});

  @override
  State<SignInAccountPage> createState() => _SignInAccountPageState();

}

class _SignInAccountPageState extends State<SignInAccountPage> {
  final _formKey = GlobalKey<FormState>();

  final _emailController = TextEditingController();
  final _pwController = TextEditingController();
  String _errorMessage = '';

  @override
  Widget build(BuildContext context){
    return Scaffold(
      appBar: AppBar(title: const Text('Sign In')),
      body: Padding(padding: const EdgeInsets.all(20.0),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              TextFormField(
                keyboardType: TextInputType.emailAddress, 
                controller: _emailController,
                // style: TextStyle(color: Colors.black),
                decoration: InputDecoration(
                  labelText: 'Email Address',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                  
                
                ),
                validator: validateEmailAddress,
              ),
              const SizedBox(height: 20),
              TextFormField(
                obscureText: true,
                controller: _pwController,
                decoration: InputDecoration(
                  labelText: 'Password',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                  
                ),
                // style: const TextStyle(color: Colors.black),
                validator: validatePassword,
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.0),),
                    backgroundColor: Colors.white,
                ),
                child: const Text('Sign In', style: TextStyle(color: Colors.black),),
                onPressed: ()  async {
                  if (_formKey.currentState!.validate()) {
                    final result = await AuthController().signIn(
                      email: _emailController.text.trim(),
                      password: _pwController.text.trim(),
                    );
                    if (result == null) {
                      Navigator.of(context).pop();
                    }
                    else {
                      setState(() {
                        _errorMessage = result;
                      });
                    }
                  }               
                },
              ),
              Text(_errorMessage, style: const TextStyle(color: Colors.red)),
            ],
          ),
        ),
      ),
    );
  }


}