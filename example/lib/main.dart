import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'dart:async';
import 'dart:io';

import 'package:flutter/services.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';

import 'package:path_provider/path_provider.dart' as path_provider;
 import 'package:image_picker/image_picker.dart';

void main() => runApp(new MyApp());

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => new _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  void initState() {
    super.initState();
  }

  // Platform messages are asynchronous, so we initialize in an async method.
  Future<void> compress() async {
    var img = AssetImage("img/img.jpg");
    print("pre compress");
    var config = new ImageConfiguration();

    AssetBundleImageKey key = await img.obtainKey(config);
    final ByteData data = await key.bundle.load(key.name);

    var beforeCompress = data.lengthInBytes;
    print("beforeCompress = $beforeCompress");

    var result = await FlutterImageCompress.compressWithList(data.buffer.asUint8List());

    print("after = ${result?.length ?? 0}");
  }

  File _image;

  Future getImage() async {
    var image = await ImagePicker.pickImage(source: ImageSource.camera, maxWidth: 1920, maxHeight: 1080);

    setState(() {
      _image = image;
      image.readAsBytesSync();
//      provider = Image.file(image).image;

//      var x = testCompressFile(image);
//      print(x.runtimeType);

//      FlutterImageCompress.compressWithList(image.readAsBytesSync()).then((list) {
//        provider = Image.memory(Uint8List.fromList(list)).image;
//      });

      if(_image != null) {
//        print(_image.readAsBytes().then((bytes) => print(bytes.length)));

        FlutterImageCompress.compressWithList(image.readAsBytesSync()).then((list) {
          provider = Image.memory(Uint8List.fromList(list)).image;
        });

//        testCompressFile(image).then((bytes) {
//          _image = File.fromRawPath(Uint8List.fromList(bytes));
//          provider = Image.file(_image).image;
//        });
      }
    });
  }

  ImageProvider provider;

  @override
  Widget build(BuildContext context) {
    return new MaterialApp(
      home: new Scaffold(
        appBar: new AppBar(
          title: const Text('Plugin example app'),
        ),
        body: SingleChildScrollView(
          child: new Center(
            child: Column(
              children: <Widget>[
                AspectRatio(
                  child: Image(
                    image: provider ?? AssetImage("img/img.jpg"),
                    width: double.infinity,
                    fit: BoxFit.contain,
                  ),
                  aspectRatio: 1 / 1,
                ),
                FlatButton(
                  child: Text('Capture Image'),
                  onPressed: getImage,
                ),
                FlatButton(
                  child: Text('CompressFile and rotate 180'),
                  onPressed: _testCompressFile,
                ),
                FlatButton(
                  child: Text('CompressAndGetFile and rotate 90'),
                  onPressed: getFileImage,
                ),
                FlatButton(
                  child: Text('CompressAsset and rotate 135'),
                  onPressed: () => testCompressAsset("img/img.jpg"),
                ),
                FlatButton(
                  child: Text('CompressList and rotate 270'),
                  onPressed: compressListExample,
                ),
              ],
            ),
          ),
        ),
        floatingActionButton: FloatingActionButton(
          child: Icon(Icons.computer),
          onPressed: () => setState(() => this.provider = null),
          tooltip: "show origin asset",
        ),
      ),
    );
  }

  Future<Directory> getTemporaryDirectory() async {
    return Directory.systemTemp;
  }

  void _testCompressFile() async {
    var img = AssetImage("img/img.jpg");
    print("pre compress");
    var config = new ImageConfiguration();

    AssetBundleImageKey key = await img.obtainKey(config);
    final ByteData data = await key.bundle.load(key.name);
    var dir = await path_provider.getTemporaryDirectory();
    print('dir = $dir');

    File file = File("${dir.absolute.path}/test.png");
    file.writeAsBytesSync(data.buffer.asUint8List());

    List<int> list = await testCompressFile(file);
    ImageProvider provider = MemoryImage(Uint8List.fromList(list));
    this.provider = provider;
    setState(() {});
  }

  void getFileImage() async {
    var img = AssetImage("img/img.jpg");
    print("pre compress");
    var config = new ImageConfiguration();

    AssetBundleImageKey key = await img.obtainKey(config);
    final ByteData data = await key.bundle.load(key.name);
    var dir = await path_provider.getTemporaryDirectory();

    File file = File("${dir.absolute.path}/test.png");
    file.writeAsBytesSync(data.buffer.asUint8List());

    var targetPath = dir.absolute.path + "/temp.png";
    var imgFile = await testCompressAndGetFile(file, targetPath);

    provider = FileImage(imgFile);
    setState(() {});
  }

  Future<List<int>> testCompressFile(File file) async {
    print("testCompressFile");
    var result = await FlutterImageCompress.compressWithFile(
      file.absolute.path,
      minWidth: 2300,
      minHeight: 1500,
      quality: 94,
      rotate: 180,
    );
    print(file.lengthSync());
    print(result.length);
    return result;
  }

  Future<File> testCompressAndGetFile(File file, String targetPath) async {
    print("testCompressAndGetFile");
    var result = await FlutterImageCompress.compressAndGetFile(
      file.absolute.path,
      targetPath,
      quality: 90,
      minWidth: 1024,
      minHeight: 1024,
      rotate: 90,
    );

    print(file.lengthSync());
    print(result.lengthSync());

    return result;
  }

   Future<List<int>> _compressWithImageProvider(
       BuildContext context, ImageProvider provider,
       {int minWidth = 1920, int minHeight = 1080, int quality = 95}) async {
     var info = await getImageInfo(context, provider);
     var data = await info.image.toByteData();
     var list = data.buffer.asUint8List().toList();

     return FlutterImageCompress.compressWithList(
       list,
       minWidth: minWidth,
       minHeight: minHeight,
       quality: quality,
     );
   }

  Future testCompressAsset(String assetName) async {
    print("testCompressAsset");
    var list = await FlutterImageCompress.compressAssetImage(
      assetName,
      minHeight: 1920,
      minWidth: 1080,
      quality: 96,
      rotate: 135,
    );

    this.provider = MemoryImage(Uint8List.fromList(list));
    setState(() {});
  }

  Future compressListExample() async {
    var img = AssetImage("img/img.jpg");
    print("pre compress");
    var config = new ImageConfiguration();

    AssetBundleImageKey key = await img.obtainKey(config);
    final ByteData data = await key.bundle.load(key.name);
    var list = List<int>.from(data.buffer.asUint8List());

    // print(list);

    list = await testComporessList(list);

    var memory = Uint8List.fromList(list);
    setState(() {
      this.provider = MemoryImage(memory);
    });
  }

  Future<List<int>> testComporessList(List<int> list) async {
    var result = await FlutterImageCompress.compressWithList(
      list,
      minHeight: 1920,
      minWidth: 1080,
      quality: 96,
      rotate: 270,
    );
    print(list.length);
    print(result.length);
    return result;
  }

  void writeToFile(List<int> list, String filePath) {
    var file = File(filePath);
    file.writeAsBytes(list, flush: true, mode: FileMode.write);
  }
}
