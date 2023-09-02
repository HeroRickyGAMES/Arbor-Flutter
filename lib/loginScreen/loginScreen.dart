import 'package:arbor/AdsWidget/AdsWidget.dart';
import 'package:arbor/registro/cadastre-se.dart';
import 'package:arbor/swipeMainTela/mainTelaApp.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:geolocator/geolocator.dart';
import 'package:translator_plus/translator_plus.dart';

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
        Fluttertoast.showToast(
            msg: "Recomendamos fortemente que você permita a permissão de localização,",
            toastLength: Toast.LENGTH_SHORT,
            gravity: ToastGravity.CENTER,
            timeInSecForIosWeb: 1,
            backgroundColor: Colors.red,
            textColor: Colors.white,
            fontSize: 16.0
        );
        Fluttertoast.showToast(
            msg: " caso você não garanta essa permissão infelizmente o aplicativo",
            toastLength: Toast.LENGTH_SHORT,
            gravity: ToastGravity.CENTER,
            timeInSecForIosWeb: 1,
            backgroundColor: Colors.red,
            textColor: Colors.white,
            fontSize: 16.0
        );

        Fluttertoast.showToast(
            msg: " não irá funcionar corretamente em seu disposito!",
            toastLength: Toast.LENGTH_SHORT,
            gravity: ToastGravity.CENTER,
            timeInSecForIosWeb: 1,
            backgroundColor: Colors.red,
            textColor: Colors.white,
            fontSize: 16.0
        );
        Fluttertoast.showToast(
            msg: "Isso pode gerar banimentos permanentes em sua conta caso você não utilise o GPS!",
            toastLength: Toast.LENGTH_SHORT,
            gravity: ToastGravity.CENTER,
            timeInSecForIosWeb: 1,
            backgroundColor: Colors.red,
            textColor: Colors.white,
            fontSize: 16.0
        );
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
                  child: Image.asset(
                      'assets/images/ic_launcher.png',
                    scale: 4,
                  )
              ),
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
                  obscureText: true,
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
                          showDialog(
                            context: context,
                            builder: (BuildContext context) {
                              return const AlertDialog(
                                title: Text('Aguarde!'),
                                actions: [
                                  Center(
                                      child: CircularProgressIndicator()
                                  )
                                ],
                              );
                            },
                          );
                          _auth.signInWithEmailAndPassword(email: Email, password: Senha).catchError((e){

                            print(e.toString());
                            Navigator.of(context).pop();
                            final translator = GoogleTranslator();

                            String error = e.toString().replaceAll("[firebase_auth/wrong-password]", "").replaceAll("[firebase_auth/too-many-requests]", "").replaceAll("[firebase_auth/user-not-found]", "").replaceAll("[firebase_auth/invalid-email]", "").trim();
                            translator.translate(error, from: 'en', to: 'pt').then((s) {
                              Fluttertoast.showToast(
                                  msg: "$s",
                                  toastLength: Toast.LENGTH_SHORT,
                                  gravity: ToastGravity.CENTER,
                                  timeInSecForIosWeb: 1,
                                  backgroundColor: Colors.red,
                                  textColor: Colors.white,
                                  fontSize: 16.0
                              );
                            });

                          }).then((value){
                            Navigator.of(context).pop();
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
              Container(
                  padding: const EdgeInsets.all(16),
                  child: AdBannerLayout(false),
              ),
            ],
          ),
        ),
      ),
    );
  }
}