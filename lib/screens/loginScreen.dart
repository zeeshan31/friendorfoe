import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:friendorfoe/screens/waitingScreen.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final TextEditingController _nameController = TextEditingController();

    void _showJoinRoomDialog() {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          final TextEditingController _roomController = TextEditingController();
          return AlertDialog(
            title: Text('Enter Room Code'),
            content: TextField(
              controller: _roomController,
              decoration: InputDecoration(hintText: 'Room Code'),
            ),
            actions: [
              TextButton(
                child: Text('Cancel'),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
              TextButton(
                child: Text('Join'),
                onPressed: () async {
                  final roomCode = _roomController.text;
                  final roomSnapshot = await FirebaseFirestore.instance.collection('rooms').doc(roomCode).get();
                  if (roomSnapshot.exists) {
                    Navigator.of(context).pop();
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => RoomScreen(
                          isCreatingRoom: false,
                          userName: _nameController.text,
                          roomCode: roomCode,
                        ),
                      ),
                    );
                  } else {
                    Navigator.of(context).pop();
                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Room does not exist')));
                  }
                },
              ),
            ],
          );
        },
      );
    }

    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: Stack(
        children: [
          Container(
            decoration: BoxDecoration(
              image: DecorationImage(
                image: AssetImage("assets/Login.png"),
                fit: BoxFit.cover,
              ),
            ),
          ),
          Center(
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    SizedBox(height: 100,),
                    TextField(
                      controller: _nameController,
                      decoration: InputDecoration(
                        fillColor: Color.fromARGB(255, 239, 82, 71),
                        filled: true,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.all(Radius.circular(12)),
                        ),
                        hintText: 'Enter Your Name',
                      ),
                    ),
                    SizedBox(height: 10,),
                    ElevatedButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => RoomScreen(
                              isCreatingRoom: true,
                              userName: _nameController.text,
                            ),
                          ),
                        );
                      },
                      child: Text('Create Room'),
                    ),
                    ElevatedButton(
                      onPressed: _showJoinRoomDialog,
                      child: Text('Join Room'),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
