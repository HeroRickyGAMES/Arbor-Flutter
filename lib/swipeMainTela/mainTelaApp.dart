import 'package:arbor/AdsWidget/AdsWidget.dart';
import 'package:arbor/bePremiumAlert/sejaPremium.dart';
import 'package:arbor/chatActivity/chatActivity.dart';
import 'package:arbor/chatActivity/chatList.dart';
import 'package:arbor/likeActivity/likeActivity.dart';
import 'package:arbor/profile/profile.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:salomon_bottom_bar/salomon_bottom_bar.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:swipeable_card_stack/swipeable_card_stack.dart';
import 'package:uuid/uuid.dart';

final Future<SharedPreferences> _prefs = SharedPreferences.getInstance();
var UID = FirebaseAuth.instance.currentUser?.uid;
SwipeableCardSectionController _cardController = SwipeableCardSectionController();
String localData = '';
bool startad = false;
var userInfos;
bool onlyMyLocate = true;
int makeActions = 0;
String sex = '';
String opositeSex = '';
bool isSameSexAndOposite = false;
bool isPremium = false;
bool _notificationsEnabled = false;

class MainTelaRoleta extends StatefulWidget {
  const MainTelaRoleta({super.key});

  @override
  State<MainTelaRoleta> createState() => _MainTelaRoletaState();
}

class _MainTelaRoletaState extends State<MainTelaRoleta> {
  var _currentIndex = 0;

  primeiroCheck() async {
    userInfos = await FirebaseFirestore.instance
        .collection("Usuarios")
        .doc(UID)
        .get();
    setState(() {
      //Sistema de assinaturas
      if(userInfos['AssinaturaTime'] == ""){
        isPremium = false;
        interAd(isPremium);
      }else{
        int totaymenostrinta = int.parse('${DateTime.now().month}${DateTime.now().day}${DateTime.now().year}') - 01000000;

        if(totaymenostrinta ==  int.parse("${userInfos['AssinaturaTime'].replaceAll('/', '')}")){
          isPremium = true;
        }else{
          isPremium = false;
          interAd(isPremium);
        }
      }
      startad = true;
    });

    FirebaseFirestore.instance.collection('Usuarios').doc(UID).update({
      'LocalizaçãoDefault': localData,
    });

    final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
    FlutterLocalNotificationsPlugin();

    final SharedPreferences prefs = await _prefs;

    String? negado = prefs.getString('Foi Negado');

    if(negado == 'false'){
      //não garantido
    }else{
      final bool granted = await flutterLocalNotificationsPlugin
          .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin>()
          ?.areNotificationsEnabled() ??
          false;

      if(granted == false){
        final AndroidFlutterLocalNotificationsPlugin? androidImplementation =
        flutterLocalNotificationsPlugin.resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>();

        final bool? granted = await androidImplementation?.requestPermission();
        _notificationsEnabled = granted ?? false;

        prefs.setString('Foi Negado', '$granted');
        //não garantido
      }else{
        _notificationsEnabled = granted;
        //garantido
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if(startad == false){
      primeiroCheck();
    }

    return LayoutBuilder(builder: (context, constrains){
      return Scaffold(
        appBar: AppBar(
          title: const Text('Arbor - Encontre alguém especial!'),
          centerTitle: true,
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              _currentIndex == 0
                  ? SizedBox(
                  width: double.infinity,
                  height: constrains.maxHeight - 265,
                  child: const SwapWidgets()
              )
                  :
              _currentIndex == 1 ?
              SizedBox(
                  width: double.infinity,
                  height: constrains.maxHeight - 265,
                  child: likeActivity(isPremium)
              )
                  :
              _currentIndex == 2?
              SizedBox(
                  width: double.infinity,
                  height: constrains.maxHeight - 265,
                  child: const ChatList()
              )
                  :
              SizedBox(
                  width: double.infinity,
                  height: constrains.maxHeight - 265,
                  child: profileSettings(isPremium)
              ),
              isPremium == false ? ElevatedButton(onPressed: (){
                sejaPremium(context);
              },
                  child: const Text('Se torne premium')
              ): Container(),
              AdBannerLayout(isPremium),
            ],
          ),
        ),
        bottomNavigationBar: SalomonBottomBar(
          currentIndex: _currentIndex,
          onTap: (i) => setState(() => _currentIndex = i),
          items: [
            /// Home
            SalomonBottomBarItem(
              icon: const Icon(Icons.home),
              title: Container(),
              selectedColor: Colors.red,
            ),

            /// Likes
            SalomonBottomBarItem(
              icon: const Icon(Icons.favorite_border),
              title: Container(),
              selectedColor: Colors.pink,
            ),

            /// Profile
            SalomonBottomBarItem(
              icon: const Icon(Icons.chat_bubble_outline_outlined),
              title: Container(),
              selectedColor: Colors.teal,
            ),

            /// Profile
            SalomonBottomBarItem(
              icon: const Icon(Icons.person),
              title: Container(),
              selectedColor: Colors.teal,
            ),
          ],
        ),
      );
    });
  }
}


class SwapWidgets extends StatefulWidget {
  const SwapWidgets({super.key});

  @override
  State<SwapWidgets> createState() => _SwapWidgetsState();
}

class _SwapWidgetsState extends State<SwapWidgets> {
  swapedToMakeAlgo() async {

    userInfos = await FirebaseFirestore.instance
        .collection("Usuarios")
        .doc(UID)
        .get();


    Position currentPosition = await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
    );
    List<Placemark> placemarks = await placemarkFromCoordinates(
      currentPosition.latitude,
      currentPosition.longitude,
    );

    Placemark placemark = placemarks.first;

    setState(() {
      onlyMyLocate = userInfos['exibirApenasEmMinhaLocalização'];
      localData = "${placemark.subAdministrativeArea}";
      sex = userInfos['Genero'];
      opositeSex = userInfos['GeneroProcura'];

      if(opositeSex == sex){
        isSameSexAndOposite = true;
      }else{
        isSameSexAndOposite = false;
      }

      startad = true;
    });

    FirebaseFirestore.instance.collection('Usuarios').doc(UID).update({
      'LocalizaçãoDefault': localData,
    });
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (context, constrains){

      if(startad == false){
        swapedToMakeAlgo();
        return const Center(
            child: CircularProgressIndicator()
        );
      }

      startad = true;

      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Container(
              height: constrains.maxHeight,
              width: double.infinity,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                border: Border.all(
                  color: Colors.black,
                  width: 1.0,
                ),
                borderRadius: const BorderRadius.all(Radius.circular(5.0)),
              ),
              child: StreamBuilder(
                  stream: onlyMyLocate == true ?
                  isSameSexAndOposite == true ?
                  FirebaseFirestore
                      .instance
                      .collection('Usuarios')
                      .where("uid", isNotEqualTo: UID)
                      .where("LocalizaçãoDefault", isEqualTo: localData)
                      .where('GeneroProcura', isEqualTo: sex)
                      .where('Genero', isEqualTo: sex)
                      .snapshots() :
                  FirebaseFirestore
                      .instance
                      .collection('Usuarios')
                      .where("uid", isNotEqualTo: UID)
                      .where("LocalizaçãoDefault", isEqualTo: localData)
                      .where('GeneroProcura', isEqualTo: sex)
                      .where('Genero', isEqualTo: opositeSex)
                      .snapshots()
                      :
                  isSameSexAndOposite == true ?
                  FirebaseFirestore
                      .instance
                      .collection('Usuarios')
                      .where("uid", isNotEqualTo: UID)
                      .where('GeneroProcura', isEqualTo: sex)
                      .where('Genero', isEqualTo: sex)
                      .snapshots()
                  :
                  FirebaseFirestore
                      .instance
                      .collection('Usuarios')
                      .where("uid", isNotEqualTo: UID)
                      .where('GeneroProcura', isEqualTo: sex)
                      .where('Genero', isEqualTo: opositeSex)
                      .snapshots(),
                  builder: (BuildContext context,
                      AsyncSnapshot<QuerySnapshot> snapshot) {
                    if (!snapshot.hasData) {
                      return const Center(
                        child: CircularProgressIndicator(),
                      );
                    }
                    return Stack(
                      children: snapshot.data!.docs.map((documents) {
                        if(documents['swaped'].contains(UID)){
                          return Container();
                        }else{
                          if(documents['Idade'] >= userInfos['idadeProcuraMin'] && documents['Idade'] <= userInfos['idadeProcura']){
                            return SwipeableCardsSection(
                              cardController: _cardController,
                              context: context,
                              items: [
                                Card(
                                  child: Stack(
                                    children: [
                                      SizedBox.expand(
                                        child: Material(
                                          borderRadius: BorderRadius.circular(12.0),
                                          child: Image.network(documents['urlfoto01']),
                                        ),
                                      ),
                                      SizedBox.expand(
                                        child: Container(
                                          decoration: const BoxDecoration(
                                              gradient: LinearGradient(
                                                  colors: [Colors.transparent, Colors.black54],
                                                  begin: Alignment.center,
                                                  end: Alignment.bottomCenter
                                              )
                                          ),
                                        ),
                                      ),
                                      Align(
                                        alignment: Alignment.bottomLeft,
                                        child: Container(
                                            padding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 16.0),
                                            child: Column(
                                              mainAxisAlignment: MainAxisAlignment.end,
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              children: <Widget>[
                                                Text(documents['Nome'],
                                                    style: const TextStyle(
                                                        color: Colors.white,
                                                        fontSize: 20.0,
                                                        fontWeight: FontWeight.w700)),
                                                const Padding(
                                                    padding: EdgeInsets.only(bottom: 8.0)
                                                ),
                                                Text("${documents['Detalhes']}",
                                                    textAlign: TextAlign.start,
                                                    style: const TextStyle(color: Colors.white)
                                                ),
                                              ],
                                            )
                                        ),
                                      ),
                                      Container(
                                        padding: const EdgeInsets.all(70),
                                        child: Align(
                                          alignment: Alignment.bottomRight,
                                          child: ElevatedButton(onPressed: () async {
                                            setState(() {
                                              makeActions ++;
                                            });

                                            if(makeActions == 15){
                                              //TODO recheck location and exibir anuncio
                                              swapedToMakeAlgo();
                                              setState(() {
                                                makeActions = 0;
                                              });
                                              if(isPremium == false){
                                                interAd(isPremium);
                                              }
                                            }

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
                                          },
                                              child: const Icon(Icons.favorite)
                                          ),
                                        ),
                                      ),
                                      Container(
                                        padding: const EdgeInsets.all(70),
                                        child: Align(
                                          alignment: Alignment.bottomLeft,
                                          child: ElevatedButton(onPressed: () async {
                                            setState(() {
                                              makeActions ++;
                                            });

                                            if(makeActions == 15){
                                              //TODO recheck location and exibir anuncio
                                              swapedToMakeAlgo();
                                              setState(() {
                                                makeActions = 0;
                                              });
                                              if(isPremium == false){
                                                interAd(isPremium);
                                              }
                                            }

                                            var resulte = await FirebaseFirestore.instance
                                                .collection("Usuarios")
                                                .doc(UID)
                                                .get();

                                            List listLike = documents['like'];
                                            List swapList = documents['swaped'];
                                            //todo swap;


                                            listLike.add('false $UID');
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
                                              });
                                            });

                                          },
                                              child: const Icon(Icons.close)
                                          ),
                                        ),
                                      ),
                                      Container(
                                        padding: const EdgeInsets.all(70),
                                        child: Align(
                                          alignment: Alignment.bottomCenter,
                                          child: ElevatedButton(onPressed: (){
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
                                          },
                                              child: const Icon(Icons.chat_bubble)
                                          ),
                                        ),
                                      )
                                    ],
                                  ),
                                ),
                              ],
                              //Get card swipe event callbacks
                              onCardSwiped: (dir, index, widget) async {

                                var resulte = await FirebaseFirestore.instance
                                    .collection("Usuarios")
                                    .doc(UID)
                                    .get();

                                List listLike = documents['like'];
                                List swapList = documents['swaped'];
                                //todo swap;

                                //Liked
                                if(dir.toString() == 'Direction.right'){
                                  setState(() {
                                    makeActions ++;
                                  });

                                  if(makeActions == 15){
                                    //TODO recheck location and exibir anuncio
                                    swapedToMakeAlgo();
                                    setState(() {
                                      makeActions = 0;
                                    });
                                    if(isPremium == false){
                                      interAd(isPremium);
                                    }
                                  }

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
                                }
                                //Desliked
                                if(dir.toString() == 'Direction.left'){
                                  setState(() {
                                    makeActions ++;
                                  });

                                  if(makeActions == 15){
                                              //TODO recheck location and exibir anuncio
                                              swapedToMakeAlgo();
                                              setState(() {
                                                makeActions = 0;
                                              });
                                              if(isPremium == false){
                                                interAd(isPremium);
                                              }
                                            }

                                  var resulte = await FirebaseFirestore.instance
                                      .collection("Usuarios")
                                      .doc(UID)
                                      .get();

                                  List listLike = documents['like'];
                                  List swapList = documents['swaped'];
                                  //todo swap;


                                  listLike.add('false $UID');
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
                                    });
                                  });
                                }
                              },
                              enableSwipeUp: true,
                              enableSwipeDown: false,
                            );
                          }else{
                            return Container();
                          }
                        }
                      }).toList(),
                    );
                  }
              ),
            ),
          ],
        ),
      );
    });
  }
}

