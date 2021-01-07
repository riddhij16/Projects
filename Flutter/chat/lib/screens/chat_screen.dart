import 'package:chat/widgets/chats/new_message.dart';
import 'package:flutter/material.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../widgets/chats/messages.dart';

class ChatScreen extends StatefulWidget {
  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  @override
  void initState() {
    super.initState();
    final fbm = FirebaseMessaging();
    fbm.requestNotificationPermissions();
    fbm.configure(
      onMessage: (msg) {
        print(msg);
        return;
      },
      onLaunch: (message) {
        //when not even in bg..terminated
        print(message);
        return;
      },
      onResume: (message) {
        //app running in background but not currently being used
        print(message);
        return;
      },
    );
    fbm.subscribeToTopic('chat');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Chats'),
        actions: [
          DropdownButton(
            underline: Container(),
            icon: Icon(
              Icons.more_vert,
              color: Theme.of(context).primaryIconTheme.color,
            ),
            items: [
              DropdownMenuItem(
                child: Container(
                  child: Row(
                    children: <Widget>[
                      Icon(Icons.exit_to_app),
                      SizedBox(
                        width: 8,
                      ),
                      Text('Logout'),
                    ],
                  ),
                ),
                value: 'logout',
              ),
            ],
            onChanged: (itemIdentifier) => {
              if (itemIdentifier == 'logout') {FirebaseAuth.instance.signOut()}
            },
          ),
        ],
      ),
      body: Container(
          child: Column(
        children: <Widget>[
          Expanded(
            child: Messages(),
          ),
          NewMessage(),
        ],
      )),
    );
  }
}

//bcoz of snapshots(stream live listener to the collectioh) we do not need to save again after every change it will just be reflected automatically
////to get realtime aspect
//snapshots returns stream:emit new values whenever data changes

// Firestore.instance
//               .collection('chats/BzOKbffB8f5x8qn0xguB/messages')
//               .snapshots()
//               .listen((data) {
//             // print(data.documents[0]['text']);
//             data.documents.forEach((document) {
//               print(document['text']); //going through all docs
//             });

//use when not using stream builder..basically sb has its own listener
