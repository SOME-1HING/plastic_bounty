import 'dart:io';

import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';

class Uploader extends StatefulWidget {
  final File file;

  const Uploader({super.key, required this.file});

  @override
  State<Uploader> createState() => _UploaderState();
}

class _UploaderState extends State<Uploader> {
  final FirebaseStorage _storage =
      FirebaseStorage.instanceFor(bucket: "gs://plastic-bounty.appspot.com");

  final storageRef = FirebaseStorage.instance.ref();

  late UploadTask _uploadTask;

  void _startUpload() {
    String filePath = 'images/${DateTime.now()}.png';

    setState(() {
      _uploadTask = storageRef.child(filePath).putFile(widget.file);
    });
  }

  @override
  Widget build(BuildContext context) {
    return const Placeholder();
  }
}
