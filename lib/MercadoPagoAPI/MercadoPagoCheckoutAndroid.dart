import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:intl/intl.dart';
import 'package:mercado_pago_mobile_checkout/mercado_pago_mobile_checkout.dart';

//Desenvolvido por HeroRIckyGames

class ChekoutPayment extends StatefulWidget {
  String idCompra;
  String id;
  String PubKey;
  int day;
  ChekoutPayment(this.idCompra,this.PubKey, this.id, this.day, {super.key});

  @override
  State<ChekoutPayment> createState() => _ChekoutPaymentState();
}

class _ChekoutPaymentState extends State<ChekoutPayment> {

  @override
  Widget build(BuildContext context) {
    String publicKey = widget.PubKey;
    String preferenceId = widget.idCompra;

    iniciarapi(context) async {

      PaymentResult result =
      await MercadoPagoMobileCheckout.startCheckout(
        publicKey,
        preferenceId,
      );
      if(result.result == 'done'){
        // Data atual
        DateTime dataAtual = DateTime.now();

        // Adicionando 3 meses
        DateTime dataVencimento = dataAtual.add(Duration(days: widget.day));

        // Formatando a data
        String dataFormatada = DateFormat('dd/MM/yyyy').format(dataVencimento);

        //todo algo
        FirebaseFirestore.instance.collection('PaymentsCollection').doc(widget.idCompra).set({
          'UIDCompra': widget.id,
          'idCompra': widget.idCompra,
          'Status': result.result,
          'Origin': 'Mobile (Android)',
          'tipo': '${result.paymentMethodId}',
        }).whenComplete(() {
          FirebaseFirestore.instance.collection('Usuarios').doc(widget.id).update({
            'AssinaturaTime': dataFormatada,
          }).whenComplete(() {
            Fluttertoast.showToast(
                msg: "Pagamento realizado com sucesso!",
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
        
      }else{
        if(result.result == 'canceled'){
          Navigator.pop(context);
        }else{
          FirebaseFirestore.instance.collection('PaymentsCollection').doc(widget.idCompra).set({
            'UIDCompra': widget.id,
            'idCompra': widget.idCompra,
            'Status': result.result,
            'Origin': 'Mobile (Android)',
            'tipo': 'Desconhecido',
          }).whenComplete(() {
            Fluttertoast.showToast(
                msg: "Ocorreu algum erro no pagamento e ele foi cancelado, tente trocar de cartão ou tentar novamente",
                toastLength: Toast.LENGTH_SHORT,
                gravity: ToastGravity.CENTER,
                timeInSecForIosWeb: 1,
                backgroundColor: Colors.red,
                textColor: Colors.white,
                fontSize: 16.0
            );

          });
        }
      }
    }

    iniciarapi(context);
    return Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.blue[200],
          centerTitle: true,
          title: const Text(
            'HRS Payments',
            style: TextStyle(
                color: Colors.black
            ),
          ),
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                  padding: const EdgeInsets.all(16),
                  child: const Text('Aguarde um momento!')
              ),
              Container(
                  padding: const EdgeInsets.all(16),
                  child: const CircularProgressIndicator()
              ),
            ],
          ),
        )
    );
  }
}