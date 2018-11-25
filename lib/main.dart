import 'dart:io';

import 'package:async/async.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:cached_network_image/cached_network_image.dart';

main()=> runApp(UploadImageApp());

class UploadImageApp extends StatefulWidget{

  @override
  _UploadImageAppState createState() => _UploadImageAppState();

}

class _UploadImageAppState extends State<UploadImageApp>{

  List<String> urlimages = [];
  bool loading = false;

  @override
  Widget build(BuildContext cotext){

    return MaterialApp(
      home: Scaffold(
          appBar:  AppBar(title: Text("Image Upload"),centerTitle:  true,),
          floatingActionButton: FloatingActionButton(child: Icon(Icons.file_upload), onPressed: ()=>getGaleria() ,),
          body: buildListImages(),

      ),
    );
  }

  getGaleria() async {

    var fileName = await  ImagePicker.pickImage(source: ImageSource.gallery);
    upload(fileName);
  }

  upload(File imageFile) async{
    setState(() {
      loading = true;
      urlimages.insert(0, 'loading');

    });

    var stream = http.ByteStream(DelegatingStream.typed(imageFile.openRead()));
    var length =  await imageFile.length();
    var uri = Uri.parse('https://upload.uploadcare.com/base/');

    var request = http.MultipartRequest('POST', uri);
    var multipartFile = http.MultipartFile('uploadedfile', stream, length,  filename:  imageFile.path);

    request.files.add(multipartFile);
    request.fields.addAll({'UPLOADCARE_PUB_KEY': 'demopublickey'});

    var response = await request.send();

    response.stream.transform(utf8.decoder).listen( (value){
      final JsonDecoder decoder = JsonDecoder();
      dynamic map = decoder.convert(value ?? '');

      setState(() {
        urlimages[0] = map['uploadedfile'];
        loading = false;
      });
    });


  }

  showLoading(){

    if(loading)
      return new Center(
        child: new Padding(
          padding: const EdgeInsets.all(10.0),
          child: new SizedBox(child: CircularProgressIndicator(), height: 30.0, width: 30.0,),
        ),
      );
  }

  buildListImages(){

    var  iconPlaceHolder =  new Padding(
      padding: const EdgeInsets.all(50.0),
      child: Icon(Icons.image),
    );

    if(urlimages.isEmpty)
      return Center(child: Text("Nenhuma imagem enviada"),);
    else{
      return ListView.builder(
        itemCount: urlimages.length,
        itemBuilder: (context, index){

          if(index == 0 && loading){
             return showLoading();
          }else{

            return CachedNetworkImage(
              imageUrl: 'https://ucarecdn.com/${urlimages[index]}/',
              placeholder: iconPlaceHolder,
            );
          }

        },
      );


    }
  }

}