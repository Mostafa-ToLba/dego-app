
class notificationModel{
  String? photo;
  String? title;
  String? notification;
  var time;

  notificationModel({this.photo,this.title,this.notification,this.time});

  notificationModel.fromJson(Map<String,dynamic>json)
  {
    photo=json['photo'];
    title=json['title'];
    notification=json['notification'];
    time=json['time'];
  }

  Map<String,dynamic>toMap()
  {
    return {
      'photo':photo,
      'title':title,
      'notification':notification,
      'time':time,
    };
  }

}