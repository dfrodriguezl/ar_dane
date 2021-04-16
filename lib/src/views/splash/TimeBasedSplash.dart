import 'package:flutter/material.dart';
import 'package:flutter_app/src/views/ui/InitialMap.dart';
import 'package:splashscreen/splashscreen.dart';
import '../../../main.dart';

class TimeBasedSplash extends State<MyApp>{
  @override
  Widget build(BuildContext context) {
    return new SplashScreen(
      seconds: 10,          // Load Splash screen for 10 seconds.
      navigateAfterSeconds: new InitialMap(),       // Navigate to HomeScreen after defined duration.
      image: new Image.asset('images/logo-DANE.png'),   // Load this image in the splash screen
      photoSize: 150,       // Size of the photo
      loaderColor: Color(0xffbe0c4d),      // Color of Loading spinner
      styleTextUnderTheLoader : const TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold, color: Colors.white),
      loadingText: new Text('Sincronizando satélites...'),
      backgroundColor: Colors.white,
      // gradientBackground: LinearGradient(   // Background color
      //   begin: Alignment.topCenter,
      //   end: Alignment.bottomCenter,
      //   colors: <Color>[
      //     Colors.white
      //   ],
      // ),
    );
  }
}