import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_chat_bubble/chat_bubble.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:uuid/uuid.dart';

//Programado por HeroRickyGames

class chatActivity extends StatefulWidget {
  String id = '';
  String NomeChat2 = '';
  String DocChatIDs = '';

  chatActivity(this.id, this.NomeChat2, this.DocChatIDs, {super.key});

  @override
  State<chatActivity> createState() => _chatActivityState();
}

class _chatActivityState extends State<chatActivity> {
  var UID = FirebaseAuth.instance.currentUser?.uid;
  String textoMensagem = '';
  final msgController = TextEditingController();
  String NomeUser = '';
  ScrollController scrollController = ScrollController();
  bool started = false;
  @override
  Widget build(BuildContext context) {

    mtUser() async {
      var resulte = await FirebaseFirestore.instance
          .collection("Usuarios")
          .doc(UID)
          .get();
      setState(() {
        NomeUser = resulte['Nome'];
      });
    }

    rolateToEnd() async {
      await Future.delayed(const Duration(seconds: 1));
      scrollController.animateTo(scrollController.position.maxScrollExtent, duration: const Duration(microseconds: 1), curve: Curves.easeOut);
    }

    if(started == false){
      rolateToEnd();
    }

    mtUser();

    started = true;

    return LayoutBuilder(
      builder: (context, constrains){
        return Scaffold(
          appBar: AppBar(
            centerTitle: true,
            title: Text(widget.NomeChat2),
          ),
          body: SingleChildScrollView(
            child: Column(
              children: [
                Container(
                  height: constrains.maxHeight - 200,
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
                          .collection('ChatCollection')
                          .doc(widget.id)
                          .collection('Mensagens')
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
                            child: Container(
                              padding: const EdgeInsets.all(16),
                              child: const Text('Você ainda não tem nenhum chat ;-;'),
                            ),
                          );
                        }
                        return Container(
                          padding: const EdgeInsets.all(16),
                          child: ListView(
                            controller: scrollController,
                            children: snapshot.data!.docs.map((documents){
                              if (!snapshot.hasData) {
                                return const Center(
                                  child: CircularProgressIndicator(),
                                );
                              }
                              return Column(
                                children: [
                                  InkWell(
                                    onLongPress: (){
                                      showDialog(
                                        context: context,
                                        builder: (BuildContext context) {
                                          return AlertDialog(
                                            actions: [
                                              Center(
                                                child: Container(
                                                  padding: const EdgeInsets.all(16),
                                                  child: TextButton(onPressed: (){

                                                    ClipboardData data = ClipboardData(text: documents['Mensagem']);

                                                    Clipboard.setData(data);

                                                    Fluttertoast.showToast(
                                                        msg: "Copiado!",
                                                        toastLength: Toast.LENGTH_SHORT,
                                                        gravity: ToastGravity.CENTER,
                                                        timeInSecForIosWeb: 1,
                                                        backgroundColor: Colors.red,
                                                        textColor: Colors.white,
                                                        fontSize: 16.0
                                                    );

                                                    Navigator.pop(context);

                                                  },
                                                      child: const Text(
                                                        'Copiar',
                                                        style: TextStyle(
                                                            color: Colors.blue
                                                        ),
                                                      )
                                                  ),
                                                ),
                                              ),
                                              documents['Nome'] == NomeUser? Center(
                                                child: Container(
                                                  padding: const EdgeInsets.all(16),
                                                  child: TextButton(onPressed: (){
                                                    FirebaseFirestore.instance.collection('ChatCollection').doc(widget.id).collection('Mensagens').doc(documents['id']).update({
                                                      'Mensagem': 'Essa Menssagem foi excluida!'
                                                    }).whenComplete((){
                                                      Navigator.of(context).pop();
                                                    });
                                                  },
                                                      child: const Text(
                                                        'Deletar',
                                                        style: TextStyle(
                                                            color: Colors.red
                                                        ),
                                                      )
                                                  ),
                                                ),
                                              ): Container(),
                                            ],
                                          );
                                        },
                                      );
                                    },
                                    child: ChatBubble(
                                      clipper: ChatBubbleClipper1(type: documents['Nome'] == NomeUser?  BubbleType.sendBubble : BubbleType.receiverBubble),
                                      alignment: documents['Nome'] == NomeUser? Alignment.centerRight: Alignment.centerLeft,
                                      margin: const EdgeInsets.only(top: 20),
                                      backGroundColor: Colors.blue,
                                      child: Container(
                                        constraints: BoxConstraints(
                                          maxWidth: MediaQuery.of(context).size.width * 0.7,
                                        ),
                                        child: Column(
                                          children: [
                                            Text(
                                              documents['Nome'],
                                              style: const TextStyle(
                                                  fontSize: 11
                                              ),
                                            ),
                                            Text(
                                                documents['Mensagem']
                                            ),
                                            Text(
                                              "${documents['Data']} ${documents['Hora']}",
                                              style: const TextStyle(
                                                  fontSize: 11
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              );
                            }).toList(),
                          ),
                        );
                      }
                  ),
                ),
                Container(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      Expanded(
                        flex: 5,
                        child:
                        TextFormField(
                          controller: msgController,
                          keyboardType: TextInputType.emailAddress,
                          onChanged: (valor){
                            textoMensagem = valor;
                            //Mudou mandou para a String

                          },
                          decoration: const InputDecoration(
                            border: OutlineInputBorder(),
                            hintText: 'Mensagem',
                          ),
                        ),
                      ),
                      Expanded(
                          child: TextButton(
                            onPressed: () async {
                              if(textoMensagem == ''){
                                Fluttertoast.showToast(
                                    msg: "O campo de texto não pode ser vazio!",
                                    toastLength: Toast.LENGTH_SHORT,
                                    gravity: ToastGravity.CENTER,
                                    timeInSecForIosWeb: 1,
                                    backgroundColor: Colors.red,
                                    textColor: Colors.white,
                                    fontSize: 16.0
                                );
                              }else{
                                var uuid2 = const Uuid().v4();
                                var resulte = await FirebaseFirestore.instance
                                    .collection("Usuarios")
                                    .doc(UID)
                                    .get();
                                String IDMenssagem = "${DateTime.now()} $uuid2";
                                FirebaseFirestore.instance.collection('ChatCollection').doc(widget.id).collection('Mensagens').doc(IDMenssagem).set({
                                  'id': IDMenssagem,
                                  'PertenceA': "$UID",
                                  'Nome': resulte['Nome'],
                                  'Data': '${DateTime.now().month}/${DateTime.now().day}/${DateTime.now().year} ',
                                  'Hora': '${DateTime.now().hour}:${DateTime.now().minute}',
                                  'Mensagem' : textoMensagem,
                                }).whenComplete((){
                                  FirebaseFirestore.instance.collection('DocChatIDs').doc(widget.DocChatIDs).update({
                                    "LastMensage": '${resulte['Nome']}: $textoMensagem',
                                    'Data': '${DateTime.now().month}/${DateTime.now().day}/${DateTime.now().year} ',
                                    'Hora': '${DateTime.now().hour}:${DateTime.now().minute}',
                                  });
                                  setState(() {
                                    textoMensagem = '';
                                    msgController.clear();
                                  });
                                  scrollController.animateTo(scrollController.position.maxScrollExtent, duration: const Duration(microseconds: 500), curve: Curves.easeOut);
                                });
                              }
                            },
                            child: const Icon(Icons.send),
                          )
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
