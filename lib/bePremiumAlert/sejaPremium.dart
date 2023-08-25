import 'dart:convert';
import 'package:arbor/MercadoPagoAPI/MercadoPagoCheckoutAndroid.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:http/http.dart' as http;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

double valorRs = 9.90;

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
                        final url = 'https://api.mercadopago.com/checkout/preferences';

                        final body = jsonEncode({
                          "items": [
                            {
                              "title": "Premium por um mês",
                              "description": "Usando recursos premium por um mes no app Arbor!",
                              "quantity": 1,
                              "currency_id": "ARS",
                              "unit_price": valorRs
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
                                return ChekoutPayment(preferenceId, PubKey, UIDUser!);
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