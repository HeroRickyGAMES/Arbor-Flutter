import 'package:arbor/firebase_options.dart';
import 'package:arbor/loginScreen/loginScreen.dart';
import 'package:arbor/swipeMainTela/mainTelaApp.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';

//Desenvolvido por HeroRickyGames

void main(){
  runApp(
    MaterialApp(
      theme: ThemeData(
          brightness: Brightness.dark,
          useMaterial3: true,
          elevatedButtonTheme: ElevatedButtonThemeData(
            style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                onPrimary: Colors.white
            ),
          ),
          appBarTheme: const AppBarTheme(
              backgroundColor: Colors.redAccent,
              titleTextStyle: TextStyle(
                  color: Colors.white
              )
          )
      ),
      home: const MainApp(),
    ),
  );
}

class MainApp extends StatefulWidget {
  const MainApp({super.key});

  @override
  State<MainApp> createState() => _MainAppState();
}

class _MainAppState extends State<MainApp> {

  checkIsLogin() async {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    FirebaseAuth.instance.idTokenChanges().listen((User? user) async {

      if(user == null){
        Navigator.pop(context);
        Navigator.push(context,
            MaterialPageRoute(builder: (context){
              return const LoginScreen();
            }));
      }else{
        Navigator.pop(context);
        Navigator.push(context,
            MaterialPageRoute(builder: (context){
              return const MainTelaRoleta();
            }));
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    checkIsLogin();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Fazer Login'),
        centerTitle: true,
      ),
    );
  }
}