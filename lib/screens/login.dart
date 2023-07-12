import 'package:flutter/material.dart';
import 'package:flutter_blog/constant.dart';
import 'package:flutter_blog/models/api_response.dart';
import 'package:flutter_blog/models/user.dart';
import 'package:flutter_blog/screens/register.dart';
import 'package:flutter_blog/services/user_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'home.dart';

class Login extends StatefulWidget {
  const Login({super.key});

  @override
  State<Login> createState() => _LoginState();
}

class _LoginState extends State<Login> {
  final GlobalKey<FormState> formkey = GlobalKey<FormState>();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  bool loading = false;

  void _loginUser() async {
    ApiResponse response =
        await login(emailController.text, passwordController.text);
    if (response.error == null) {
      _saveAndRedirectToHome(response.data as User);
    } else {
      setState(() {
        loading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(
          '${response.error}',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.red,
        shape: StadiumBorder(),
        behavior: SnackBarBehavior.floating,
      ));
    }
  }

  void _saveAndRedirectToHome(User user) async {
    SharedPreferences pref = await SharedPreferences.getInstance();
    await pref.setString('token', user.token ?? '');
    await pref.setInt('userId', user.id ?? 0);
    Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (context) => const Home()),
        (route) => false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Login'),
        centerTitle: true,
      ),
      body: Form(
          key: formkey,
          child: ListView(
            padding: EdgeInsets.all(32),
            children: [
              TextFormField(
                keyboardType: TextInputType.emailAddress,
                controller: emailController,
                validator: (val) =>
                    val!.isEmpty ? 'Invalid Email Address' : null,
                decoration: kInputDecoration('Email'),
              ),
              const SizedBox(
                height: 20,
              ),
              TextFormField(
                  obscureText: true,
                  controller: passwordController,
                  validator: (val) => val!.length < 6
                      ? 'Password cannot be less than 6 characters'
                      : null,
                  decoration: kInputDecoration('Password')),
              const SizedBox(
                height: 20,
              ),
              loading
                  ? const Center(
                      child: CircularProgressIndicator(),
                    )
                  : kTextButton('Login', () {
                      if (formkey.currentState!.validate()) {
                        setState(() {
                          loading = true;
                          _loginUser();
                        });
                      }
                    }),
              const SizedBox(
                height: 10,
              ),
              kLoginRegisterHint('Dont have an acount? ', 'Register', () {
                Navigator.of(context).pushAndRemoveUntil(
                    MaterialPageRoute(builder: (context) => const Register()),
                    (route) => false);
              })
            ],
          )),
    );
  }
}
