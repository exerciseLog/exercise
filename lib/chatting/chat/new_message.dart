import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';

class NewMessage extends StatefulWidget {
  const NewMessage({Key? key}) : super(key: key);

  @override
  _NewMessageState createState() => _NewMessageState();
}

class _NewMessageState extends State<NewMessage> {
  final _controller = TextEditingController();
  var _userEnterMessage = '';
  void _sendMessage() async {
    FocusScope.of(context).unfocus();
    final user = FirebaseAuth.instance.currentUser;
    final userData = await FirebaseFirestore.instance
        .collection('user')
        .doc(user!.uid)
        .get();
    FirebaseFirestore.instance.collection('chat').add({
      'text': _userEnterMessage,
      'time': DateFormat('yyyy-MM-dd HH:mm:ss').format(DateTime.now()),
      'userID': user.uid,
      'userName': userData.data()!['userName'],
      'userImage': userData['picked_image']
    });
    _controller.clear();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      // height: MediaQuery.of(context).size.height * 0.07,
      color: Color.fromARGB(255, 233, 232, 232),
      margin: EdgeInsets.only(top: 10),
      padding: const EdgeInsets.all(10),
      child: Row(
        children: [
          const SizedBox(
            width: 10,
          ),
          Expanded(
            child: TextField(
              maxLines: null,
              keyboardType: TextInputType.multiline,
              textCapitalization: TextCapitalization.sentences,
              controller: _controller,
              decoration: InputDecoration(
                suffixIcon: IconButton(
                  onPressed:
                      _userEnterMessage.trim().isEmpty ? null : _sendMessage,
                  icon: const Icon(Icons.send),
                  color: Colors.blue,
                  iconSize: 25,
                ),
                hintText: '메시지를 입력해 주세요...',
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 8.0, vertical: 10),
                hintStyle: const TextStyle(
                  fontSize: 16,
                ),
                fillColor: Colors.white,
                filled: true,
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(30.0),
                  borderSide: const BorderSide(
                    color: Colors.white,
                    width: 0.2,
                  ),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(30.0),
                  borderSide: const BorderSide(
                    color: Colors.black26,
                    width: 0.2,
                  ),
                ),
              ),
              onChanged: (value) {
                setState(() {
                  _userEnterMessage = value;
                });
              },
            ),
          ),
          const SizedBox(
            width: 10,
          ),
          // IconButton(
          //   onPressed: _userEnterMessage.trim().isEmpty ? null : _sendMessage,
          //   icon: Icon(Icons.send),
          //   color: Colors.blue,
          // ),
        ],
      ),
    );
  }
}
