// ignore_for_file: avoid_print

import 'dart:io';

import 'package:cloud/image_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:file_picker/file_picker.dart';

import 'package:cloud/firebase_service.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:path/path.dart';
import 'package:permission_handler/permission_handler.dart';

class ImageView extends StatefulWidget {
  const ImageView({Key? key}) : super(key: key);

  @override
  State<ImageView> createState() => _ImageViewState();
}

class _ImageViewState extends State<ImageView> {
  bool _loading = false;

  void changeLoadingStatus() {
    setState(() {
      _loading = !_loading;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('ITU ACM SC')),
      body: StreamBuilder<QuerySnapshot<ImageModel>>(
        stream: FirebaseService.getImageModel(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return const Text('HATA...');
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          //* AsyncSnapshot<QuerySnapshot<ImageModel>> tipindeki datayı QuerySnapshot<ImageModel> tipindeki
          // * yeni değişkenimize atıyoruz.
          final data = snapshot.requireData;

          //* QuerySnapshot<ImageModel> tipindeki datamızı List<ImageModel> tipine oluşturduğumuz değişkene atıyoruz.
          List<ImageModel> _images =
              data.docs.map((e) => ImageModel.fromQuery(e)).toList();

          if (_images.isNotEmpty) {
            return _imageList(_images);
          } else {
            return const Center(child: Text('No Data'));
          }
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _loading ? null : () async => _addImage(),
        child: _loading
            ? const Center(
                child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              )
            : const Icon(Icons.add),
      ),
    );
  }

  Future<void> _addImage() async {
    try {
      //* izni sorguluyorum
      var status = await Permission.photos.request();

      if (status.isGranted || status.isLimited) {
        //* ihtiyacım olan değişkenleri oluşturuyorum
        File? file;
        UploadTask? task;

        //* statusu değiştiriyorum fab için
        changeLoadingStatus();

        //* imageı seçiyorum.
        final _picker = await FilePicker.platform.pickFiles(
          type: FileType.image,
        );

        //* image seçimini kontrol ediyorum seçilmediyse statusu değiştirip çıkıyorum.
        if (_picker == null) {
          changeLoadingStatus();
          return;
        }

        //* pickerde multiple seçim mümkün olduğu için pickerın ile seçtiğim
        //! [PLATFROMFILELARIN]
        //* birinin pathini path değişkenime atıyorum.
        final path = _picker.files.single.path!;

        //* buradaki path tüm dizin bu dizindeki path ile daha önceden oluşturduğum file dosyasına atıyorum.
        //* Özetle seçmiş olduğum imageın pathini yakalayarak yeni oluşturduğum dosyama atıyorum.
        print(path);
        file = File(path);

        //* basename fonk ile en son dizine giderek fileın adını alıyoruz.
        final fileName = basename(file.path);
        print(fileName);

        //* Burada fileımızı hangi dizine atacağımızı belirtiyoruz. images dizinine az önce oluşturduğumuz ad ile.
        //* images dizini yoksa da bizim için oluşturur.
        final destination = 'images/$fileName';

        //* storagea dosyamızı yüklüyoruz.
        task = await FirebaseService.uploadFile(destination, file);

        //* yüklemeyi kontrol ediyorum yüklenmediyse statusu değiştirip çıkıyorum.
        if (task == null) {
          changeLoadingStatus();
          return;
        }
        //* Elde ettiğim task değişkenini tasksnapshot formatındaki değişkenime atıyorum.
        final snapshot = await task;

        //* Oluşturduğum değişkenden urli alıyorum.
        final urlDownload = await snapshot.ref.getDownloadURL();

        //* firebase e göndermek üzere bi instance oluşturup değerlerini dolduruyorum.
        final ImageModel _images = ImageModel()
          ..name = fileName
          ..url = urlDownload
          ..uploadTime = Timestamp.now();

        //* bu instance ı firebasee yüklüyorum ve statumu değiştiriyorum.
        await FirebaseService.saveImageFileDetails(_images);
        changeLoadingStatus();
      }
    } on Exception catch (e) {
      print(e);
      changeLoadingStatus();
    }
  }

  ListView _imageList(List<ImageModel> _images) {
    return ListView.builder(
      itemCount: _images.length,
      itemBuilder: (context, index) {
        return Padding(
          padding: const EdgeInsets.all(8.0),
          child: Image.network(
            _images[index].url!,
            fit: BoxFit.cover,
            // height: 300,
            loadingBuilder: (
              BuildContext context,
              Widget image,
              ImageChunkEvent? loadingProgress,
            ) {
              if (loadingProgress == null) return image;
              return _loadingProgress(loadingProgress);
            },
          ),
        );
      },
    );
  }

  SizedBox _loadingProgress(ImageChunkEvent loadingProgress) {
    return SizedBox(
      height: 300,
      child: Center(
        child: CircularProgressIndicator(
          value: loadingProgress.expectedTotalBytes != null
              ? loadingProgress.cumulativeBytesLoaded /
                  loadingProgress.expectedTotalBytes!
              : null,
        ),
      ),
    );
  }
}
