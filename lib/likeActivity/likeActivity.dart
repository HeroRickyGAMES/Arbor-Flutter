import 'package:arbor/chatActivity/chatActivity.dart';
import 'package:blur/blur.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:uuid/uuid.dart';

//Programado por HeroRickyGames

class likeActivity extends StatefulWidget {
  bool isPremium = false;
  likeActivity(this.isPremium, {super.key});

  @override
  State<likeActivity> createState() => _likeActivityState();
}

var UID = FirebaseAuth.instance.currentUser?.uid;

class _likeActivityState extends State<likeActivity> {
  @override
  Widget build(BuildContext context) {

    return LayoutBuilder(
        builder: (context, constrains){
          return Column(
            children: [
              Container(
                height: constrains.maxHeight,
                width: double.infinity,
                decoration: BoxDecoration(
                  border: Border.all(
                    color: Colors.black,
                    width: 1.0,
                  ),
                  borderRadius: const BorderRadius.all(Radius.circular(5.0)),
                ),
                child: StreamBuilder(
                    stream: FirebaseFirestore
                        .instance
                        .collection('Likes')
                        .where('Liked', isEqualTo: UID)
                        .snapshots(),
                    builder: (
                        BuildContext context,
                        AsyncSnapshot<QuerySnapshot> snapshot){
                      if (!snapshot.hasData) {
                        return const Center(
                          child: CircularProgressIndicator(),
                        );
                      }
                      return Container(
                        padding: const EdgeInsets.all(16),
                        child: ListView(
                          children: snapshot.data!.docs.map((documents){
                            return Column(
                              children: [
                                Row(
                                  children: [
                                    widget.isPremium == false ? Container(
                                      padding: const EdgeInsets.all(16),
                                      child: Image.network(
                                          "https://firebasestorage.googleapis.com/v0/b/lovers-ai-to-kanjo.appspot.com/o/images%2F${documents['QuemCurtiu']}%2F${documents['QuemCurtiu']}?alt=media&token=4c2d4dac-9116-4df4-a2e5-ae55210c5375",
                                        scale: 7,
                                      ).blurred(
                                          blur: 5
                                      ),
                                    )
                                        :
                                    Container(
                                      padding: const EdgeInsets.all(16),
                                      child: Image.network(
                                        "https://firebasestorage.googleapis.com/v0/b/lovers-ai-to-kanjo.appspot.com/o/images%2F${documents['QuemCurtiu']}%2F${documents['QuemCurtiu']}?alt=media&token=4c2d4dac-9116-4df4-a2e5-ae55210c5375",
                                        scale: 7,
                                      ),
                                    ),
                                    Column(
                                      children: [
                                        Container(
                                            padding: const EdgeInsets.all(16),
                                            child: Text(widget.isPremium == false ? '********' : documents['QuemCurtiuNome']),
                                        ),
                                        Row(
                                          children: [
                                            Container(
                                                padding: const EdgeInsets.all(16),
                                                child: ElevatedButton(
                                                  onPressed: widget.isPremium == true ? (){
                                                    showDialog(
                                                      context: context,
                                                      builder: (BuildContext context) {
                                                        String mensagemtext = '';
                                                        return StatefulBuilder(builder: (BuildContext context, StateSetter setState){
                                                          return AlertDialog(
                                                            title: const Text('Iniciar um chat com esse usuario?'),
                                                            actions: [
                                                              Center(
                                                                child: Column(
                                                                  children: [
                                                                    Container(
                                                                      padding: const EdgeInsets.all(16),
                                                                      child: TextFormField(
                                                                        keyboardType: TextInputType.text,
                                                                        onChanged: (valor){
                                                                          mensagemtext = valor;
                                                                          //Mudou mandou para a String
                                                                        },
                                                                        decoration: const InputDecoration(
                                                                          border: OutlineInputBorder(),
                                                                          hintText: 'Mensagem',
                                                                        ),
                                                                      ),
                                                                    ),
                                                                    Row(
                                                                      crossAxisAlignment: CrossAxisAlignment.center,
                                                                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                                                                      children: [
                                                                        TextButton(onPressed: (){
                                                                          Navigator.of(context).pop();
                                                                        }, child: const Text('Cancelar')
                                                                        ),
                                                                        TextButton(onPressed: () async {
                                                                          if(mensagemtext == ''){
                                                                            Fluttertoast.showToast(
                                                                                msg: "A mensagem não pode estar vazia!",
                                                                                toastLength: Toast.LENGTH_SHORT,
                                                                                gravity: ToastGravity.CENTER,
                                                                                timeInSecForIosWeb: 1,
                                                                                backgroundColor: Colors.red,
                                                                                textColor: Colors.white,
                                                                                fontSize: 16.0
                                                                            );
                                                                          }else{
                                                                            var resulte = await FirebaseFirestore.instance
                                                                                .collection("Usuarios")
                                                                                .doc(UID)
                                                                                .get();
                                                                            var uuid = const Uuid().v4();
                                                                            var uuid2 = const Uuid().v4();

                                                                            String IDChat = uuid;
                                                                            String IDAchat = uuid2;
                                                                            String IDMenssagem = "${DateTime.now()} $uuid2";

                                                                            FirebaseFirestore.instance.collection("ChatCollection").doc(IDChat).set({
                                                                              'id': IDChat,
                                                                              'PertenceA': "$UID",
                                                                              'PertenceA2': documents['uid'],
                                                                              'Nome': resulte['Nome'],
                                                                              'Nome2': documents['Nome'],
                                                                            });

                                                                            FirebaseFirestore.instance.collection('ChatCollection').doc(IDChat).collection('Mensagens').doc(IDMenssagem).set({
                                                                              'id': IDMenssagem,
                                                                              'PertenceA': "$UID",
                                                                              'Nome': resulte['Nome'],
                                                                              'Data': '${DateTime.now().month}/${DateTime.now().day}/${DateTime.now().year} ',
                                                                              'Hora': '${DateTime.now().hour}:${DateTime.now().minute}',
                                                                              'Mensagem' : mensagemtext,
                                                                            }).whenComplete((){
                                                                              FirebaseFirestore.instance.collection('DocChatIDs').doc(IDAchat).set({
                                                                                'URLUser1': resulte['urlfoto01'],
                                                                                'URLUser2': documents['urlfoto01'],
                                                                                "idDoc": IDAchat,
                                                                                'idChat': IDChat,
                                                                                'Nome': resulte['Nome'],
                                                                                'Nome2': documents['Nome'],
                                                                                'id1': UID,
                                                                                'id2': documents['uid'],
                                                                                'LastMensage': '${resulte['Nome']}: $mensagemtext',
                                                                                'Data': '${DateTime.now().month}/${DateTime.now().day}/${DateTime.now().year} ',
                                                                                'Hora': '${DateTime.now().hour}:${DateTime.now().minute}',
                                                                              }).then((value){
                                                                                List listLike = documents['like'];
                                                                                List swapList = documents['swaped'];
                                                                                listLike.add('true $UID');
                                                                                swapList.add(UID);

                                                                                FirebaseFirestore.instance.collection('Usuarios').doc(documents['uid']).update({
                                                                                  'like': listLike,
                                                                                  'swaped': swapList,
                                                                                }).whenComplete((){
                                                                                  FirebaseFirestore.instance.collection('Likes').doc().set({
                                                                                    'Liked': documents['uid'],
                                                                                    'QuemCurtiu': UID,
                                                                                    'QuemCurtiuNome': resulte['Nome'],
                                                                                    'Data': '${DateTime.now().month}/${DateTime.now().day}/${DateTime.now().year} ',
                                                                                    'Hora': '${DateTime.now().hour}:${DateTime.now().minute}',
                                                                                  }).whenComplete((){
                                                                                    //todo go to chat activity
                                                                                    Navigator.of(context).pop();
                                                                                    Navigator.push(context,
                                                                                        MaterialPageRoute(builder: (context){
                                                                                          return chatActivity(IDChat, documents['Nome'], IDAchat);
                                                                                        }));
                                                                                  });
                                                                                });
                                                                              });
                                                                            });
                                                                          }
                                                                        }, child: const Text('Enviar')
                                                                        ),
                                                                      ],
                                                                    )
                                                                  ],
                                                                ),
                                                              )
                                                            ],
                                                          );
                                                        },
                                                        );
                                                      },
                                                    );
                                                  } : null,
                                                  child: const Icon(Icons.chat_bubble),
                                                )
                                            ),
                                            Container(
                                                padding: const EdgeInsets.all(16),
                                                child: ElevatedButton(
                                                  onPressed: widget.isPremium ? () async {


                                                    var resulte = await FirebaseFirestore.instance
                                                        .collection("Usuarios")
                                                        .doc(UID)
                                                        .get();

                                                    List listLike = documents['like'];
                                                    List swapList = documents['swaped'];
                                                    //todo swap;

                                                    listLike.add('true $UID');
                                                    swapList.add(UID);

                                                    FirebaseFirestore.instance.collection('Usuarios').doc(documents['uid']).update({
                                                      'like': listLike,
                                                      'swaped': swapList,
                                                    }).whenComplete((){
                                                      FirebaseFirestore.instance.collection('Likes').doc().set({
                                                        'Liked': documents['uid'],
                                                        'QuemCurtiu': UID,
                                                        'QuemCurtiuNome': resulte['Nome'],
                                                        'Data': '${DateTime.now().month}/${DateTime.now().day}/${DateTime.now().year} ',
                                                        'Hora': '${DateTime.now().hour}:${DateTime.now().minute}',
                                                      }).whenComplete((){


                                                        if(resulte['like'].contains('true ${documents['uid']}')){

                                                          var uuid = const Uuid().v4();
                                                          var uuid2 = const Uuid().v4();

                                                          String IDChat = uuid;
                                                          String IDAchat = uuid2;
                                                          String IDMenssagem = "${DateTime.now()} $uuid2";

                                                          FirebaseFirestore.instance.collection("ChatCollection").doc(IDChat).set({
                                                            'id': IDChat,
                                                            'PertenceA': "$UID",
                                                            'PertenceA2': documents['uid'],
                                                            'Nome': resulte['Nome'],
                                                            'Nome2': documents['Nome'],
                                                          });

                                                          FirebaseFirestore.instance.collection('ChatCollection').doc(IDChat).collection('Mensagens').doc(IDMenssagem).set({
                                                            'id': IDMenssagem,
                                                            'PertenceA': "$UID",
                                                            'Nome': resulte['Nome'],
                                                            'Data': '${DateTime.now().month}/${DateTime.now().day}/${DateTime.now().year} ',
                                                            'Hora': '${DateTime.now().hour}:${DateTime.now().minute}',
                                                            'Mensagem' : '${resulte['Nome']} e ${documents['Nome']} fizeram um match!',
                                                          }).whenComplete((){
                                                            FirebaseFirestore.instance.collection('DocChatIDs').doc(IDAchat).set({
                                                              'URLUser1': resulte['urlfoto01'],
                                                              'URLUser2': documents['urlfoto01'],
                                                              "idDoc": IDAchat,
                                                              'idChat': IDChat,
                                                              'Nome': resulte['Nome'],
                                                              'Nome2': documents['Nome'],
                                                              'id1': UID,
                                                              'id2': documents['uid'],
                                                              'LastMensage': '${resulte['Nome']}: ${resulte['Nome']} e ${documents['Nome']} fizeram um match!',
                                                              'Data': '${DateTime.now().month}/${DateTime.now().day}/${DateTime.now().year} ',
                                                              'Hora': '${DateTime.now().hour}:${DateTime.now().minute}',
                                                            });
                                                            Fluttertoast.showToast(
                                                                msg: "Você fez um Match!",
                                                                toastLength: Toast.LENGTH_SHORT,
                                                                gravity: ToastGravity.CENTER,
                                                                timeInSecForIosWeb: 1,
                                                                backgroundColor: Colors.red,
                                                                textColor: Colors.white,
                                                                fontSize: 16.0
                                                            );
                                                          });


                                                        }else{

                                                        }
                                                      });
                                                    });

                                                  } : null,
                                                  child: const Icon(Icons.favorite),
                                                )
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ],
                            );
                          }).toList(),
                        ),
                      );
                    }
                ),
              ),
            ],
          );
        }
    );
  }
}