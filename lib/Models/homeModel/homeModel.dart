
class HomeModel{
  String? photo;
  String? video;
  String? text;
  int? likes ;
  int? views ;
  String? docId;
  HomeModel({this.photo,this.video,this.text,this.likes,this.docId,this.views});

  HomeModel.fromJson(Map<String,dynamic>json)
  {
    photo=json['photo'];
    video=json['video'];
    text=json['text'];
    likes=json['likes'];
    docId=json['docId'];
    views=json['views'];
  }

  Map<String,dynamic>toMap()
  {
    return {
      'photo':photo,
      'video':video,
      'text':text,
      'likes':likes,
      'docId':docId,
      'views':views,
    };
  }

}