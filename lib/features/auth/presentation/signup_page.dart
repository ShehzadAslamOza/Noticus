import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:noticus/core/navigation/presentation/navigation.dart';

import '../bloc/auth_bloc.dart';
import 'login_page.dart';

class SignupPage extends StatelessWidget {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: BlocListener<AuthBloc, AuthState>(
        listener: (context, state) {
          if (state is AuthSuccess) {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => NavigationPage()),
            );
          } else if (state is AuthFailure) {
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(
              content: Text("Error: ${state.message}"),
            ));
          }
        },
        child: Center(
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  // Big Header
                  BuildHeader(),
                  SizedBox(height: 20),
                  BuildSignupCard(context),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget BuildHeader() {
    return Column(
      children: [
        Icon(
          Icons.person_add,
          size: 80.0,
          color: Colors.red.shade300,
        ),
        SizedBox(height: 10),
        Text(
          "Create Account",
          style: TextStyle(
            color: Colors.white,
            fontSize: 32.0,
            fontWeight: FontWeight.bold,
            letterSpacing: 2.0,
          ),
        )
      ],
    );
  }

  Widget BuildSignupCard(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.red.shade300,
        borderRadius: BorderRadius.circular(12.0),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            decoration: BoxDecoration(
              color: Colors.red.shade300,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(12.0),
                topRight: Radius.circular(12.0),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "Sign Up",
                  style: TextStyle(
                    color: Colors.black,
                    fontWeight: FontWeight.bold,
                    fontSize: 20.0,
                  ),
                ),
                Icon(Icons.person, color: Colors.black),
              ],
            ),
          ),
          Container(
            margin: EdgeInsets.fromLTRB(8, 0, 8, 8),
            padding: EdgeInsets.all(16.0),
            decoration: BoxDecoration(
              color: Colors.black,
              borderRadius: BorderRadius.circular(8.0),
            ),
            child: Column(
              children: [
                // Email Field
                TextField(
                  controller: emailController,
                  decoration: InputDecoration(
                    hintText: "Email",
                    hintStyle: TextStyle(color: Colors.white),
                    filled: true,
                    fillColor: Colors.grey.shade800,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8.0),
                      borderSide: BorderSide.none,
                    ),
                  ),
                  style: TextStyle(color: Colors.white),
                ),
                SizedBox(height: 16.0),

                // Password Field
                TextField(
                  controller: passwordController,
                  decoration: InputDecoration(
                    hintText: "Password",
                    hintStyle: TextStyle(color: Colors.white),
                    filled: true,
                    fillColor: Colors.grey.shade800,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8.0),
                      borderSide: BorderSide.none,
                    ),
                  ),
                  obscureText: true,
                  style: TextStyle(color: Colors.white),
                ),
                SizedBox(height: 20),

                // Sign Up Button or Circular Progress Indicator
                BlocBuilder<AuthBloc, AuthState>(
                  builder: (context, state) {
                    if (state is AuthLoading) {
                      return Center(
                        child: CircularProgressIndicator(
                          color: Colors.red.shade300,
                        ),
                      );
                    }
                    return ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red.shade300,
                        foregroundColor: Colors.black, // Text color
                        padding: EdgeInsets.symmetric(vertical: 12.0),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8.0),
                        ),
                      ),
                      onPressed: () {
                        context.read<AuthBloc>().add(
                              SignupEvent(
                                emailController.text,
                                passwordController.text,
                              ),
                            );
                      },
                      child: Center(
                        child: Text(
                          "Sign Up",
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ),
                    );
                  },
                ),

                SizedBox(height: 10),

                // Login Link
                TextButton(
                  onPressed: () {
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(builder: (context) => LoginPage()),
                    );
                  },
                  child: Text(
                    "Already have an account? Log in",
                    style: TextStyle(color: Colors.grey.shade300),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
