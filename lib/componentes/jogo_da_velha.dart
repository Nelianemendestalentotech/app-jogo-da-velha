import 'package:flutter/material.dart';
import 'dart:math';

class JogoDaVelha extends StatefulWidget {
  const JogoDaVelha({super.key});

  @override
  State<JogoDaVelha> createState() => _JogoDaVelhaState();
}

class _JogoDaVelhaState extends State<JogoDaVelha> {
  List<String> tabuleiro = List.filled(9, '');
  String _jogador = 'X';
  bool _contraMaquina = false;
  bool _computadorPensando = false;

  void _iniciarJogo() {
    setState(() {
      tabuleiro = List.filled(9, '');
      _jogador = 'X';
      _computadorPensando = false;
    });
  }

  void _trocaJogador() {
    setState(() {
      _jogador = _jogador == 'X' ? 'O' : 'X';
    });
  }

  void _mostrarDialogoVencedor(String vencedor) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(vencedor == 'Empate' ? 'Empate!' : 'Vencedor: $vencedor'),
          actions: [
            ElevatedButton(
              child: const Text('Reiniciar Jogo'),
              onPressed: () {
                Navigator.of(context).pop();
                _iniciarJogo();
              },
            ),
          ],
        );
      },
    );
  }

  bool _verificaVencedor(String jogador) {
    const posicoesVencedoras = [
      [0, 1, 2],
      [3, 4, 5],
      [6, 7, 8],
      [0, 3, 6],
      [1, 4, 7],
      [2, 5, 8],
      [0, 4, 8],
      [2, 4, 6],
    ];

    for (var posicoes in posicoesVencedoras) {
      if (tabuleiro[posicoes[0]] == jogador &&
          tabuleiro[posicoes[1]] == jogador &&
          tabuleiro[posicoes[2]] == jogador) {
        _mostrarDialogoVencedor(jogador);
        return true;
      }
    }
    return false;
  }

  void _jogada(int index) {
    if (tabuleiro[index] == '') {
      setState(() {
        tabuleiro[index] = _jogador;
        if (_verificaVencedor(_jogador)) {
          _mostrarDialogoVencedor(_jogador);
        } else if (!tabuleiro.contains('')) {
          _mostrarDialogoVencedor('Empate');
        } else {
          _trocaJogador();
          if (_contraMaquina && _jogador == 'O') {
            setState(() {
              _computadorPensando = true;
            });
            Future.delayed(const Duration(seconds: 2), () {
              _jogadaComputador();
              setState(() {
                _computadorPensando = false;
              });
            });
          }
        }
      });
    }
  }

  void _jogadaComputador() {
    var rng = Random();
    int index;
    do {
      index = rng.nextInt(9);
    } while (tabuleiro[index] != '');
    _jogada(index);
  }

  @override
  Widget build(BuildContext context) {
    double altura = MediaQuery.of(context).size.height * 0.4;
    return Column(
      children: [
        Expanded(
          child: Row(
            children: [
              Transform.scale(
                scale: 0.6,
                child: Switch(
                  value: _contraMaquina,
                  onChanged: (value) {
                    setState(() {
                      _contraMaquina = value;
                    });
                  },
                ),
              ),
              Text(_contraMaquina ? 'Computador' : 'Humano'),
              if (_computadorPensando)
                const Padding(
                  padding: EdgeInsets.only(left: 5.0),
                  child: Row(
                    children: [
                      CircularProgressIndicator(),
                      SizedBox(height: 5.0, width: 15.0),
                      Text('Computador está pensando...'),
                    ],
                  ),
                ),
            ],
          ),
        ),
        Expanded(
          flex: 8,
          child: SizedBox(
            width: altura,
            height: altura,
            child: GridView.builder(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                crossAxisSpacing: 5.0,
                mainAxisSpacing: 5.0,
              ),
              itemCount: 9,
              itemBuilder: (context, index) {
                return GestureDetector(
                  onTap: () => _jogada(index),
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.blue[100],
                      borderRadius: BorderRadius.circular(5),
                    ),
                    child: Center(
                      child: Text(
                        tabuleiro[index],
                        style: const TextStyle(fontSize: 40.0),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ),
        Expanded(
          child: ElevatedButton(
            onPressed: _iniciarJogo,
            child: const Text('Reiniciar Jogo'),
          ),
        ),
      ],
    );
  }
}
