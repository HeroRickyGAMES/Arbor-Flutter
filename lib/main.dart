import 'package:arbor/NotificationAPI/NotificationAPI.dart';
import 'package:arbor/firebase_options.dart';
import 'package:arbor/loginScreen/loginScreen.dart';
import 'package:arbor/swipeMainTela/mainTelaApp.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

//Desenvolvido por HeroRickyGames
final Future<SharedPreferences> _prefs = SharedPreferences.getInstance();

void main(){
  runApp(
    MaterialApp(
      theme: ThemeData(
          brightness: Brightness.dark,
          useMaterial3: true,
          elevatedButtonTheme: ElevatedButtonThemeData(
            style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                onPrimary: Colors.white
            ),
          ),
          appBarTheme: const AppBarTheme(
              backgroundColor: Colors.redAccent,
              titleTextStyle: TextStyle(
                  color: Colors.white
              )
          )
      ),
      home: const MainApp(),
    ),
  );
}

class MainApp extends StatefulWidget {
  const MainApp({super.key});

  @override
  State<MainApp> createState() => _MainAppState();
}

class _MainAppState extends State<MainApp> {

  checkIsLogin() async {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );

    FirebaseAuth.instance.idTokenChanges().listen((User? user) async {
      final SharedPreferences prefs = await _prefs;

      String? negado = prefs.getString('JaPegouDvTk');


      FirebaseMessaging.onMessage.listen((RemoteMessage message) async {
        print('Serviço de notificações está funcionando OK!');

        WidgetsFlutterBinding.ensureInitialized();
        await Firebase.initializeApp();
        FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

        var UID = FirebaseAuth.instance.currentUser?.uid;
        var ntf = await FirebaseFirestore.instance
            .collection("Usuarios")
            .doc(UID)
            .get();
        if(ntf.exists){
          NotificationApi.showNotification(
              title: '${message.data['title']}',
              body: '${message.data['body']}',
              payload: 'hrg.ntf'
          );

          print('Message data: ${message.data}');
          print('Message data: ${message.data['title']}');
          print('Message data: ${message.data['body']}');

        }else{

        }
        if (message.notification != null) {
          print('Message also contained a notification: ${message.notification}');
        }
      });

      if(negado == null){
        final fcmToken = await FirebaseMessaging.instance.getToken();

        FirebaseFirestore.instance.collection('DeviceTokens').doc().set({
          'token': fcmToken
        });
        prefs.setString('JaPegouDvTk', 'Verdadeiro');
      }

      if(user == null){
        Navigator.pop(context);
        Navigator.push(context,
            MaterialPageRoute(builder: (context){
              return const LoginScreen();
            }));
      }else{
        Navigator.pop(context);
        Navigator.push(context,
            MaterialPageRoute(builder: (context){
              return const MainTelaRoleta();
            }));
      }
    });
  }

  Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {

    print('Handling a background message ${message.messageId}');

    var UID = FirebaseAuth.instance.currentUser?.uid;
    var ntf = await FirebaseFirestore.instance
        .collection("Usuarios")
        .doc(UID)
        .get();
    if(ntf.exists){
      NotificationApi.showNotification(
          title: '${message.data['title']}',
          body: '${message.data['body']}',
          payload: 'hrg.ntf'
      );
      print('Message data: ${message.data}');
      print('Message data: ${message.data['title']}');
      print('Message data: ${message.data['body']}');

    }else{

    }
  }

  @override
  Widget build(BuildContext context) {
    checkIsLogin();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Fazer Login'),
        centerTitle: true,
      ),
    );
  }
}