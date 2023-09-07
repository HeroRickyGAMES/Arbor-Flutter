import 'package:arbor/chatActivity/chatActivity.dart';
import 'package:blur/blur.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:fluid_kit/fluid_kit.dart';
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
                    color: Colors.white,
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
                        child:
                        snapshot.data!.docs.isEmpty ?
                        Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Container(
                                padding: const EdgeInsets.all(16),
                                child: const Icon(
                                  Icons.heart_broken,
                                  size: 100,
                                ),
                              ),
                              Container(
                                padding: const EdgeInsets.all(16),
                                child: const Text('Ninguém ainda te curtiu. ;-; não se preocupe logo irá aparecer alguém que curta você! :)'),
                              ),
                            ],
                          ),
                        ):
                        ListView(
                          children: snapshot.data!.docs.map((documents){
                            return Column(
                              children: [
                                Fluid(
                                  children: [
                                    Fluidable(
                                      fluid: 1,
                                      minWidth: 200,
                                      child:
                                      Container(
                                        decoration: BoxDecoration(
                                          border: Border.all(
                                            color: Colors.white,
                                            width: 1.0,
                                          ),
                                          borderRadius: const BorderRadius.all(Radius.circular(5.0)),
                                        ),
                                        child: Row(
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
                                                          onPressed: widget.isPremium == true ? () async {
                                                            List rgs = [];

                                                            final resulteuseropositeColection = FirebaseFirestore.instance.collection('DocChatIDs');
                                                            final snapshot2 = await resulteuseropositeColection.get();
                                                            final request = snapshot2.docs;
                                                            for (final chatdocs in request) {

                                                              final id1 = chatdocs.get('id1');
                                                              final id2 = chatdocs.get('id2');

                                                              rgs.add("$id1, $id2");
                                                            }

                                                            var resulteuseroposite = await FirebaseFirestore.instance
                                                                .collection("Usuarios")
                                                                .doc(documents['QuemCurtiu'])
                                                                .get();

                                                            if(rgs.contains('${resulteuseroposite['uid']}, $UID')){
                                                              Fluttertoast.showToast(
                                                                  msg: "Esse chat já existe!",
                                                                  toastLength: Toast.LENGTH_SHORT,
                                                                  gravity: ToastGravity.CENTER,
                                                                  timeInSecForIosWeb: 1,
                                                                  backgroundColor: Colors.red,
                                                                  textColor: Colors.white,
                                                                  fontSize: 16.0
                                                              );
                                                            }else{
                                                              if(rgs.contains('$UID, ${resulteuseroposite['uid']}')){
                                                                Fluttertoast.showToast(
                                                                    msg: "Esse chat já existe!",
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
                                                                                          'PertenceA2': resulteuseroposite['uid'],
                                                                                          'Nome': resulte['Nome'],
                                                                                          'Nome2': resulteuseroposite['Nome'],
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
                                                                                            'URLUser2': resulteuseroposite['urlfoto01'],
                                                                                            "idDoc": IDAchat,
                                                                                            'idChat': IDChat,
                                                                                            'Nome': resulte['Nome'],
                                                                                            'Nome2': resulteuseroposite['Nome'],
                                                                                            'id1': UID,
                                                                                            'id2': resulteuseroposite['uid'],
                                                                                            'LastMensage': '${resulte['Nome']}: $mensagemtext',
                                                                                            'Data': '${DateTime.now().month}/${DateTime.now().day}/${DateTime.now().year} ',
                                                                                            'Hora': '${DateTime.now().hour}:${DateTime.now().minute}',
                                                                                          }).then((value){
                                                                                            //todo go to chat activity
                                                                                            Navigator.of(context).pop();
                                                                                            Navigator.push(context,
                                                                                                MaterialPageRoute(builder: (context){
                                                                                                  return chatActivity(IDChat, documents['Nome'], IDAchat, resulteuseroposite['uid']);
                                                                                                }));
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
                                                              }
                                                            }
                                                          } : null,
                                                          style: ElevatedButton.styleFrom(
                                                              primary: Colors.green,
                                                              minimumSize: const Size.square(10)
                                                          ),
                                                          child: Container(
                                                              padding: const EdgeInsets.all(2),
                                                              child: const Icon(Icons.chat_bubble)),
                                                        )
                                                    ),
                                                    Container(
                                                        padding: const EdgeInsets.all(16),
                                                        child: ElevatedButton(
                                                          onPressed: widget.isPremium ? () async {
                                                            List IsChatExists = [];

                                                            var resulteuseroposite = await FirebaseFirestore.instance
                                                                .collection("Usuarios")
                                                                .doc(documents['QuemCurtiu'])
                                                                .get();

                                                            if(!resulteuseroposite['swaped'].contains(UID)){
                                                              // Cria uma instância do Firebase Firestore
                                                              final firestore = FirebaseFirestore.instance;

                                                              // Obtém uma referência para a coleção "my_collection"
                                                              final collection = firestore.collection("DocChatIDs");

                                                              // Lê todos os documentos da coleção
                                                              collection.get().then((querySnapshot) {
                                                                // O map `querySnapshot.docs` contém todos os documentos da coleção
                                                                List<DocumentSnapshot> docs = querySnapshot.docs;

                                                                // Exibe todos os documentos da coleção
                                                                docs.forEach((doc) {

                                                                  print(doc);
                                                                  print(doc['id1']);
                                                                  print(doc['id2']);
                                                                  IsChatExists.add('${doc['id1']}, ${doc['id2']}');
                                                                });
                                                              });

                                                              if(IsChatExists.contains('${resulteuseroposite['uid']}, $UID')){
                                                                Fluttertoast.showToast(
                                                                    msg: "Esse chat já existe!",
                                                                    toastLength: Toast.LENGTH_SHORT,
                                                                    gravity: ToastGravity.CENTER,
                                                                    timeInSecForIosWeb: 1,
                                                                    backgroundColor: Colors.red,
                                                                    textColor: Colors.white,
                                                                    fontSize: 16.0
                                                                );
                                                              }else{
                                                                if(IsChatExists.contains('$UID, ${resulteuseroposite['uid']}')){
                                                                  Fluttertoast.showToast(
                                                                      msg: "Esse chat já existe!",
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

                                                                  List listLike = resulteuseroposite['like'];
                                                                  List swapList = resulteuseroposite['swaped'];
                                                                  //todo swap;

                                                                  listLike.add('true $UID');
                                                                  swapList.add(UID);

                                                                  FirebaseFirestore.instance.collection('Usuarios').doc(resulteuseroposite['uid']).update({
                                                                    'like': listLike,
                                                                    'swaped': swapList,
                                                                  }).whenComplete((){
                                                                    FirebaseFirestore.instance.collection('Likes').doc().set({
                                                                      'Liked': resulteuseroposite['uid'],
                                                                      'QuemCurtiu': UID,
                                                                      'QuemCurtiuNome': resulte['Nome'],
                                                                      'Data': '${DateTime.now().month}/${DateTime.now().day}/${DateTime.now().year} ',
                                                                      'Hora': '${DateTime.now().hour}:${DateTime.now().minute}',
                                                                    }).whenComplete((){

                                                                      if(resulte['like'].contains('true ${resulteuseroposite['uid']}')){

                                                                        var uuid = const Uuid().v4();
                                                                        var uuid2 = const Uuid().v4();

                                                                        String IDChat = uuid;
                                                                        String IDAchat = uuid2;
                                                                        String IDMenssagem = "${DateTime.now()} $uuid2";

                                                                        FirebaseFirestore.instance.collection("ChatCollection").doc(IDChat).set({
                                                                          'id': IDChat,
                                                                          'PertenceA': "$UID",
                                                                          'PertenceA2': resulteuseroposite['uid'],
                                                                          'Nome': resulte['Nome'],
                                                                          'Nome2': resulteuseroposite['Nome'],
                                                                        });

                                                                        FirebaseFirestore.instance.collection('ChatCollection').doc(IDChat).collection('Mensagens').doc(IDMenssagem).set({
                                                                          'id': IDMenssagem,
                                                                          'PertenceA': "$UID",
                                                                          'Nome': resulte['Nome'],
                                                                          'Data': '${DateTime.now().month}/${DateTime.now().day}/${DateTime.now().year} ',
                                                                          'Hora': '${DateTime.now().hour}:${DateTime.now().minute}',
                                                                          'Mensagem' : '${resulte['Nome']} e ${resulteuseroposite['Nome']} fizeram um match!',
                                                                        }).whenComplete((){
                                                                          FirebaseFirestore.instance.collection('DocChatIDs').doc(IDAchat).set({
                                                                            'URLUser1': resulte['urlfoto01'],
                                                                            'URLUser2': resulteuseroposite['urlfoto01'],
                                                                            "idDoc": IDAchat,
                                                                            'idChat': IDChat,
                                                                            'Nome': resulte['Nome'],
                                                                            'Nome2': resulteuseroposite['Nome'],
                                                                            'id1': UID,
                                                                            'id2': resulteuseroposite['uid'],
                                                                            'LastMensage': '${resulte['Nome']}: ${resulte['Nome']} e ${resulteuseroposite['Nome']} fizeram um match!',
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
                                                                          Navigator.push(context,
                                                                              MaterialPageRoute(builder: (context){
                                                                                return chatActivity(IDChat, documents['Nome'], IDAchat, resulteuseroposite['uid']);
                                                                              }));
                                                                        });

                                                                      }else{

                                                                      }
                                                                    });
                                                                  });
                                                                }
                                                              }
                                                            }else{
                                                              Fluttertoast.showToast(
                                                                  msg: "Você já curtiu esse usuario!",
                                                                  toastLength: Toast.LENGTH_SHORT,
                                                                  gravity: ToastGravity.CENTER,
                                                                  timeInSecForIosWeb: 1,
                                                                  backgroundColor: Colors.red,
                                                                  textColor: Colors.white,
                                                                  fontSize: 16.0
                                                              );
                                                            }
                                                          } : null,
                                                          style: ElevatedButton.styleFrom(
                                                              primary: Colors.pink,
                                                              minimumSize: const Size.square(10)
                                                          ),
                                                          child: Container(
                                                              padding: const EdgeInsets.all(2),
                                                              child: const Icon(Icons.favorite)
                                                          ),
                                                        )
                                                    ),
                                                  ],
                                                ),
                                              ],
                                            ),
                                          ],
                                        ),
                                      ),
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