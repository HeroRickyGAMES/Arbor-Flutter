import 'package:arbor/chatActivity/chatActivity.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

//Programado por HeroRickyGames

class ChatList extends StatefulWidget {
  const ChatList({super.key});

  @override
  State<ChatList> createState() => _ChatListState();
}

class _ChatListState extends State<ChatList> {
  var UID = FirebaseAuth.instance.currentUser?.uid;
  String NomeUser = '';
  String URL = '';
  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (context, constrains){
      return Container(
        height: constrains.maxHeight,
        width: double.infinity,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          border: Border.all(
            color: Colors.white,
            width: 1.0,
          ),
          borderRadius: const BorderRadius.all(Radius.circular(5.0)),
        ),
        child: StreamBuilder(
            stream: FirebaseFirestore
                .instance
                .collection('DocChatIDs')
                .snapshots(),
            builder: (
                BuildContext context,
                AsyncSnapshot<QuerySnapshot> snapshot){
              if (!snapshot.hasData) {
                return const Center(
                  child: CircularProgressIndicator(),
                );
              }

              if(snapshot.data!.docs.isEmpty){
                return Center(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(16),
                        child: const Icon(
                          Icons.mark_chat_unread,
                          size: 100,
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.all(16),
                        child: const Text('Você ainda não tem nenhum chat ativo! Procure usuarios para conversar e interagir na guia de paquera!'),
                      ),
                    ],
                  ),
                );
              }

              return ListView(
                children: snapshot.data!.docs.map((documents){
                  mtUser() async {
                    var resulte = await FirebaseFirestore.instance
                        .collection("Usuarios")
                        .doc(UID)
                        .get();
                    setState(() {
                      NomeUser = resulte['Nome'];
                      URL = resulte['urlfoto01'];
                    });
                  }
                  mtUser();

                  if(documents['id1'] == UID){
                    return InkWell(
                      onTap: () {
                        Navigator.push(context,
                            MaterialPageRoute(builder: (context){
                              return chatActivity(
                                  documents['idChat'],
                                  documents['Nome'] == NomeUser?
                                  documents['Nome2']: documents['Nome'],
                                  documents['idDoc'],
                                  documents['Nome'] == NomeUser?documents['id2']:
                                  documents['id1'],
                              );
                            })
                        );
                      },
                      child: Container(
                        decoration: BoxDecoration(
                          border: Border.all(
                            color: Colors.white,
                            width: 1.0,
                          ),
                          borderRadius: const BorderRadius.all(Radius.circular(5.0)),
                        ),
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Container(
                              padding: const EdgeInsets.only(top: 16),
                              child: documents['Nome'] == NomeUser?
                              Text(documents['Nome2']): Text(documents['Nome'],
                                style: const TextStyle(
                                    fontSize: 20
                                ),
                              ),
                            ),
                            Row(
                              children: [
                                Expanded(
                                  flex: 1,
                                  child: Container(
                                    padding: const EdgeInsets.all(16),
                                    child: Image.network(
                                      URL == documents['URLUser2']?  documents['URLUser1']:
                                      documents['URLUser2'],
                                      scale: 15,
                                    ),
                                  ),
                                ),
                                Expanded(
                                  flex: 5,
                                  child: Text(documents['LastMensage']),
                                ),
                                Expanded(
                                  flex: 2,
                                  child: Text("${documents['Data']} - ${documents['Hora']}"),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    );
                  }else{
                    if(documents['id2'] == UID){
                      return InkWell(
                        onTap: () {
                          Navigator.push(context,
                              MaterialPageRoute(builder: (context){
                                return chatActivity(
                                    documents['idChat'],
                                    documents['Nome'] == NomeUser?
                                    documents['Nome2']: documents['Nome'],
                                    documents['idDoc'],
                                    documents['Nome'] == NomeUser?documents['id2']:
                                    documents['id1'],
                                );
                              })
                          );
                        },
                        child: Container(
                          decoration: BoxDecoration(
                            border: Border.all(
                              color: Colors.white,
                              width: 1.0,
                            ),
                            borderRadius: const BorderRadius.all(Radius.circular(5.0)),
                          ),
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Container(
                                padding: const EdgeInsets.only(top: 16),
                                child: documents['Nome'] == NomeUser?
                                Text(documents['Nome2']): Text(documents['Nome'],
                                  style: const TextStyle(
                                      fontSize: 20
                                  ),
                                ),
                              ),
                              Row(
                                children: [
                                  Expanded(
                                    flex: 1,
                                    child: Container(
                                      padding: const EdgeInsets.all(16),
                                      child: Image.network(
                                        URL == documents['URLUser1']?  documents['URLUser2']:
                                        documents['URLUser1'],
                                        scale: 15,
                                      ),
                                    ),
                                  ),
                                  Expanded(
                                    flex: 5,
                                    child: Container(
                                        child: Text(documents['LastMensage'])
                                    ),
                                  ),
                                  Expanded(
                                    flex: 2,
                                    child: Container(
                                        child: Text("${documents['Data']} - ${documents['Hora']}")
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      );
                    }else{
                      return Container();
                    }
                  }
                }).toList(),
              );
            }
        ),
      );
    });
  }
}