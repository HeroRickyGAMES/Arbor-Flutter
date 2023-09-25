import 'package:arbor/NotificationAPI/NotificationAPI.dart';
import 'package:arbor/firebase_options.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:shared_preferences/shared_preferences.dart';

//Programado por HeroRickyGames

intermeterNotifications() async {
  final Future<SharedPreferences> _prefs = SharedPreferences.getInstance();
  final SharedPreferences prefs = await _prefs;
  String? negado = prefs.getString('JaPegouDvTk');

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

  FirebaseMessaging.onMessage.listen((RemoteMessage message) async {

    var UID = FirebaseAuth.instance.currentUser?.uid;
    var ntf = await FirebaseFirestore.instance
        .collection("Usuarios")
        .doc(UID)
        .get();
    if(ntf.exists){
      if(message.data['idSender'] == UID){

      }else{
        if(message.data['id1'] == UID || message.data['id2'] == UID){
          NotificationApi.showNotification(
              title: '${message.data['title']}',
              body: '${message.data['body']}',
              payload: 'hrg.ntf'
          );
        }
      }


    }
  }).onError((e){
  });

  if(negado == null){
    final fcmToken = await FirebaseMessaging.instance.getToken();

    FirebaseFirestore.instance.collection('DeviceTokens').doc().set({
      'token': fcmToken
    });
    prefs.setString('JaPegouDvTk', 'Verdadeiro');
  }
}

Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  var UID = FirebaseAuth.instance.currentUser?.uid;
  var ntf = await FirebaseFirestore.instance
      .collection("Usuarios")
      .doc(UID)
      .get();
  if(ntf.exists){
    if(message.data['idSender'] == UID){

    }else{
      List mensageList = [];

      if(message.data['id1'] == UID || message.data['id1'] == UID){
        mensageList.add(message.data['body']);

        NotificationApi.showNotification(
            title: '${message.data['title']}',
            body: '${mensageList.toString()}',
            payload: 'hrg.ntf'
        );

      }
    }
  }
}