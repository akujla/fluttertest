import 'package:flutter/material.dart';
//import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
// import 'firebase_options.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ChatScreenWidget extends StatelessWidget {
  const ChatScreenWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: ChatWidget(),
    );
  }
}

class ChatWidget extends StatefulWidget {
  const ChatWidget({super.key});

  @override
  State<ChatWidget> createState() => _ChatWidgetState();
}

class _ChatWidgetState extends State<ChatWidget> {
  var messageController = TextEditingController();
  CollectionReference collectionReference =
      FirebaseFirestore.instance.collection('message');
  List idList = [];
  delMessage(int id) async {
    var ms = await FirebaseFirestore.instance.collection("message").get();

    var msd = ms.docs;
    var d = msd[id].id;
    await FirebaseFirestore.instance.collection('message').doc(d).delete();
  }

  var indexId = 0;
  @override
  Widget build(BuildContext context) {
    final Stream<QuerySnapshot> message = FirebaseFirestore.instance
        .collection('message')
        .orderBy("id", descending: true)
        .snapshots();
    addMessageToBase(int indexId) {
      if (messageController.text.isNotEmpty) {
        collectionReference.add({
          'userName': 'admin',
          'dateTime': DateTime.now().toString(),
          'body': messageController.text,
          'id': indexId
        });
        messageController.clear();
      } else {
        return;
      }
    }

    return SingleChildScrollView(
      child: Center(
        child: Column(children: [
          StreamBuilder<QuerySnapshot>(
            stream: message,
            builder: (context, snapshot) {
              if (snapshot.hasError) {
                return const Text('Erro');
              } else if (snapshot.connectionState == ConnectionState.waiting) {
                return const CircularProgressIndicator();
              }
              final data = snapshot.requireData;
              return SizedBox(
                width: 400,
                height: 400,
                child: ListView.builder(
                  reverse: true,
                  itemCount: data.size,
                  itemBuilder: (context, index) {
                    indexId = index;
                    return Slidable(
                      endActionPane: ActionPane(
                        motion: const ScrollMotion(),
                        children: [
                          // A SlidableAction can have an icon and/or a label.
                          SlidableAction(
                            onPressed: (ctx) => {delMessage(index)},
                            backgroundColor: const Color(0xFFFE4A49),
                            foregroundColor: Colors.white,
                            icon: Icons.delete,
                            label: 'Delete',
                          ),
                        ],
                      ),
                      key: const ValueKey(0),
                      child: ListTile(
                        leading: CircleAvatar(
                            child: Text(data.docs[index]['userName'][0])),
                        title: Text(data.docs[index]['body']),
                        trailing: Text(data.docs[index]['dateTime'].toString()),
                      ),
                    );
                  },
                ),
              );
            },
          ),
          SizedBox(
            width: MediaQuery.of(context).size.width * 0.4,
            child: TextField(
              onEditingComplete: () async {
                addMessageToBase(indexId);
              },
              controller: messageController,
              decoration: const InputDecoration(
                  labelText: 'Введите сообщение',
                  focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.green, width: 2)),
                  enabledBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.red, width: 2))),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: ElevatedButton(
                onPressed: () async {
                  addMessageToBase(indexId);
                },
                child: const Text('Отправить сообщение или просто ENTER')),
          )
        ]),
      ),
    );
  }
}
