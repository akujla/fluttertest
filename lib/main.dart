import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:fluttertest/chat_screen.dart';
import 'package:fluttertest/loginscreen.dart';
import 'firebase_options.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
//import 'package:flutter_slidable/flutter_slidable.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      initialRoute: '/login_screen',
      routes: {
        '/main_screen': (context) => const MainScreen(),
        '/login_screen': (context) => const LoginScreen(),
        '/chat_screen': (context) => const ChatScreenWidget()
      },
      debugShowCheckedModeBanner: false,
      home: const MainScreen(),
    );
  }
}

class MainScreen extends StatelessWidget {
  const MainScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final Stream<QuerySnapshot> users =
        FirebaseFirestore.instance.collection('users').snapshots();
    CollectionReference collectionReference =
        FirebaseFirestore.instance.collection('users');
    void addToBase() {
      collectionReference.add({'name': 'Data', 'surname': 'Base', 'age': 10});
    }

    return Scaffold(
      appBar: AppBar(
        actions: [
          TextButton(
              onPressed: addToBase,
              child: const Text(
                'Upload',
                style: TextStyle(color: Colors.white),
              ))
        ],
      ),
      backgroundColor: Colors.grey,
      body: Center(
          child: SizedBox(
        width: MediaQuery.of(context).size.width * 0.7,
        height: MediaQuery.of(context).size.height * 0.7,
        child: StreamBuilder<QuerySnapshot>(
          stream: users,
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
                  itemCount: data.size,
                  itemBuilder: (context, index) {
                    return ListTile(
                      title: SizedBox(
                        child: Card(
                          child: Text(data.docs[index]['name'],
                              style: const TextStyle(fontSize: 30)),
                        ),
                      ),
                      subtitle: Text(data.docs[index]['surname']),
                      leading: ClipRRect(
                        borderRadius: BorderRadius.circular(20),
                        child: Container(
                          width: 100,
                          height: 50,
                          color: Colors.white,
                          child: Center(
                            child: Text(data.docs[index]['name'][0],
                                style: const TextStyle(fontSize: 40)),
                          ),
                        ),
                      ),
                      trailing: Text(
                        '${data.docs[index]['age']}',
                        style: const TextStyle(fontSize: 40),
                      ),
                    );
                  }),
            );
          },
        ),
      )),
    );
  }
}
