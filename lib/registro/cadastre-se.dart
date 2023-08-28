import 'dart:io';

import 'package:arbor/AdsWidget/AdsWidget.dart';
import 'package:arbor/swipeMainTela/mainTelaApp.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:path_provider/path_provider.dart';
import 'package:http/http.dart' as http;

//Programado por HeroRickyGames

class Cadastrese extends StatefulWidget {
  const Cadastrese({super.key});

  @override
  State<Cadastrese> createState() => _CadastreseState();
}

class _CadastreseState extends State<Cadastrese> {
  String Name = '';
  String idade = '';
  String Email = '';
  String Senha = '';
  String generoSelecionado = '';
  String GeneroProcura = '';
  bool masculino = false;
  bool Feminino = false;
  bool masculinoprocura = false;
  bool Femininoprocura = false;
  bool selecionadoGenero = false;
  bool selecionadoGeneroprocura = false;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseStorage storage = FirebaseStorage.instance;

  Future<String> _uploadImageToFirebase(File file, String id) async {
    // Crie uma referência única para o arquivo

    final reference = storage.ref().child('images/$id/$id');

    // Faça upload da imagem para o Cloud Storage
    await reference.putFile(file);

    // Recupere a URL do download da imagem para salvar no banco de dados
    final url = await reference.getDownloadURL();
    return url;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Cadastre-se'),
        centerTitle: true,
      ),
      body: Center(
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                child: TextFormField(
                  keyboardType: TextInputType.name,
                  onChanged: (valor){
                    Name = valor;
                    //Mudou mandou para a String

                  },
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    hintText: 'Nome',
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.all(16),
                child: TextFormField(
                  keyboardType: TextInputType.number,
                  onChanged: (valor){
                    idade = valor;
                    //Mudou mandou para a String

                  },
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    hintText: 'Idade',
                  ),
                ),
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
                child: const Text(
                  'Seu genero'
                )
              ),
              Container(
                padding: const EdgeInsets.all(16),
                child:               Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CheckboxListTile(
                      title: const Text(
                        'Masculino',
                      ),
                      value: masculino,
                      onChanged: (value) {
                        setState(() {
                          if(value == true){
                            generoSelecionado = 'Masculino';
                            selecionadoGenero = true;
                            masculino = true;
                            Feminino = false;
                          }
                        });
                      },
                      activeColor: Colors.blue,
                      checkColor: Colors.white,
                      controlAffinity: ListTileControlAffinity.leading,
                    ),
                    CheckboxListTile(
                      title: const Text(
                        'Feminino'
                      ),
                      value: Feminino,
                      onChanged: (value) {
                        setState(() {
                          if(value == true){
                            generoSelecionado = 'Feminino';
                            selecionadoGenero = true;
                            masculino = false;
                            Feminino = true;
                          }

                        });
                      },
                      activeColor: Colors.blue,
                      checkColor: Colors.white,
                      controlAffinity: ListTileControlAffinity.leading,
                    ),
                  ],
                ),
              ),
              Container(
                  padding: const EdgeInsets.all(16),
                  child: const Text(
                      'Estou procurando'
                  )
              ),
              Container(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CheckboxListTile(
                      title: const Text(
                        'Um Homem',
                      ),
                      value: masculinoprocura,
                      onChanged: (value) {
                        setState(() {
                          if(value == true){
                            GeneroProcura = 'Masculino';
                            selecionadoGeneroprocura = true;
                            masculinoprocura = true;
                            Femininoprocura = false;
                          }
                        });
                      },
                      activeColor: Colors.blue,
                      checkColor: Colors.white,
                      controlAffinity: ListTileControlAffinity.leading,
                    ),
                    CheckboxListTile(
                      title: const Text(
                          'Uma Mulher'
                      ),
                      value: Femininoprocura,
                      onChanged: (value) {
                        setState(() {
                          if(value == true){
                            GeneroProcura = 'Feminino';
                            selecionadoGeneroprocura = true;
                            masculinoprocura = false;
                            Femininoprocura = true;
                          }

                        });
                      },
                      activeColor: Colors.blue,
                      checkColor: Colors.white,
                      controlAffinity: ListTileControlAffinity.leading,
                    ),
                  ],
                ),
              ),
              Container(
                  padding: const EdgeInsets.all(16),
                  child: ElevatedButton(
                    onPressed: () async {

                      if(int.parse(idade) < 18){
                        Fluttertoast.showToast(
                            msg: "Você tem $idade, ainda não pode usar o APP!",
                            toastLength: Toast.LENGTH_SHORT,
                            gravity: ToastGravity.CENTER,
                            timeInSecForIosWeb: 1,
                            backgroundColor: Colors.red,
                            textColor: Colors.white,
                            fontSize: 16.0
                        );
                      }else{
                        if(Name == ''){
                          Fluttertoast.showToast(
                              msg: "O campo de nome está vazio!",
                              toastLength: Toast.LENGTH_SHORT,
                              gravity: ToastGravity.CENTER,
                              timeInSecForIosWeb: 1,
                              backgroundColor: Colors.red,
                              textColor: Colors.white,
                              fontSize: 16.0
                          );
                        }else{
                          if(idade == ''){
                            Fluttertoast.showToast(
                                msg: "O campo de idade está vazio!",
                                toastLength: Toast.LENGTH_SHORT,
                                gravity: ToastGravity.CENTER,
                                timeInSecForIosWeb: 1,
                                backgroundColor: Colors.red,
                                textColor: Colors.white,
                                fontSize: 16.0
                            );
                          }else{
                            if(Email == ''){
                              Fluttertoast.showToast(
                                  msg: "O campo de Email está vazio!",
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
                                    msg: "O campo de Senha está vazio!",
                                    toastLength: Toast.LENGTH_SHORT,
                                    gravity: ToastGravity.CENTER,
                                    timeInSecForIosWeb: 1,
                                    backgroundColor: Colors.red,
                                    textColor: Colors.white,
                                    fontSize: 16.0
                                );
                              }else{
                                if(selecionadoGenero == false){
                                  Fluttertoast.showToast(
                                      msg: "Selecione um genero!",
                                      toastLength: Toast.LENGTH_SHORT,
                                      gravity: ToastGravity.CENTER,
                                      timeInSecForIosWeb: 1,
                                      backgroundColor: Colors.red,
                                      textColor: Colors.white,
                                      fontSize: 16.0
                                  );
                                }else{
                                  if(selecionadoGeneroprocura == false){
                                    Fluttertoast.showToast(
                                        msg: "Selecione um que você se atrai!",
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

                                    String url = '';
                                    if(masculino == true){
                                      setState(() {
                                        url = 'https://raw.githubusercontent.com/HeroRickyGAMES/Lovers-KanjoProject/master/assets/corporate-user-icon.png';
                                      });
                                    }
                                    if(Feminino == true){
                                      setState(() {
                                        url = 'https://raw.githubusercontent.com/HeroRickyGAMES/Lovers-KanjoProject/master/assets/img_529937.png';
                                      });
                                    }

                                    Position currentPosition = await Geolocator.getCurrentPosition(
                                      desiredAccuracy: LocationAccuracy.high,
                                    );

                                    List<Placemark> placemarks = await placemarkFromCoordinates(
                                      currentPosition.latitude,
                                      currentPosition.longitude,
                                    );
                                    Placemark placemark = placemarks.first;

                                    String LocalizacaoAgora = '${placemark.street}, ${placemark.subLocality}, ${placemark.locality} ${placemark.subAdministrativeArea}, ${placemark.administrativeArea} ${placemark.postalCode}, ${placemark.country}';

                                    String Latitude = '${currentPosition.latitude}';
                                    String longitude = '${currentPosition.longitude}';

                                    //TODO CADASTRO
                                    _auth.createUserWithEmailAndPassword(email: Email, password: Senha).whenComplete(() async {
                                      var UID = FirebaseAuth.instance.currentUser?.uid;

                                      final http.Response responseData = await http.get(Uri.parse(url));
                                      Uint8List uint8list = responseData.bodyBytes;
                                      var buffer = uint8list.buffer;
                                      ByteData byteData = ByteData.view(buffer);
                                      var tempDir = await getTemporaryDirectory();

                                      var convertedFile = await File("${tempDir.path}/$UID").writeAsBytes(buffer.asUint8List(byteData.offsetInBytes, byteData.lengthInBytes));

                                      final imageUrl = await _uploadImageToFirebase(convertedFile!, UID!);

                                      FirebaseFirestore.instance.collection('Usuarios').doc(UID).set({
                                        'Nome': Name,
                                        'Idade': int.parse(idade),
                                        'Email': Email,
                                        'Genero': generoSelecionado,
                                        'GeneroProcura': GeneroProcura,
                                        'Latitude': Latitude,
                                        'Longitude': longitude,
                                        'Localizacao': LocalizacaoAgora,
                                        'LocalizaçãoDefault': '${placemark.subAdministrativeArea}',
                                        'LocalizaçãoDefaultEmCidade': '${placemark.administrativeArea}',
                                        'AssinaturaTime': '',
                                        'Debug': false,
                                        'urlfoto01': imageUrl,
                                        'numeroFotos': 1,
                                        'uid': UID,
                                        'idadeProcura': int.parse(idade) + 5,
                                        'idadeProcuraMin': int.parse(idade),
                                        'like': [''],
                                        'swaped': [''],
                                        'Detalhes': '',
                                        'exibirApenasEmMinhaLocalização': true
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
                              }
                            }
                          }
                        }
                      }
                    },
                    child: const Text('Criar conta'),
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
