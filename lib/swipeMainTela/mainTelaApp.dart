import 'package:arbor/AdsWidget/AdsWidget.dart';
import 'package:arbor/NotificationAPI/NotificationIntermediater.dart';
import 'package:arbor/bePremiumAlert/sejaPremium.dart';
import 'package:arbor/chatActivity/chatActivity.dart';
import 'package:arbor/chatActivity/chatList.dart';
import 'package:arbor/likeActivity/likeActivity.dart';
import 'package:arbor/profile/profile.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:salomon_bottom_bar/salomon_bottom_bar.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:swipeable_card_stack/swipeable_card_stack.dart';
import 'package:uuid/uuid.dart';

//Programado por HeroRickyGames

final Future<SharedPreferences> _prefs = SharedPreferences.getInstance();
var UID = FirebaseAuth.instance.currentUser?.uid;
SwipeableCardSectionController _cardController = SwipeableCardSectionController();
String localData = '';
bool startad = false;
bool startade = false;
var userInfos;
bool onlyMyLocate = true;
int makeActions = 0;
String sex = '';
String opositeSex = '';
bool isSameSexAndOposite = false;
bool isPremium = false;
bool _notificationsEnabled = false;

main(){
  WidgetsFlutterBinding.ensureInitialized();
}

class MainTelaRoleta extends StatefulWidget {
  const MainTelaRoleta({super.key});

  @override
  State<MainTelaRoleta> createState() => _MainTelaRoletaState();
}

class _MainTelaRoletaState extends State<MainTelaRoleta> {
  var _currentIndex = 0;

  primeiroCheck() async {
    intermeterNotifications();
    userInfos = await FirebaseFirestore.instance
        .collection("Usuarios")
        .doc(UID)
        .get();
    setState(() {
      //Sistema de assinaturas
      if(userInfos['AssinaturaTime'] == ""){
        if(userInfos['Debug'] == true){
          isPremium = true;
        }else{
          isPremium = false;
          interAd(isPremium);
        }
      }else{
        int totaymenostrinta = int.parse('${DateTime.now().month}${DateTime.now().day}${DateTime.now().year}') - 01000000;

        if(totaymenostrinta ==  int.parse("${userInfos['AssinaturaTime'].replaceAll('/', '')}")){
          isPremium = true;
        }else{
          if(userInfos['Debug'] == true){
            isPremium = true;
          }else{
            isPremium = false;
            interAd(isPremium);
          }
        }
      }
      startad = true;
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
      void interAdReward(bool isPremiumn) async {
        if(isPremiumn == false){
          MobileAds.instance.initialize();
          InterstitialAd? _interstitialAd;
          int _numInterstitialLoadAttempts = 0;
          const AdRequest request = AdRequest(
            keywords: <String>['foo', 'bar'],
            contentUrl: 'http://foo.com/bar.html',
            nonPersonalizedAds: true,
          );

          void _createInterstitialAd() {
            InterstitialAd.load(
                adUnitId: "ca-app-pub-1895475762491539/8805033305",
                request: request,
                adLoadCallback: InterstitialAdLoadCallback(
                  onAdLoaded: (InterstitialAd ad) {
                    _interstitialAd = ad;
                    _numInterstitialLoadAttempts = 0;
                    _interstitialAd!.setImmersiveMode(true);
                  },
                  onAdFailedToLoad: (LoadAdError error) {
                    _numInterstitialLoadAttempts += 1;
                    _interstitialAd = null;
                    if (_numInterstitialLoadAttempts < maxFailedLoadAttempts) {
                      _createInterstitialAd();
                    }
                  },
                ));
          }

          void _showInterstitialAd() {
            if (_interstitialAd == null) {
              return;
            }
            _interstitialAd!.fullScreenContentCallback = FullScreenContentCallback(
              onAdShowedFullScreenContent: (InterstitialAd ad) =>
                  print('ad onAdShowedFullScreenContent.'),
              onAdDismissedFullScreenContent: (InterstitialAd ad) {
                ad.dispose();
                _createInterstitialAd();
                setState(() {

                  isPremium = true;

                  setState(() {
                    const SwapWidgets();
                    likeActivity(isPremium);
                    const ChatList();
                    profileSettings(isPremium);
                  });

                });
                Fluttertoast.showToast(
                    msg: "Parabéns! Aproveite os recursos premium por esssa unica sessão!",
                    toastLength: Toast.LENGTH_SHORT,
                    gravity: ToastGravity.CENTER,
                    timeInSecForIosWeb: 1,
                    backgroundColor: Colors.red,
                    textColor: Colors.white,
                    fontSize: 16.0
                );
              },
              onAdFailedToShowFullScreenContent: (InterstitialAd ad, AdError error) {
                ad.dispose();
                _createInterstitialAd();
              },
            );
            _interstitialAd!.show();
            _interstitialAd = null;
          }
          _createInterstitialAd();
          showinterad() async {
            await Future.delayed(const Duration(seconds: 5));
            _showInterstitialAd();
          }
          showinterad();
        }else{

        }
      }

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
              _currentIndex == 0 ?
              SizedBox(
                width: double.infinity,
                height: constrains.maxHeight - 275,
                child: const SwapWidgets(),
              )
                  :
              _currentIndex == 1 ?
              SizedBox(
                  width: double.infinity,
                  height: constrains.maxHeight - 275,
                  child: likeActivity(isPremium)
              )
                  :
              _currentIndex == 2?
              SizedBox(
                  width: double.infinity,
                  height: constrains.maxHeight - 275,
                  child: const ChatList()
              )
                  :
              SizedBox(
                  width: double.infinity,
                  height: constrains.maxHeight - 275,
                  child: profileSettings(isPremium)
              ),
              isPremium == false ? Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    padding: const EdgeInsets.all(5),
                    child: ElevatedButton(onPressed: (){
                      sejaPremium(context);
                    },
                        child: const Text('Se torne premium')
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.all(5),
                    child: ElevatedButton(onPressed: (){
                      showDialog(
                        context: context,
                        builder: (BuildContext context) {
                          return AlertDialog(
                            title: const Center(
                                child: Text(
                                  'Seja Premium temporario!',
                                  style: TextStyle(
                                      fontSize: 24,
                                      fontWeight: FontWeight.bold
                                  ),
                                )
                            ),
                            actions: [
                              Container(
                                padding: const EdgeInsets.all(16),
                                child: Center(
                                  child: Column(
                                    children: [
                                      const Text(
                                        'Com o premium temporario você tem todos os recursos premium em uma unica sessão sem pagar nada!',
                                        textAlign: TextAlign.center,
                                        style: TextStyle(
                                            fontSize: 18,
                                            fontWeight: FontWeight.bold
                                        ),
                                      ),
                                      const Text(
                                        'Curtir e conversar pessoas que já te curtiram sem restrições',
                                        textAlign: TextAlign.center,
                                        style: TextStyle(
                                            fontSize: 18,
                                            fontWeight: FontWeight.bold
                                        ),
                                      ),
                                      const Text('Conheça pessoas do mundo todo!',
                                        textAlign: TextAlign.center,
                                        style: TextStyle(
                                            fontSize: 18,
                                            fontWeight: FontWeight.bold
                                        ),
                                      ),
                                      const Text('Mais opções!',
                                        textAlign: TextAlign.center,
                                        style: TextStyle(
                                            fontSize: 18,
                                            fontWeight: FontWeight.bold
                                        ),
                                      ),
                                      TextButton(onPressed: () async {
                                        Navigator.of(context).pop();
                                        interAdReward(isPremium);
                                        Fluttertoast.showToast(
                                            msg: "Aguarde um momento enquanto carregamos o anuncio...",
                                            toastLength: Toast.LENGTH_SHORT,
                                            gravity: ToastGravity.CENTER,
                                            timeInSecForIosWeb: 1,
                                            backgroundColor: Colors.red,
                                            textColor: Colors.white,
                                            fontSize: 16.0
                                        );
                                      }, child: const Text(
                                        'Seja premium temporario!',
                                        style: TextStyle(
                                            fontSize: 18,
                                            fontWeight: FontWeight.bold
                                        ),
                                      )
                                      )
                                    ],
                                  ),
                                ),
                              )
                            ],
                          );
                        },
                      );
                    },
                        child: const Text('Obtenha o premium temporario')
                    ),
                  ),
                ],
              ): Container(),
              AdBannerLayout(isPremium),
            ],
          ),
        ),
        bottomNavigationBar: SalomonBottomBar(
          currentIndex: _currentIndex,
          onTap: (i) {
            setState(() => _currentIndex = i);
          },
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
    WidgetsFlutterBinding.ensureInitialized();
    userInfos = await FirebaseFirestore.instance
        .collection("Usuarios")
        .doc(UID)
        .get();

    try{
      Position currentPosition = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );
      List<Placemark> placemarks = await placemarkFromCoordinates(
        currentPosition.latitude,
        currentPosition.longitude,
      );

      Placemark placemark = placemarks.first;
      WidgetsFlutterBinding.ensureInitialized();
      setState(() {
        if(userInfos['AssinaturaTime'] == ""){
          if(userInfos['Debug'] == true){
            onlyMyLocate = userInfos['exibirApenasEmMinhaLocalização'];
          }else{
            onlyMyLocate = true;
          }
        }else {
          int totaymenostrinta = int.parse('${DateTime
              .now()
              .month}${DateTime
              .now()
              .day}${DateTime
              .now()
              .year}') - 01000000;

          if (totaymenostrinta == int.parse("${userInfos['AssinaturaTime'].replaceAll('/', '')}")) {
            onlyMyLocate = userInfos['exibirApenasEmMinhaLocalização'];
          } else {
            if (userInfos['Debug'] == true) {
              onlyMyLocate = userInfos['exibirApenasEmMinhaLocalização'];
            } else {
              onlyMyLocate = true;
            }
          }
        }

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
    }catch(e){
      if(e.toString() == 'User denied permissions to access the device\'s location.'){
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (BuildContext context) {
            return AlertDialog(
              title: const Text('Detectamos um problema!'),
              actions: [
                const Center(
                  child: Text('Para melhor uso do aplicativo precisamos da permissão de localização ativa.'),
                ),
                Center(
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    child: TextButton(onPressed: () async {
                      LocationPermission permission;
                      permission = await Geolocator.requestPermission();
                      swapedToMakeAlgo();
                      Navigator.of(context).pop();
                    },
                        child: const Text('Habilitar a permissão')
                    ),
                  ),
                )
              ],
            );
          },
        );
      }
    }
  }

  @override
  void initState() {

    if (mounted) {
      WidgetsFlutterBinding.ensureInitialized();
      swapedToMakeAlgo();
    }

    super.initState();
  }
  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (context, constrains){

      if(startad == false){
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

                    if(snapshot.data!.docs.isEmpty){
                      return Center(
                        child: Stack(
                          children: [
                            startade == false ? Center(
                              child: CircularProgressIndicator(),
                            ): Container(),
                            Center(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.center,
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
                                    child: const Text('Não há ninguém perto de você ;-; não se preocupe, logo irá aparecer alguém proximo a você!'),
                                  ),
                                ],
                              ),
                            ),
                          ]
                        ),
                      );
                    }

                    startade = true;

                    return Stack(
                      children: snapshot.data!.docs.map((documents) {
                        if(documents['swaped'].contains(UID)){
                          return Positioned(child: Container());
                        }else{
                          if(documents['Idade'] >= userInfos['idadeProcuraMin'] && documents['Idade'] <= userInfos['idadeProcura']){
                            return SwipeableCardsSection(
                              cardController: _cardController,
                              context: context,
                              items: [
                                Card(
                                  child: Stack(
                                    children: [
                                      Positioned(
                                        child: SizedBox(
                                          child: Center(
                                            child: Material(
                                              borderRadius: BorderRadius.circular(12.0),
                                              child: Image.network(documents['urlfoto01']),
                                            ),
                                          ),
                                        ),
                                      ),
                                      Positioned(
                                        child: SizedBox(
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
                                      ),
                                      Positioned(
                                        child: Align(
                                          alignment: Alignment.bottomLeft,
                                          child: Container(
                                              padding: const EdgeInsets.symmetric(vertical: 125, horizontal: 25),
                                              child: Column(
                                                mainAxisAlignment: MainAxisAlignment.end,
                                                crossAxisAlignment: CrossAxisAlignment.start,
                                                children: <Widget>[
                                                  Row(
                                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                    children: [
                                                      Container(
                                                        padding: const EdgeInsets.all(10),
                                                        child: Text(documents['Nome'],
                                                            style: const TextStyle(
                                                                color: Colors.white,
                                                                fontSize: 20.0,
                                                                fontWeight: FontWeight.w700)),
                                                      ),
                                                      Container(
                                                        padding: const EdgeInsets.all(10),
                                                        child: Text("Idade: ${documents['Idade']}",
                                                            textAlign: TextAlign.start,
                                                            style: const TextStyle(
                                                                fontSize: 18,
                                                                color: Colors.white
                                                            )
                                                        ),
                                                      ),
                                                      Container(
                                                        padding: const EdgeInsets.all(10),
                                                        child: Text("Cidade: ${documents['LocalizaçãoDefault']}",
                                                            textAlign: TextAlign.start,
                                                            style: const TextStyle(
                                                                fontSize: 18,
                                                                color: Colors.white
                                                            )
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                  const Padding(
                                                      padding: EdgeInsets.only(bottom: 8.0)
                                                  ),
                                                  Text("${documents['Detalhes']}",
                                                      textAlign: TextAlign.start,
                                                      style: const TextStyle(
                                                          color: Colors.white
                                                      )
                                                  ),
                                                ],
                                              )
                                          ),
                                        ),
                                      ),
                                      Positioned(
                                        child: Container(
                                          padding: const EdgeInsets.all(20),
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
                                      ),
                                      Positioned(
                                        child: Container(
                                          padding: const EdgeInsets.all(20),
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
                                      ),
                                      Positioned(
                                        child: Container(
                                          padding: const EdgeInsets.all(20),
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
                            return Positioned(child: Container());
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