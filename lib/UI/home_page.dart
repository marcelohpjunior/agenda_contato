import 'dart:io';

import 'package:agenda_contato/UI/contact_page.dart';
import 'package:flutter/material.dart';
import 'package:agenda_contato/Helpers/contact-helper.dart';
import 'package:url_launcher/url_launcher.dart';

enum OrderOptions{orderaz, orderza}

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  ContactHelper helper = ContactHelper();

  List<Contact> contacts = List();

  @override
  void initState() {
    super.initState();
    _getAllContacts();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Contatos"),
        backgroundColor: Colors.red,
        centerTitle: true,
        actions: <Widget>[
          PopupMenuButton<OrderOptions>(
              itemBuilder: (context)=><PopupMenuEntry<OrderOptions>>[
                const PopupMenuItem<OrderOptions>(child: Text("Ordernar de A-Z"),
                value: OrderOptions.orderaz,
                ),
                const PopupMenuItem<OrderOptions>(child: Text("Ordernar de Z-A"),
                  value: OrderOptions.orderza,
                )
              ],
             onSelected: _orderList,
          )
        ],
      ),
      backgroundColor: Colors.white,
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          _showContactPage();
        },
        child: Icon(Icons.add),
        backgroundColor: Colors.red,
      ),
      body: ListView.builder(
        itemBuilder: (context, index) {
          return _ContactCard(context, index);
        },
        itemCount: contacts.length,
        padding: EdgeInsets.all(10),
      ),
    );
  }

  Widget _ContactCard(BuildContext context, int index) {
    return GestureDetector(
      onLongPress: () => _showoptions(context, index),
      child: Card(
        child: Padding(
            padding: EdgeInsets.all(10),
            child: Row(
              children: <Widget>[
                Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    image: DecorationImage(
                        image: contacts[index].img != null
                            ? FileImage(File(contacts[index].img))
                            : AssetImage("images/contact-null.png")),
                  ),
                ),
                Padding(
                  padding: EdgeInsets.only(left: 10),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(
                        contacts[index].name ?? "",
                        style: TextStyle(
                            fontSize: 22, fontWeight: FontWeight.bold),
                      ),
                      Text(
                        contacts[index].email ?? "",
                        style: TextStyle(fontSize: 18),
                      ),
                      Text(
                        contacts[index].phone ?? "",
                        style: TextStyle(fontSize: 18),
                      ),
                    ],
                  ),
                ),
              ],
            )),
      ),
      onTap: () {
        _showoptions(context, index);

        //_showContactPage(contact: contacts[index]);
      },
    );
  }

  void _orderList(OrderOptions result){
    switch(result){
      case OrderOptions.orderaz:
        contacts.sort((a,b) {
          return a.name.toLowerCase().compareTo(b.name.toLowerCase());
        });
        break;
      case OrderOptions.orderza:
        contacts.sort((a,b) {
          return b.name.toLowerCase().compareTo(a.name.toLowerCase());
        });
        break;
    }
    setState(() {

    });
  }

  void _showoptions(BuildContext context, int index) {
    showModalBottomSheet(
        context: context,
        builder: (context) => BottomSheet(
              onClosing: () {},
              builder: (context) {
                return Container(
                  padding: EdgeInsets.all(10),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      Padding(
                        padding: EdgeInsets.all(10),
                        child: FlatButton(
                            onPressed: (){
                              launch("tel:${contacts[index].phone}");
                              Navigator.pop(context);
                            },
                            child: Text(
                              "Ligar",
                              style: TextStyle(color: Colors.red, fontSize: 20),
                            )),
                      ),
                      Padding(
                        padding: EdgeInsets.all(10),
                        child: FlatButton(
                            onPressed: () {
                              Navigator.pop(context);
                              _showContactPage(contact: contacts[index]);
                            },
                            child: Text(
                              "Editar",
                              style: TextStyle(color: Colors.red, fontSize: 20),
                            )),
                      ),
                      Padding(
                        padding: EdgeInsets.all(10),
                        child: FlatButton(
                            onPressed: (){
                              _deleteContact(index);
                            },
                            child: Text(
                              "Excluir",
                              style: TextStyle(color: Colors.red, fontSize: 20),
                            )),
                      ),
                    ],
                  ),
                );
              },
            ));
  }

  Future<bool> _deleteContact(int index){

      showDialog(context: context,
          builder: (context) => AlertDialog(
            title: Text("Excluir contato"),
            content: Text("Tem certeza que deseja excluir esse contato?"),
            actions: <Widget>[
              FlatButton(onPressed: (){
                Navigator.pop(context);
                Navigator.pop(context);

              },
                  child: Text("Não")),
              FlatButton(onPressed: (){
                Navigator.pop(context);
                helper.deleteContact(contacts[index].id);
                setState(() {
                  contacts.removeAt(index);
                  Navigator.pop(context);
                });
              },
                  child: Text("Sim")),
            ],
          ));
      return Future.value(false);
  }

  void _showContactPage({Contact contact}) async {
    final recContact = await Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => ContactPage(
                  contact: contact,
                )));
    if (recContact != null) {
      if (contact != null) {
        await helper.updateContact(recContact);
      } else {
        await helper.saveContact(recContact);
      }
      _getAllContacts();
    }
  }

  void _getAllContacts() {
    helper.getAllContact().then((list) {
      setState(() {
        contacts = list;
        _orderList(OrderOptions.orderaz);

      });
    });
  }
}
