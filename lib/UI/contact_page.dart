import 'dart:async';
import 'dart:io';

import 'package:agenda_contato/Helpers/contact-helper.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class ContactPage extends StatefulWidget {
  final Contact contact;

  ContactPage({this.contact});

  @override
  _ContactPageState createState() => _ContactPageState();
}

class _ContactPageState extends State<ContactPage> {
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();

  final _focusName = FocusNode();

  bool _userEdited = false;
  Contact _editedContact;

  @override
  void initState() {
    super.initState();

    if (widget.contact == null) {
      _editedContact = Contact();
    } else {
      _editedContact = Contact.fromMap(widget.contact.toMap());

      _nameController.text = _editedContact.name;
      _emailController.text = _editedContact.email;
      _phoneController.text = _editedContact.phone;
    }
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: _requestPop,
      child: Scaffold(
        appBar: AppBar(
            backgroundColor: Colors.red,
            title: Text(_editedContact.name ?? "Novo Contato"),
            centerTitle: true),
        floatingActionButton: FloatingActionButton(
          onPressed: () {
            if (_editedContact.name != null && _editedContact.name.isNotEmpty) {
              Navigator.pop(context, _editedContact);
            } else {
              FocusScope.of(context).requestFocus(_focusName);
            }
          },
          child: Icon(
            Icons.save,
            color: Colors.white,
          ),
          backgroundColor: Colors.red,
        ),
        body: SingleChildScrollView(
          padding: EdgeInsets.all(10),
          child: Column(
            children: <Widget>[
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  GestureDetector(
                    onTap: () {
                      ImagePicker.pickImage(source: ImageSource.camera)
                          .then((file) {
                        if (file == null) {
                          return;
                        } else {
                          setState(() {
                            _editedContact.img = file.path;
                          });
                        }
                      });
                    },
                    child: Container(
                      margin: EdgeInsets.only(left: 20),
                      width: 140,
                      height: 140,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        image: DecorationImage(
                            image: _editedContact.img != null
                                ? FileImage(File(_editedContact.img))
                                : AssetImage("images/contact-null.png")),
                      ),
                    ),
                  ),
                  GestureDetector(
                    onTap: () {
                      ImagePicker.pickImage(source: ImageSource.gallery)
                          .then((file) {
                        if (file == null) {
                          return;
                        } else {
                          setState(() {
                            _editedContact.img = file.path;
                          });
                        }
                      });
                    },
                    child: Container(
                      margin: EdgeInsets.only(top: 100,),
                      width: 40,
                      height: 40,
                      child: Icon(Icons.image,color: Colors.white,),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color:Color.fromRGBO(88 , 89 , 91, 10)
                      ),
                    ),
                  ),
                ],
              ),
              TextField(
                focusNode: _focusName,
                controller: _nameController,
                decoration: InputDecoration(labelText: "Nome: "),
                onChanged: (text) {
                  _userEdited = true;
                  setState(() {
                    _editedContact.name = text;
                  });
                },
              ),
              TextField(
                controller: _emailController,
                decoration: InputDecoration(labelText: "E-mail: "),
                onChanged: (text) {
                  _userEdited = true;
                  _editedContact.email = text;
                },
                keyboardType: TextInputType.emailAddress,
              ),
              TextField(
                controller: _phoneController,
                decoration: InputDecoration(labelText: "Telefone: "),
                onChanged: (text) {
                  _userEdited = true;
                  _editedContact.phone = text;
                },
                keyboardType: TextInputType.phone,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<bool> _requestPop() {
    if (_userEdited) {
      showDialog(
          context: context,
          builder: (context) => AlertDialog(
                title: Text("Descartar alterações ?"),
                content: Text("Se sair as alterções serão perdidas"),
                actions: <Widget>[
                  FlatButton(
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      child: Text("Cancelar")),
                  FlatButton(
                      onPressed: () {
                        Navigator.pop(context);
                        Navigator.pop(context);
                      },
                      child: Text("Sim")),
                ],
              ));
      return Future.value(false);
    } else {
      return Future.value(true);
    }
  }
}
