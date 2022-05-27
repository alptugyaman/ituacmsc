import 'package:cloud_firestore/cloud_firestore.dart';

class ImageModel {
  String? name;
  String? url;
  Timestamp? uploadTime;

  ImageModel({this.name, this.url, this.uploadTime});

  factory ImageModel.fromJson(Map<String, dynamic> json) => ImageModel(
        name: json['name'] as String?,
        url: json['url'] as String?,
        uploadTime: json['uploadTime'] as Timestamp?,
      );

  Map<String, dynamic> toJson() => {
        'name': name,
        'url': url,
        'uploadTime': uploadTime,
      };

  factory ImageModel.fromQuery(QueryDocumentSnapshot<ImageModel> json) =>
      ImageModel(
        name: json['name'] as String?,
        url: json['url'] as String?,
        uploadTime: json['uploadTime'] as Timestamp?,
      );
}
