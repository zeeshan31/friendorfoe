import 'dart:math';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class RoomScreen extends StatefulWidget {
  final bool isCreatingRoom;
  final String userName;
  final String roomCode;

  RoomScreen({required this.isCreatingRoom, required this.userName, this.roomCode = ''});

  @override
  _RoomScreenState createState() => _RoomScreenState();
}

class _RoomScreenState extends State<RoomScreen> {
  final CollectionReference roomsRef = FirebaseFirestore.instance.collection('rooms');
  late String _roomCode;
  List<String> participants = [];

  @override
  void initState() {
    super.initState();
    if (widget.isCreatingRoom) {
      _createRoom();
    } else {
      _roomCode = widget.roomCode;
      _joinRoom();
    }
  }

  void _createRoom() async {
    _roomCode = _generateRoomCode();
    DocumentReference roomRef = roomsRef.doc(_roomCode);
    
    print('Attempting to create room with code: $_roomCode');
    
    // Create new room
    try {
      await roomRef.set({
        'creator': widget.userName,
        'players': {widget.userName: true},
      });
      _listenForParticipants();
      print('Room created successfully with code: $_roomCode');
    } catch (error) {
      print('Failed to create room: $error');
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $error')));
    }
  }

  String _generateRoomCode() {
    final random = Random();
    return (random.nextInt(90000) + 10000).toString();
  }

  void _joinRoom() async {
    DocumentReference roomRef = roomsRef.doc(_roomCode);
    
    print('Attempting to join room with code: $_roomCode');
    
    // Check if room exists
    DocumentSnapshot snapshot = await roomRef.get();
    if (snapshot.exists) {
      try {
        await roomRef.update({
          'players.${widget.userName}': true,
        });
        _listenForParticipants();
        print('Joined room successfully');
      } catch (error) {
        print('Failed to join room: $error');
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $error')));
      }
    } else {
      print('Room does not exist');
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Room does not exist')));
    }
  }

  void _listenForParticipants() {
    roomsRef.doc(_roomCode).snapshots().listen((snapshot) {
      if (snapshot.exists) {
        final data = snapshot.data() as Map<String, dynamic>;
        final playersMap = data['players'] as Map<String, dynamic>;
        setState(() {
          participants = playersMap.keys.toList();
        });
        print('Current participants: $participants');
      }
    });
  }

  void _navigateToGamePage() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => GamePage(roomCode: _roomCode, userName: widget.userName)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Waiting Room'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('Room Code: $_roomCode', style: TextStyle(fontSize: 24)),
            if (widget.isCreatingRoom)
              ElevatedButton(
                onPressed: _navigateToGamePage,
                child: Text('Start Game'),
              ),
            SizedBox(height: 20),
            Text('Participants:', style: TextStyle(fontSize: 20)),
            ...participants.map((participant) => Text(participant)).toList(),
          ],
        ),
      ),
    );
  }
}

class GamePage extends StatelessWidget {
  final String roomCode;
  final String userName;

  GamePage({required this.roomCode, required this.userName});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Game Room'),
      ),
      body: Center(
        child: Text('Welcome to the game, $userName! Room Code: $roomCode'),
      ),
    );
  }
}
