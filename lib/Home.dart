import 'dart:io';
import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  List _listaTarefas = [];
  Map<String, dynamic> _ultimaTarefaRemovida = Map();
  Map<String, dynamic> _ultimaTarefaEditada = Map();
  TextEditingController _controllerTarefa = TextEditingController();

  Future<File> _getFile() async {
    final diretorio = await getApplicationDocumentsDirectory();
    //print(diretorio.path);
    return File("${diretorio.path}/dados.json");
  }

  _salvarTarefa() {
    String textoDigitado = _controllerTarefa.text;
    Map<String, dynamic> tarefa = Map();
    tarefa["titulo"] = textoDigitado;
    tarefa["realizada"] = false;
    setState(() {
      _listaTarefas.add(tarefa);
    });
    _salvarArquivo();
    _controllerTarefa.text = "";
  }

  _editarTarefa(index) {
    setState(() {
      String textoDigitado = _controllerTarefa.text;
      Map<String, dynamic> tarefa = Map();
      tarefa["titulo"] = textoDigitado;
      tarefa["realizada"] = _ultimaTarefaEditada["realizada"];
      _listaTarefas.insert(index, tarefa);
    });
    _salvarArquivo();
  }

  _salvarArquivo() async {
    var arquivo = await _getFile();
    String dados = json.encode(_listaTarefas);
    arquivo.writeAsString(dados);
  }

  _lerArquivo() async {
    try {
      final arquivo = await _getFile();
      return arquivo.readAsString();
    } catch (e) {
      return print(e);
    }
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _lerArquivo().then((dados) {
      setState(() {
        _listaTarefas = json.decode(dados);
      });
    });
  }

  Widget criarItemLista(context, index) {
    return Dismissible(
        key: Key(DateTime.now().millisecondsSinceEpoch.toString()),
        onDismissed: (direction) {
          if (direction == DismissDirection.endToStart) {
            _ultimaTarefaRemovida = _listaTarefas[index];
            _listaTarefas.removeAt(index);
            _salvarArquivo();
            //snackbar
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                behavior: SnackBarBehavior.floating,
                backgroundColor: Colors.red,
                content: Text("Tarefa removida"),
                action: SnackBarAction(
                    label: "Desfazer",
                    textColor: Colors.white,
                    onPressed: () {
                      setState(() {
                        _listaTarefas.insert(index, _ultimaTarefaRemovida);
                      });
                      _salvarArquivo();
                    })));
          } else if (direction == DismissDirection.startToEnd) {
            _controllerTarefa.text = _listaTarefas[index]["titulo"];
            _ultimaTarefaEditada = _listaTarefas[index];

            showDialog(
                context: context,
                builder: (context) {
                  return AlertDialog(
                    title: Text("adicionar tarefa"),
                    content: TextField(
                      controller: _controllerTarefa,
                      decoration:
                          InputDecoration(labelText: "Edite sua tarefa"),
                      onChanged: (text) {},
                    ),
                    actions: <Widget>[
                      TextButton(
                          child: Text("Cancelar"),
                          onPressed: () {
                            setState(() {});
                            _controllerTarefa.text = "";
                            Navigator.pop(context);
                          }),
                      TextButton(
                        child: Text("Salvar"),
                        onPressed: () {
                          _listaTarefas.removeAt(index);
                          _editarTarefa(index);
                          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                            behavior: SnackBarBehavior.floating,
                            backgroundColor: Colors.blue,
                            content: Text("Tarefa Editada"),
                          ));
                          Navigator.pop(context);
                        },
                      )
                    ],
                  );
                });
          }
        },
        background: Container(
          color: Colors.blue, // Cor de fundo para a ação de edição
          alignment: Alignment.centerRight,
          padding: EdgeInsets.all(16),
          child: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: <Widget>[Icon(Icons.edit, color: Colors.white)]),
        ),
        secondaryBackground: Container(
          color: Colors.red,
          padding: EdgeInsets.all(16),
          child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: <Widget>[Icon(Icons.delete, color: Colors.white)]),
        ),
        child: CheckboxListTile(
            title: Text(_listaTarefas[index]['titulo']),
            value: _listaTarefas[index]['realizada'],
            onChanged: (value) {
              setState(() {
                _listaTarefas[index]['realizada'] = value;
              });
              _salvarArquivo();
            }));
  }

  @override
  Widget build(BuildContext context) {
    //_salvarArquivo();
    return Scaffold(
      appBar: AppBar(
        title: Text("Lista de tarefas"),
        centerTitle: true,
      ),
      body: Column(children: <Widget>[
        Expanded(
            child: ListView.builder(
          itemCount: _listaTarefas.length,
          itemBuilder: criarItemLista,
        ))
      ]),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      //floatingActionButton: FloatingActionButton.extended(
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
        elevation: 10,
        //icon: Icon(Icons.add),
        //label: Text("Adicionar"),
        onPressed: () {
          showDialog(
              context: context,
              builder: (context) {
                return AlertDialog(
                  title: Text("adicionar tarefa"),
                  content: TextField(
                    controller: _controllerTarefa,
                    decoration: InputDecoration(labelText: "Digite sua tarefa"),
                    onChanged: (text) {},
                  ),
                  actions: <Widget>[
                    TextButton(
                      child: Text("Cancelar"),
                      onPressed: () => Navigator.pop(context),
                    ),
                    TextButton(
                      child: Text("Salvar"),
                      onPressed: () {
                        _salvarTarefa();
                        Navigator.pop(context);
                      },
                    )
                  ],
                );
              });
        },
        //mini: true,
        child: Icon(Icons.add),
      ),
      // bottomNavigationBar: BottomAppBar(
      //   color: Colors.blue,
      //   shape: CircularNotchedRectangle(),
      //   child: Row(children: <Widget>[
      //     IconButton(onPressed: null, icon: Icon(null))
      //   ]),
      // ));
    );
  }
}
