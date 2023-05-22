
class HomeModel{
  String? ph;
  HomeModel({this.ph,});

  HomeModel.fromJson(Map<String,dynamic>json)
  {
    ph=json['ph'];
  }

  Map<String,dynamic>toMap()
  {
    return {
      'ph':ph,
    };
  }

}