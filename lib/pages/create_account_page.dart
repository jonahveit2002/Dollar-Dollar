import 'package:flutter/material.dart';
import 'package:dollar_dollar/controllers/auth_controller.dart';
import 'package:dollar_dollar/utils/string_validator.dart';

class CreateAccountPage extends StatefulWidget {
  const CreateAccountPage({super.key});

  @override
  State<CreateAccountPage> createState() => _CreateAccountPageState();
}

class _CreateAccountPageState extends State<CreateAccountPage> {
  final _formKey = GlobalKey<FormState>();

  final _emailController = TextEditingController();
  final _pwController = TextEditingController();
  String _errorMessage = '';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Create Account')),
      body: Padding(padding: const EdgeInsets.all(20.0),
      child: Form(
        key: _formKey,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextFormField(
              keyboardType: TextInputType.emailAddress, 
              controller: _emailController,
              // style: const TextStyle(color: Colors.black),
              decoration: InputDecoration(
                labelText: 'Email Address',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8.0),
                ),
              ),
              validator: validateEmailAddress,
            ),
            const SizedBox(height: 20,),
            TextFormField(
              obscureText: true,
              controller: _pwController,
              decoration: InputDecoration(labelText: 'Password',border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8.0),
                ),),
              // style: const TextStyle(color: Colors.black),
              validator: validatePassword,
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.0),),
                  backgroundColor: Colors.white,
              ),
              child: const Text('Create Account', style: TextStyle(color: Colors.black),),
              onPressed: ()  async {
                if (_formKey.currentState!.validate()) {
                  final result = await AuthController().createAccount(
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

  @override
  void dispose() {
    _emailController.dispose();
    _pwController.dispose();
    super.dispose();
  }
}
