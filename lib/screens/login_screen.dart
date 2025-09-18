import 'dart:async';
import 'package:flutter/material.dart';
import 'package:rive/rive.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  StateMachineController? controller;

  // State machine inputs
  SMIBool? isChecking;
  SMIBool? isHandsUp;
  SMITrigger? trigSuccess;
  SMITrigger? trigFail;
  SMINumber? numLook;

  bool isPasswordVisible = false;

  // Controladores de texto
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  // Focus y timer
  final FocusNode _emailFocus = FocusNode();
  final FocusNode _passwordFocus = FocusNode();
  Timer? _idleTimer;

  @override
  void initState() {
    super.initState();

    // Listener: email focus
    _emailFocus.addListener(() {
      if (_emailFocus.hasFocus) {
        isChecking?.change(true);
        _resetIdleTimer();
      } else {
        isChecking?.change(false);
        numLook?.change(0);
        _idleTimer?.cancel();
      }
    });

    // Listener: password focus
    _passwordFocus.addListener(() {
      if (_passwordFocus.hasFocus) {
        isHandsUp?.change(true);
      } else {
        isHandsUp?.change(false);
      }
    });
  }

  void _resetIdleTimer() {
    _idleTimer?.cancel();
    _idleTimer = Timer(const Duration(seconds: 1), () {
      if (_emailFocus.hasFocus) {
        numLook?.change(0);
        isChecking?.change(false);
      }
    });
  }

  @override
  void dispose() {
    _emailFocus.dispose();
    _passwordFocus.dispose();
    _idleTimer?.cancel();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final Size size = MediaQuery.of(context).size;

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SizedBox(
                width: size.width,
                height: 200,
                child: RiveAnimation.asset(
                  'animated_login_character.riv',
                  stateMachines: ['Login Machine'],
                  onInit: (artboard) {
                    controller = StateMachineController.fromArtboard(
                      artboard,
                      'Login Machine',
                    );
                    if (controller == null) return;

                    artboard.addController(controller!);
                    isChecking = controller!.findSMI('isChecking');
                    isHandsUp = controller!.findSMI('isHandsUp');
                    trigSuccess = controller!.findSMI('trigSuccess');
                    trigFail = controller!.findSMI('trigFail');
                    numLook = controller!.findSMI('numLook');
                  },
                ),
              ),
              const SizedBox(height: 10),

              // Campo email
              TextField(
                controller: _emailController,
                focusNode: _emailFocus,
                onChanged: (value) {
                  isHandsUp?.change(false);
                  isChecking?.change(true);

                  if (numLook != null) {
                    numLook!.change(value.length.toDouble() * 1.5);
                  }

                  _resetIdleTimer();
                },
                decoration: InputDecoration(
                  hintText: 'Email',
                  prefixIcon: const Icon(Icons.mail),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
              const SizedBox(height: 10),

              // Campo password con MouseRegion
              MouseRegion(
                onEnter: (_) {
                  isHandsUp?.change(true);
                },
                onExit: (_) {
                  if (!_passwordFocus.hasFocus) {
                    isHandsUp?.change(false);
                  }
                },
                child: TextField(
                  controller: _passwordController,
                  focusNode: _passwordFocus,
                  onChanged: (value) {
                    isChecking?.change(false);
                    isHandsUp?.change(true);
                  },
                  obscureText: !isPasswordVisible,
                  decoration: InputDecoration(
                    hintText: "Password",
                    prefixIcon: const Icon(Icons.lock),
                    suffixIcon: IconButton(
                      icon: Icon(
                        isPasswordVisible
                            ? Icons.visibility_off
                            : Icons.visibility,
                      ),
                      onPressed: () {
                        setState(() {
                          isPasswordVisible = !isPasswordVisible;
                        });
                      },
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 10),

              SizedBox(
                width: size.width,
                child: const Text(
                  "Forgot your Password?",
                  textAlign: TextAlign.right,
                  style: TextStyle(decoration: TextDecoration.underline),
                ),
              ),
              const SizedBox(height: 10),

              // Botón Login con validación y triggers
              MaterialButton(
                minWidth: size.width,
                height: 50,
                color: Colors.blue,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                onPressed: () {
                  final email = _emailController.text.trim();
                  final password = _passwordController.text;

                  // resetear estados antes del trigger
                  isChecking?.change(false);
                  isHandsUp?.change(false);
                  numLook?.change(0);

                  if (email == "MBaPech@gmail.com" &&
                      password == "Basto12345") {
                    trigSuccess?.fire();
                  } else {
                    trigFail?.fire();
                  }
                },
                child: const Text(
                  "Login",
                  style: TextStyle(color: Colors.white),
                ),
              ),
              SizedBox(
                width: size.width,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text("Don't have an account?"),
                    TextButton(
                      onPressed: () {},
                      child: const Text(
                        "Sign up",
                        style: TextStyle(
                          color: Colors.black,
                          fontWeight: FontWeight.bold,
                          decoration: TextDecoration.underline,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}





