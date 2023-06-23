
import 'package:cloud_firestore/cloud_firestore.dart';

class DataModel {
  final String? video;
  final String? ph;
  final String? text;

  DataModel({this.video, this.ph, this.text,});

  //Create a method to convert QuerySnapshot from Cloud Firestore to a list of objects of this DataModel
  //This function in essential to the working of FirestoreSearchScaffold

  List<DataModel> dataListFromSnapshot(QuerySnapshot querySnapshot) {
    return querySnapshot.docs.map((snapshot) {
      final Map<String, dynamic> dataMap = snapshot.data() as Map<String, dynamic>;
      return DataModel(
          video: dataMap['Vi'],
          ph: dataMap['Ph'],
          text: dataMap['Tx']);
    }).toList();
  }
}
