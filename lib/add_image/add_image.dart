import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class AddImage extends StatefulWidget {
  const AddImage(this.addImageFunc, {Key? key}) : super(key: key);

  final Function(File pickedImage) addImageFunc;

  @override
  _AddImageState createState() => _AddImageState();
}

class _AddImageState extends State<AddImage> {
  File? pickedImage;

  void _pickImage(ImageSource imageSource) async {
    final imagePicker = ImagePicker();
    final pickedImageFile = await imagePicker.pickImage(
        source: imageSource, imageQuality: 50, maxHeight: 150);
    setState(() {
      if (pickedImageFile != null) {
        pickedImage = File(pickedImageFile.path);
        if (pickedImage != null) {
          widget.addImageFunc(pickedImage!);
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(top: 10),
      width: 150,
      height: 300,
      child: Column(
        children: [
          InkWell(
            onTap: () => _pickImage(ImageSource.camera),
            child: CircleAvatar(
              radius: 40,
              backgroundColor: Colors.blue,
              backgroundImage:
                  pickedImage != null ? FileImage(pickedImage!) : null,
            ),
          ),
          SizedBox(
            height: 10,
          ),
          OutlinedButton.icon(
            onPressed: () {
              _pickImage(ImageSource.gallery);
            },
            icon: Icon(Icons.image),
            label: Text('갤러리 이미지 추가'),
          ),
          SizedBox(
            height: 80,
          ),
          TextButton.icon(
            onPressed: () {
              Navigator.pop(context);
            },
            icon: Icon(Icons.close),
            label: Text('닫기'),
          ),
        ],
      ),
    );
  }
}