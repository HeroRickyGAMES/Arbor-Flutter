import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:http/http.dart' as http;

//Programado por HeroRickyGames

class profileSettings extends StatefulWidget {
  bool isPremium = false;
  profileSettings(this.isPremium, {super.key});

  @override
  State<profileSettings> createState() => _profileSettingsState();
}

var UID = FirebaseAuth.instance.currentUser?.uid;
String URLFoto = '';
File? convertedFile;
File? convertedFilee;
String username = '';
String idade = '';
String sobre = '';
bool masculinoprocura = false;
bool Femininoprocura = false;
bool selecionadoGenero = false;
bool selecionadoGeneroprocura = false;
bool cidadePremium = true;
String GeneroProcura = '';
String minIdade = '';
String maxIdade = '';
final NameController = TextEditingController();
final IdadeController = TextEditingController();
final SobreController = TextEditingController();
final idadeMaxController = TextEditingController();
final idadeMinController = TextEditingController();
bool init = false;
bool isPremium = false;
final FirebaseStorage storage = FirebaseStorage.instance;

class _profileSettingsState extends State<profileSettings> {

  getUserConfigs() async {
    var resulte = await FirebaseFirestore.instance
        .collection("Usuarios")
        .doc(UID)
        .get();

    final http.Response responseData = await http.get(Uri.parse(resulte['urlfoto01']));
    Uint8List uint8list = responseData.bodyBytes;
    var buffer = uint8list.buffer;
    ByteData byteData = ByteData.view(buffer);
    var tempDir = await getTemporaryDirectory();

    convertedFile = await File("${tempDir.path}/$UID").writeAsBytes(buffer.asUint8List(byteData.offsetInBytes, byteData.lengthInBytes));
    setState(() {
      URLFoto = resulte['urlfoto01'];
      convertedFilee = convertedFile;
      username = resulte['Nome'];
      idade = "${resulte['Idade']}";
      sobre = resulte['Detalhes'];
      NameController.text = username;
      IdadeController.text = idade;
      SobreController.text = sobre;
      GeneroProcura = resulte['GeneroProcura'];
      minIdade = "${resulte['idadeProcuraMin']}";
      maxIdade = "${resulte['idadeProcura']}";
      idadeMaxController.text = "${resulte['idadeProcura']}";
      idadeMinController.text = "${resulte['idadeProcuraMin']}";
      cidadePremium = resulte['exibirApenasEmMinhaLocalização'];

    });
    if(resulte['GeneroProcura'] == 'Feminino'){
      setState(() {
        selecionadoGeneroprocura = true;
        masculinoprocura = false;
        Femininoprocura = true;
      });
    }else{
      if(resulte['GeneroProcura'] == 'Masculino'){
        setState(() {
          selecionadoGeneroprocura = true;
          masculinoprocura = true;
          Femininoprocura = false;
        });
      }
    }
    if(widget.isPremium == false){
      cidadePremium = true;
    }
  }



  voidPickFile() async {
    final pickedFile = await ImagePicker().pickImage(source: ImageSource.gallery);
    setState(() {
      convertedFilee = File(pickedFile!.path);
    });
  }

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
  void dispose() {
    // TODO: implement dispose
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {

    if(init == false){
      getUserConfigs();
    }

    if(convertedFilee == null){
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    init = true;
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            child: InkWell(
              onTap: (){
                voidPickFile();
              },
                child: Image.file(
                    convertedFilee!,
                  scale: 2,
                  width: 500,
                  height: 500,
                )
            ),
          ),
          Container(
            padding: const EdgeInsets.all(16),
            child: TextFormField(
              controller: NameController,
              keyboardType: TextInputType.name,
              onChanged: (valor){
                username = valor;
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
              controller: IdadeController,
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
              controller: SobreController,
              keyboardType: TextInputType.text,
              onChanged: (valor){
                sobre = valor;
                //Mudou mandou para a String

              },
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                hintText: 'Sobre você',
              ),
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
                Container(
                    padding: const EdgeInsets.all(16),
                    child: const Text(
                        'Idade procura:'
                    )
                ),
                Container(
                  padding: const EdgeInsets.all(16),
                  child: TextFormField(
                    controller: idadeMinController,
                    keyboardType: TextInputType.number,
                    onChanged: (valor){
                      minIdade = valor;
                      //Mudou mandou para a String

                    },
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                      hintText: 'Idade Mínima',
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.all(16),
                  child: TextFormField(
                    controller: idadeMaxController,
                    keyboardType: TextInputType.number,
                    onChanged: (valor){
                      maxIdade = valor;
                      //Mudou mandou para a String

                    },
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                      hintText: 'Idade Máxima',
                    ),
                  ),
                ),
                //PremiumFunctions
                UID != 'IuWeYRTsFXcaEFTYoUo8h4VZh8m2' ?
                Container(
                    padding: const EdgeInsets.all(16),
                    child: const Text(
                        'Premium'
                    )
                ): Container(),
                UID != 'IuWeYRTsFXcaEFTYoUo8h4VZh8m2' ?
                CheckboxListTile(
                  title: Row(
                    children: [
                      const Text(
                          'Exibir apenas pessoas proximas'
                      ),
                      TextButton(
                        onPressed: (){
                          showDialog(
                            context: context,
                            builder: (BuildContext context) {
                              return AlertDialog(
                                actions: [
                                  Container(
                                    padding: const EdgeInsets.all(16),
                                    child: Center(
                                      child: Column(
                                        children: [
                                          const Text('Exibe pessoas com base na sua localização levando a base do municipio que você está.'),
                                          TextButton(onPressed: (){
                                            Navigator.of(context).pop();
                                          }, child: const Text('Prosseguir'))
                                        ],
                                      ),
                                    ),
                                  )
                                ],
                              );
                            },
                          );
                        },
                        child: const Icon(Icons.help_outline),
                      )
                    ],
                  ),
                  value: cidadePremium,
                  onChanged: widget.isPremium ? (value) {
                    setState(() {
                      cidadePremium = value!;
                    });
                  } : null,
                  activeColor: Colors.blue,
                  checkColor: Colors.white,
                  controlAffinity: ListTileControlAffinity.leading,
                ): Container(),
                Container(
                    padding: const EdgeInsets.all(16),
                    child: ElevatedButton(
                      onPressed: () async {

                        if(URLFoto == ''){
                          Fluttertoast.showToast(
                              msg: "A foto não foi selecionada!",
                              toastLength: Toast.LENGTH_SHORT,
                              gravity: ToastGravity.CENTER,
                              timeInSecForIosWeb: 1,
                              backgroundColor: Colors.red,
                              textColor: Colors.white,
                              fontSize: 16.0
                          );
                        }else{
                          if(username == ''){
                            Fluttertoast.showToast(
                                msg: "O campo do nome não pode ficar vazio!",
                                toastLength: Toast.LENGTH_SHORT,
                                gravity: ToastGravity.CENTER,
                                timeInSecForIosWeb: 1,
                                backgroundColor: Colors.red,
                                textColor: Colors.white,
                                fontSize: 16.0
                            );
                          }else{
                            if(idade == ""){
                              Fluttertoast.showToast(
                                  msg: "O campo do idade não pode ficar vazio!",
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
                                    msg: "Selecione um genero!",
                                    toastLength: Toast.LENGTH_SHORT,
                                    gravity: ToastGravity.CENTER,
                                    timeInSecForIosWeb: 1,
                                    backgroundColor: Colors.red,
                                    textColor: Colors.white,
                                    fontSize: 16.0
                                );
                              }else{
                                  if(minIdade == ''){
                                    Fluttertoast.showToast(
                                        msg: "O campo do idade minima não pode ficar vazio!",
                                        toastLength: Toast.LENGTH_SHORT,
                                        gravity: ToastGravity.CENTER,
                                        timeInSecForIosWeb: 1,
                                        backgroundColor: Colors.red,
                                        textColor: Colors.white,
                                        fontSize: 16.0
                                    );
                                  }else{
                                    if(maxIdade == ''){
                                      Fluttertoast.showToast(
                                          msg: "O campo do idade Maxima não pode ficar vazio!",
                                          toastLength: Toast.LENGTH_SHORT,
                                          gravity: ToastGravity.CENTER,
                                          timeInSecForIosWeb: 1,
                                          backgroundColor: Colors.red,
                                          textColor: Colors.white,
                                          fontSize: 16.0
                                      );
                                    }else{
                                      if(int.parse(minIdade) < int.parse(maxIdade)){
                                        showDialog(
                                          context: context,
                                          builder: (BuildContext context) {
                                            return const AlertDialog(
                                              title: Text('Aguarde!'),
                                              actions: [
                                                Center(
                                                  child: CircularProgressIndicator(),
                                                )
                                              ],
                                            );
                                          },
                                        );
                                        final imageUrl = await _uploadImageToFirebase(convertedFilee!, UID!);
                                        FirebaseFirestore.instance.collection('Usuarios').doc(UID).update({
                                          'Nome': username,
                                          'Idade': int.parse(idade),
                                          'Detalhes': sobre,
                                          'GeneroProcura': GeneroProcura,
                                          'urlfoto01': imageUrl,
                                          'idadeProcuraMin': int.parse(minIdade),
                                          'maxIdade': int.parse(maxIdade),
                                          'exibirApenasEmMinhaLocalização': cidadePremium,
                                        }).whenComplete(() {
                                          Navigator.of(context).pop();
                                          Fluttertoast.showToast(
                                              msg: "Informações atualizadas!",
                                              toastLength: Toast.LENGTH_SHORT,
                                              gravity: ToastGravity.CENTER,
                                              timeInSecForIosWeb: 1,
                                              backgroundColor: Colors.red,
                                              textColor: Colors.white,
                                              fontSize: 16.0
                                          );
                                          Fluttertoast.showToast(
                                              msg: "Talvez por algumas auterações é necessario reiniciar o aplicativo para que entrem em vigor.",
                                              toastLength: Toast.LENGTH_LONG,
                                              gravity: ToastGravity.CENTER,
                                              timeInSecForIosWeb: 1,
                                              backgroundColor: Colors.red,
                                              textColor: Colors.white,
                                              fontSize: 16.0
                                          );
                                        });
                                      }else{
                                        Fluttertoast.showToast(
                                            msg: "A idade minima está maior que a idade maxima!",
                                            toastLength: Toast.LENGTH_SHORT,
                                            gravity: ToastGravity.CENTER,
                                            timeInSecForIosWeb: 1,
                                            backgroundColor: Colors.red,
                                            textColor: Colors.white,
                                            fontSize: 16.0
                                        );
                                      }
                                    }
                                  }
                              }
                            }
                          }
                        }
                      },
                      child: const Text('Salvar'),
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