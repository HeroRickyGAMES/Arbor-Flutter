import 'dart:convert';
import 'dart:io';
import 'package:arbor/MercadoPagoAPI/MercadoPagoCheckoutAndroid.dart';
import 'package:arbor/NotificationAPI/NotificationAPI.dart';
import 'package:clipboard/clipboard.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:http/http.dart' as http;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:uuid/uuid.dart';

//Programado por HeroRickyGames

bool AlertIniciado = false;
bool geradoPix = false;
double valorRs = 9.99;
var UID = FirebaseAuth.instance.currentUser?.uid;
String idCompra = '';
String jasetada = '';


sejaPremium(context){
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: const Center(
            child: Text(
                'Seja Premium!',
              style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold
              ),
            )
        ),
        actions: [
          Center(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text('Sem anuncios',
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
                Container(
                  padding: const EdgeInsets.all(5),
                  child: Text('Por R\$$valorRs por um mês em premium aproveite todas essas vantagens!',
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold
                    ),
                  ),
                ),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    TextButton(onPressed: (){
                            Navigator.of(context).pop();
                    },
                        child: const Text('Não obrigado!')
                    ),
                      TextButton(onPressed: () async {
                        Navigator.of(context).pop();
                        showDialog(
                          context: context,
                          builder: (BuildContext context) {
                            double seisMesesInt = valorRs + valorRs + valorRs + valorRs + valorRs + valorRs - 3;
                            String seisMeses = seisMesesInt.toStringAsFixed(2);

                            double dozeMesesdouble = seisMesesInt + seisMesesInt - 3;
                            String dozeMeses = dozeMesesdouble.toStringAsFixed(2);

                            return AlertDialog(
                              title: const Text('A assinatura é feita por mes!'),
                              actions: [
                                Center(
                                  child: Column(
                                    children: [
                                      const Text('Você pode usar um mês, dois meses ou até três meses!'),
                                      Text(
                                          '1 Mês: R\$$valorRs',
                                        textAlign: TextAlign.center,
                                        style: const TextStyle(
                                            fontSize: 18,
                                            fontWeight: FontWeight.bold
                                        ),
                                      ),
                                      Text(
                                          '3 Meses: R\$${valorRs + valorRs + valorRs - 3}',
                                        textAlign: TextAlign.center,
                                        style: const TextStyle(
                                            fontSize: 18,
                                            fontWeight: FontWeight.bold
                                        ),
                                      ),
                                      Text(
                                          '6 Meses: R\$${seisMeses}',
                                        textAlign: TextAlign.center,
                                        style: const TextStyle(
                                            fontSize: 18,
                                            fontWeight: FontWeight.bold
                                        ),
                                      ),
                                      Text(
                                          '12 Meses: R\$${dozeMeses}',
                                        textAlign: TextAlign.center,
                                        style: const TextStyle(
                                            fontSize: 18,
                                            fontWeight: FontWeight.bold
                                        ),
                                      ),
                                      TextButton(onPressed: (){
                                        assinaturaPIX(context, valorRs, 0, 0);

                                        }, child: const Text(
                                          'Assine 1 mês!',
                                        style: TextStyle(
                                            fontSize: 18,
                                            fontWeight: FontWeight.bold
                                        ),
                                      )
                                      ),
                                      TextButton(onPressed: (){
                                        assinaturaPIX(context, valorRs + valorRs + valorRs - 3, 0300000, 60);
                                        }, child: const Text(
                                          'Assine 3 meses!',
                                        style: TextStyle(
                                            fontSize: 18,
                                            fontWeight: FontWeight.bold
                                        ),
                                      )
                                      ),
                                      TextButton(onPressed: (){
                                        assinaturaPIX(context, double.parse(seisMeses), 0600000, 183);
                                        }, child: const Text(
                                          'Assine 6 meses!',
                                        style: TextStyle(
                                            fontSize: 18,
                                            fontWeight: FontWeight.bold
                                        ),
                                      )
                                      ),
                                      TextButton(onPressed: (){
                                        assinaturaPIX(context, double.parse(dozeMeses), 0000001, 365);
                                      }, child: const Text(
                                          'Assine 12 meses!',
                                        style: TextStyle(
                                            fontSize: 18,
                                            fontWeight: FontWeight.bold
                                        ),
                                      )
                                      ),
                                    ],
                                  ),
                                )
                              ],
                            );
                          },
                        );
                       },
                        child: const Text(
                            'Seja Premium!',
                          style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold
                          ),
                        )
                    ),
                  ],
                ),
              ],
            ),
          )
        ],
      );
    },
  );
}

assinaturaPIX(context, double Valor, int maisDate, int days){
  Navigator.of(context).pop();
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return StatefulBuilder(builder: (BuildContext context, StateSetter setStatee){
        return Container(
          child: AlertDialog(
            title: const Text('Temos pagamentos em PIX e Cartão.'),
            actions: [
              Center(
                child: Column(
                  children: [
                    TextButton(onPressed: () async {
                      const String url = 'https://api.mercadopago.com/v1/payments';
                      String idPix = '';
                      String QRCode = '';

                      final Map<String, String> headers = {
                        'accept': 'application/json',
                        'content-type': 'application/json',
                        'Authorization':
                        'Bearer APP_USR-1043806088316304-112116-22728519f1efab60ee52f29f3f3f3487-306741183',
                      };

                      final Map<String, dynamic> data = {
                        "transaction_amount": Valor,
                        "description": "Test",
                        "payment_method_id": "pix",
                        "payer": {
                          "email": "test@gmail.com",
                          "first_name": "Test",
                          "last_name": "User",
                          "identification": {
                            "type": "CPF",
                            "number": "19119119100"
                          },
                          "address": {
                            "zip_code": "06233200",
                            "street_name": "Av. das Nações Unidas",
                            "street_number": "3003",
                            "neighborhood": "Bonfim",
                            "city": "Osasco",
                            "federal_unit": "SP"
                          }
                        }
                      };

                      final response = await http.post(
                        Uri.parse(url),
                        headers: headers,
                        body: jsonEncode(data),
                      );

                      Fluttertoast.showToast(
                          msg: "Aguarde enquanto geramos o PIX!",
                          toastLength: Toast.LENGTH_SHORT,
                          gravity: ToastGravity.CENTER,
                          timeInSecForIosWeb: 1,
                          backgroundColor: Colors.red,
                          textColor: Colors.white,
                          fontSize: 16.0
                      );
                      Navigator.of(context).pop();
                      showDialog(
                        context: context,
                        barrierDismissible: false,
                        builder: (BuildContext context) {
                          return StatefulBuilder(builder: (BuildContext context, StateSetter setState4){
                            verificarSeOPixFoiPagoOuNao(String idPixx) async {
                              final String urll = 'https://api.mercadopago.com/v1/payments/$idPixx';
                              final Map<String, String> headers = {
                                'Authorization':
                                'Bearer APP_USR-1043806088316304-112116-22728519f1efab60ee52f29f3f3f3487-306741183',
                              };

                              final response = await http.get(
                                Uri.parse(urll),
                                headers: headers,
                              );
                              if (response.statusCode == 200 || response.statusCode == 201) {
                                Map<String, dynamic> datax = json.decode(response.body);

                                if(datax['status'] == 'pending'){
                                  verificarSeOPixFoiPagoOuNao(idPix);
                                }else{
                                  setState4((){
                                    AlertIniciado = false;
                                  });

                                  var UIDUser = FirebaseAuth.instance.currentUser?.uid;

                                  String plataforma = Platform.isWindows == true ? 'Windows (Desktop)': Platform.isAndroid ? 'Android (Mobile)' : Platform.isLinux? 'Linux (Desktop)': 'Plataforma Desconhecida (É Desktop ou é Mobile, uai não sei kkkkkk)';
                                  var uuid = const Uuid();

                                  String idd = "${DateTime.now().toString()}${uuid.v4()}";
                                  int day = DateTime.now().day;

                                  if(day.bitLength == 1){
                                    day = int.parse("0${DateTime.now().day}");
                                  }

                                  DateTime dataAtual = DateTime.now();

                                  // Adicionando 3 meses
                                  DateTime dataVencimento = dataAtual.add(Duration(days: days));

                                  // Formatando a data
                                  String dataFormatada = DateFormat('dd/MM/yyyy').format(dataVencimento);

                                  FirebaseFirestore.instance.collection('PaymentsCollection').doc(idd).set({
                                    'UIDCompra': idd,
                                    'Status': datax['status'],
                                    'Origin': plataforma,
                                    'tipo': 'PIX',
                                    'Codigo pix': QRCode
                                  }).whenComplete(() {
                                    FirebaseFirestore.instance.collection('Usuarios').doc("$UIDUser").update({
                                      'AssinaturaTime': '$dataFormatada'
                                    }).whenComplete(() {
                                      NotificationApi.showNotification(
                                          title: 'Pagamento Realizado com sucesso!',
                                          body: 'Pagamento realizado com sucesso! Feche e abra o aplicativo para que as mudanças entrem em vigor!',
                                          payload: 'hrg.ntf'
                                      );

                                      Fluttertoast.showToast(
                                          msg: "Pagamento realizado com sucesso! Feche e abra o aplicativo para que as mudanças entrem em vigor!",
                                          toastLength: Toast.LENGTH_SHORT,
                                          gravity: ToastGravity.CENTER,
                                          timeInSecForIosWeb: 1,
                                          backgroundColor: Colors.red,
                                          textColor: Colors.white,
                                          fontSize: 16.0
                                      );
                                      Navigator.pop(context);
                                    });
                                  });
                                }
                              } else {
                                Fluttertoast.showToast(
                                    msg: "Ocorreu um erro ao verificar o estado do PIX, por favor contate o desenvolvedor do app!",
                                    toastLength: Toast.LENGTH_SHORT,
                                    gravity: ToastGravity.CENTER,
                                    timeInSecForIosWeb: 1,
                                    backgroundColor: Colors.red,
                                    textColor: Colors.white,
                                    fontSize: 16.0
                                );
                              }
                            }

                            getQRCode() async {
                              if(response.statusCode == 200 || response.statusCode == 201){
                                await Future.delayed(const Duration(seconds: 2));
                                Map<String, dynamic> datan = json.decode(response.body);

                                setState4((){
                                  QRCode = datan['point_of_interaction']['transaction_data']['qr_code'];
                                  idPix = "${datan['id']}";
                                  geradoPix = true;
                                });

                                verificarSeOPixFoiPagoOuNao(idPix);

                              }else{
                                Fluttertoast.showToast(
                                    msg: "Ocorreu um erro ao gerar o PIX!",
                                    toastLength: Toast.LENGTH_SHORT,
                                    gravity: ToastGravity.CENTER,
                                    timeInSecForIosWeb: 1,
                                    backgroundColor: Colors.red,
                                    textColor: Colors.white,
                                    fontSize: 16.0
                                );
                              }
                            }
                            if(AlertIniciado == false){
                              getQRCode();
                            }

                            AlertIniciado = true;
                            return AlertDialog(
                              title: geradoPix == true ? const Text('Agora é só escanear o código QR!'): const Text('Aguarde...'),
                              actions: [
                                Center(
                                  child:
                                  Column(
                                    children: [
                                      SizedBox(
                                        height: 200,
                                        width: 200,
                                        child:
                                        geradoPix == true ? QrImageView(
                                          data: "$QRCode",
                                          version: QrVersions.auto,
                                          size: 200.0,
                                          backgroundColor: Colors.white,
                                        ): const CircularProgressIndicator(),
                                      ),
                                      geradoPix == true ? const Text('Você também pode copiar a chave PIX copia e cola!'): Container(),
                                      geradoPix == true ? TextButton(onPressed: (){
                                        FlutterClipboard.copy("$QRCode").whenComplete((){
                                          Fluttertoast.showToast(
                                              msg: "Pix copiado com sucesso!",
                                              toastLength: Toast.LENGTH_SHORT,
                                              gravity: ToastGravity.CENTER,
                                              timeInSecForIosWeb: 1,
                                              backgroundColor: Colors.red,
                                              textColor: Colors.white,
                                              fontSize: 16.0
                                          );
                                        });
                                      }, child: const Text('Copiar chave pix copia e cola')
                                      ): Container(),
                                      TextButton(onPressed: (){
                                        Navigator.of(context).pop();
                                        AlertIniciado = false;
                                        geradoPix = false;
                                      }, child: const Text('Fechar')
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            );
                          },);
                        },
                      );

                    }, child: const Text('PIX')
                    ),
                    TextButton(onPressed: () async {

                      Fluttertoast.showToast(
                          msg: "Aguarde!",
                          toastLength: Toast.LENGTH_SHORT,
                          gravity: ToastGravity.CENTER,
                          timeInSecForIosWeb: 1,
                          backgroundColor: Colors.red,
                          textColor: Colors.white,
                          fontSize: 16.0
                      );
                      var server = await FirebaseFirestore.instance
                          .collection("Server")
                          .doc("ServerValues")
                          .get();
                      String AssToken = server.get('Access Token');
                      String PubKey = server.get('ChavePublica');

                      final access_token = AssToken;
                      const url = 'https://api.mercadopago.com/checkout/preferences';

                      final body = jsonEncode({
                        "items": [
                          {
                            "title": "Premium por um mês",
                            "description": "Usando recursos premium por um mes no app Arbor!",
                            "quantity": 1,
                            "currency_id": "ARS",
                            "unit_price": Valor
                          }
                        ],
                        "back_urls": {
                          "success": "https://herorickygames.github.io/Projeto-Pede-Facil-Entregadores/",
                          "failure": "https://www.google.com"
                        },
                        "payer": {
                          "email": "payer@email.com"
                        }
                      });

                      final response = await http.post(
                        Uri.parse('$url?access_token=$access_token'),
                        headers: {
                          'Content-Type': 'application/json',
                        },
                        body: body,
                      );

                      if(response.statusCode == 200 || response.statusCode == 201){
                        final preferenceId = jsonDecode(response.body)['id'];

                        var UIDUser = FirebaseAuth.instance.currentUser?.uid;

                        Navigator.of(context).pop();

                        Navigator.push(context,
                            MaterialPageRoute(builder: (context){
                              return ChekoutPayment(preferenceId, PubKey, UIDUser!, days);
                            }));

                      }else{
                        Fluttertoast.showToast(
                            msg: "Houve um errro de cominucação com o servidor, por favor contate-nos pela PlayStore!",
                            toastLength: Toast.LENGTH_SHORT,
                            gravity: ToastGravity.CENTER,
                            timeInSecForIosWeb: 1,
                            backgroundColor: Colors.red,
                            textColor: Colors.white,
                            fontSize: 16.0
                        );
                      }
                    }, child: const Text('Cartão')
                    ),
                  ],
                ),
              )
            ],
          ),
        );
      },);
    },
  );
}