import 'package:arbor/registro/cadastre-se.dart';
import 'package:arbor/swipeMainTela/mainTelaApp.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:geolocator/geolocator.dart';

//Desenvolvido por HeroRickyGames

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  String Email = '';
  String Senha = '';

  Future<Position> _determinePosition() async {
    bool serviceEnabled;
    LocationPermission permission;

    // Test if location services are enabled.
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      // Location services are not enabled don't continue
      // accessing the position and request users of the
      // App to enable the location services.
      return Future.error('Location services are disabled.');
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        // Permissions are denied, next time you could try
        // requesting permissions again (this is also where
        // Android's shouldShowRequestPermissionRationale
        // returned true. According to Android guidelines
        // your App should show an explanatory UI now.
        return Future.error('Location permissions are denied');
      }
    }

    if (permission == LocationPermission.deniedForever) {
      // Permissions are denied forever, handle appropriately.
      return Future.error(
          'Location permissions are permanently denied, we cannot request permissions.');
    }

    // When we reach here, permissions are granted and we can
    // continue accessing the position of the device.
    return await Geolocator.getCurrentPosition();
  }

  @override
  Widget build(BuildContext context) {
    final FirebaseAuth _auth = FirebaseAuth.instance;
    _determinePosition();
    return Scaffold(
      appBar: AppBar(
        title: const Text('Fazer Login'),
        centerTitle: true,
      ),
      body: Center(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                child: TextFormField(
                  keyboardType: TextInputType.emailAddress,
                  onChanged: (valor){
                    Email = valor;
                    //Mudou mandou para a String

                  },
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    hintText: 'Email',
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.all(16),
                child: TextFormField(
                  keyboardType: TextInputType.visiblePassword,
                  onChanged: (valor){
                    Senha = valor;
                    //Mudou mandou para a String

                  },
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    hintText: 'Senha',
                  ),
                ),
              ),
              Container(
                  padding: const EdgeInsets.all(16),
                  child: ElevatedButton(
                    onPressed: (){
                      if(Email == ''){
                        Fluttertoast.showToast(
                            msg: "Digite o seu email!",
                            toastLength: Toast.LENGTH_SHORT,
                            gravity: ToastGravity.CENTER,
                            timeInSecForIosWeb: 1,
                            backgroundColor: Colors.red,
                            textColor: Colors.white,
                            fontSize: 16.0
                        );
                      }else{
                        if(Senha == ''){
                          Fluttertoast.showToast(
                              msg: "Digite sua Senha!",
                              toastLength: Toast.LENGTH_SHORT,
                              gravity: ToastGravity.CENTER,
                              timeInSecForIosWeb: 1,
                              backgroundColor: Colors.red,
                              textColor: Colors.white,
                              fontSize: 16.0
                          );
                        }else{
                          _auth.signInWithEmailAndPassword(email: Email, password: Senha).whenComplete(() {
                            Navigator.pop(context);
                            Navigator.push(context,
                                MaterialPageRoute(builder: (context){
                                  return const MainTelaRoleta();
                                }));
                          });
                        }
                      }

                    },
                    child: const Text('Fazer Login'),
                  )
              ),
              Container(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text('Ainda não tem uma conta?'),
                      TextButton(
                        onPressed: (){
                          Navigator.push(context,
                              MaterialPageRoute(builder: (context){
                                return const Cadastrese();
                              }));
                        },
                        child: const Text('Crie uma conta agora!'),
                      ),
                    ],
                  )
              ),
            ],
          ),
        ),
      ),
    );
  }
}