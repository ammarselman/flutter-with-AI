import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:io';

void main() {
  runApp(const MaterialApp(home: ImageWithPrediction()));
}

class ImageWithPrediction extends StatefulWidget {
  const ImageWithPrediction({super.key});

  @override
  State<ImageWithPrediction> createState() => _ImageWithPredictionState();
}

class _ImageWithPredictionState extends State<ImageWithPrediction> {
  File? _file;
  Map<String, dynamic> data = {};
  int? age = 0;
  String eth = "";
  String gender = "";
  bool loading = false;

  Future uploadimage() async {
    loading = true;
    final MyFlie = await ImagePicker().pickImage(source: ImageSource.gallery);
    setState(() {
      _file = File(MyFlie!.path);
      loading = false;
      age = 0;
      eth = "";
      gender = "";
    });
  }

  Future sendimage() async {
    if (_file == null) return print("image not uploaded");
    String base64 = base64Encode(_file!.readAsBytesSync());
    Map<String, String> requestHeader = {
      "Content-type": 'application/json',
      'Accept': 'application/json',
    };
    var response = await http.put(Uri.parse("http://10.0.2.2:5000/api"),
        body: base64, headers: requestHeader);

    setState(() {
      print(response.body);
      var result = response.body;
      var finalres = jsonDecode(result);
      data.addAll(finalres);
      data.toString();
      print(data);
      age = data["age"];
      eth = data["ethnicity"];
      gender = data["gender"];
      print(age);
      print(eth);
      print(gender);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: const Text(
          "Image with Prediction",
          style: TextStyle(
              fontWeight: FontWeight.bold,
              color: Colors.white,
              fontFamily: "DancingScript"),
        ),
        centerTitle: true,
      ),
      body: ListView(scrollDirection: Axis.vertical, children: [
        Center(
          child: Padding(
            padding: const EdgeInsets.all(60.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (loading)
                  const Center(
                    child: CircularProgressIndicator(),
                  ),
                _file == null
                    ? IconButton(
                        onPressed: () => uploadimage(),
                        icon: const Icon(Icons.upload_file_outlined),
                        iconSize: 35,
                      )
                    : Container(
                        decoration: BoxDecoration(
                          boxShadow: const [BoxShadow(color: Colors.black)],
                          borderRadius: BorderRadius.circular(15),
                        ),
                        child: Image.file(
                          _file!,
                        ),
                      ),
                Container(
                  width: 250,
                  height: 300,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: Container(
                    height: 200,
                    child: Column(
                      children: [
                        Text(
                          "Age is : $age years",
                          style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          "gender is :$gender",
                          style: const TextStyle(
                              fontSize: 15, fontWeight: FontWeight.bold),
                        ),
                        Text(
                          "ethic is : $eth",
                          style: const TextStyle(
                              fontSize: 15, fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                  ),
                ),
                Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                  TextButton(
                      style: const ButtonStyle(
                          backgroundColor:
                              MaterialStatePropertyAll(Colors.black)),
                      onPressed: () => uploadimage(),
                      child: const Row(
                        children: [
                          Text(
                            "Upload an image",
                            style: TextStyle(color: Colors.white),
                          ),
                          Icon(
                            Icons.upload_file,
                            color: Colors.white,
                          ),
                        ],
                      )),
                  Container(
                    width: 15,
                  ),
                  TextButton(
                      style: const ButtonStyle(
                          backgroundColor:
                              MaterialStatePropertyAll(Colors.black),
                          animationDuration: Duration(seconds: 2)),
                      onPressed: () => sendimage(),
                      child: const Row(children: [
                        Text(
                          "Predict",
                          style: TextStyle(color: Colors.white),
                        ),
                        Icon(
                          Icons.send,
                          color: Colors.white,
                        ),
                      ]))
                ])
              ],
            ),
          ),
        ),
      ]),
    );
  }
}
