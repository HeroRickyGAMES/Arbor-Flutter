import 'package:flutter/material.dart';

class SeeProfile extends StatefulWidget {
  String Nome = '';
  int Idade = 0;
  String Cidade = '';
  String descricao = '';
  String ImageURL = '';
  bool isInChats;
  SeeProfile(this.Nome, this.Idade, this.Cidade, this.descricao, this.ImageURL, this.isInChats, {super.key});

  @override
  State<SeeProfile> createState() => _SeeProfileState();
}
int _currentIndex = 0;
class _SeeProfileState extends State<SeeProfile> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: const Text('Perfil do usuário'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              child: Image.network(
                widget.ImageURL,
                scale: 2,
                width: 500,
                height: 500,
              )
            ),
            Container(
              padding: const EdgeInsets.all(16),
              child: Text("Nome: ${widget.Nome}"),
            ),
            Container(
              padding: const EdgeInsets.all(16),
              child: Text("Idade: ${widget.Idade}"),
            ),
            Container(
              padding: const EdgeInsets.all(16),
              child: Text("Cidade: ${widget.Cidade}"),
            ),
            Container(
              decoration: BoxDecoration(
                border: Border.all(
                  color: Colors.white,
                  width: 1.0,
                ),
                borderRadius: const BorderRadius.all(Radius.circular(5.0)),
              ),
              child: Container(
                padding: const EdgeInsets.all(16),
                child: Text("Descrição: ${widget.descricao}"),
              ),
            )
          ],
        ),
      ),
      bottomNavigationBar: BottomAppBar(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            widget.isInChats == false?
            Container(
              padding: const EdgeInsets.only(right: 16),
              child: ElevatedButton(onPressed: (){

              }, child: const Icon(Icons.chat_bubble_outline_outlined)
              ),
            ): Container(),
            widget.isInChats == false?
            ElevatedButton(onPressed: (){

            }, child: const Icon(Icons.favorite)
            ):Container(),
          ],
        ),
      )
    );
  }
}
