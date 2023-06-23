

import 'dart:async';
import 'dart:io';
import 'dart:math';

import 'package:audioplayers/audioplayers.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dego/AppCubit/appCubitStates.dart';
import 'package:dego/Models/homeModel/homeModel.dart';
import 'package:dego/Models/notificationModel/notificationModel.dart';
import 'package:dego/Models/searchModel/searchModel.dart';
import 'package:dego/Screens/bookmarkScreen/bookmarkScreen.dart';
import 'package:dego/Screens/downloadScreen/downloadScreen.dart';
import 'package:dego/Screens/homScreen2/homeScreen2.dart';
import 'package:dego/Screens/notificationScreen/notificationScreen.dart';
import 'package:dego/Screens/trendingScreen/trendingScreen.dart';
import 'package:dego/Shared/casheHelper/sharedPreferance.dart';
import 'package:dego/Shared/constans/constans.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:gallery_saver/gallery_saver.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:http/http.dart';
import 'package:instagram_share/instagram_share.dart';
import 'package:intl/intl.dart';
import 'package:localize_and_translate/localize_and_translate.dart';
import 'package:share_plus/share_plus.dart';
import 'package:share_whatsapp/share_whatsapp.dart';
import 'package:sizer/sizer.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path_provider/path_provider.dart';
import 'package:url_launcher/url_launcher.dart';

class AppCubit extends Cubit<AppCubitStates> {
  static BuildContext? context;

  AppCubit(AppCubitStates InitialAppCubitState) : super(InitialAppCubitState);

  static AppCubit get(context) => BlocProvider.of(context);

  int selectedIndex = 0;

  onItemTapped(int index)  async {
    soundsFunc();
    selectedIndex = index;
    if(index==1) {
      loadInterstialAd();
    }
    emit(navigationState());
  }

  List<Widget> Screens =
  [
    const  HomeScreen2(),
    const  TrendingScreen(),
    const  DownloadScreen(),
    const  BookmarkScreen(),
    const  NotificationScreen(),
  ];


  GetHomeScreen() {
    return FirebaseFirestore.instance.collection('Home').orderBy(
        "time", descending: true);
  }

  List<HomeModel>HomeList = [];
  List<String>AppbarList = [];
  List<String>AppbarListIds = [];

  Stream<QuerySnapshot> GetAppbarList() {
    return FirebaseFirestore.instance.collection('appbarList').snapshots();
  }

  int selectedIndexx = 0;
  TabController? tabController;

  List<HomeModel> VideosList =[] ;
  List<HomeModel>AllList = [] ;

  GetHomeVideos() {
    return FirebaseFirestore.instance.collection('Videos').orderBy('Time',descending: false);
  }
  GetAllVideos() {
    return FirebaseFirestore.instance.collection('Videos').orderBy('Time',descending: true);
  }

  GetTrendingVideos() {
    return FirebaseFirestore.instance.collection('Videos').orderBy(
        "views", descending: true).limit(3);
  }


  List<String>ShuffledItems = [];
  void shuffleItems()
   {
    final random = Random();
    ShuffledItems = List.from(VideosList);
   ShuffledItems.shuffle(random);
  }

  bool firstView = true;

  Future loveFunction(id)
    async {
     /*
     int love =0;
     FirebaseFirestore.instance.collection('Videos').doc(id).get().then((value)
     async {
       if(value.data()!['likes']!=null)
       {
         love =  value.data()!['likes'];
       }
       love+=1;
   await   FirebaseFirestore.instance.collection('Videos').doc(id).update({'likes':love});

      */
    FirebaseFirestore.instance.collection('Videos').doc(id).update({'likes': FieldValue.increment(1) });
      emit(LoveState());

   }




 Future removeLoveFunction(id)
   async{
    /*
    int love =0;
    FirebaseFirestore.instance.collection('Videos').doc(id).get().then((value)
    {
      if(value.data()!['likes']!=null)
        love =  value.data()!['likes'];

      if(love !=0)
      love -= 1;
      FirebaseFirestore.instance.collection('Videos').doc(id).update({'likes':love});
      emit(LoveState());
    });

     */
   FirebaseFirestore.instance.collection('Videos').doc(id).update({'likes': FieldValue.increment(-1) });
    emit(LoveState());
  }

   ///sqflite

  ///Sqflite DataBase
  //////////////
  Database? database;
  List<Map<String, dynamic>> FavoriteDatabaseList = [];
  Map<int, String> IsFavoriteDatabaseList = {};

  void createDatabase() {
    openDatabase(
      'favorite.db',
      version: 1,
      onCreate: (database, version) {
        // id integer
        // title String
        // date String
        // time String
        // name String
        print('database for Videos created');
        database.execute('CREATE TABLE favorite (id INTEGER PRIMARY KEY,status TEXT,'
            'savedStatus Text,downloadStatus Text,video TEXT,savedVideos Text,photo Text,title Text,downloadVideo Text,downloadPhoto Text,downloadTitle Text)')
            .then((value) {
          print('table created');
        }).catchError((error) {
          print('Error When Creating Table ${error.toString()}');
        });
      },
      onOpen: (database) {
        getDataFromDatabase(database: database);
        getDataFromDatabaseForSavedVideos(database: database);
        getDataFromDatabaseForDownloadedVideos(database: database);
        print('database opened');
      },
    ).then((value) {
      database = value;
      emit(AppCreateDatabaseState());
    });
  }
  List<Map<String, dynamic>> savedVideosList = [];
  Map<int, String> IsSavedVideosInDatabaseList = {};
  Future<void> getDataFromDatabase({database}) async {
    FavoriteDatabaseList = [];
    IsFavoriteDatabaseList = {};
      emit(AppGetDatabaseLoadingState());
    await database.rawQuery('SELECT * FROM favorite').then((value) {
      value.forEach((element) {
        if (element['status']=='new')
        {
          FavoriteDatabaseList.add(element);
          IsFavoriteDatabaseList.addAll(
              {
                element['id']: element['video'],
              });
        }
      });
      emit(AppGetDatabaseState());
    });
  }

  Future<void> getDataFromDatabaseForSavedVideos({database}) async {
    savedVideosList = [];
    IsSavedVideosInDatabaseList = {};
    emit(AppGetDatabaseLoadingState());
    await database.rawQuery('SELECT * FROM favorite').then((value) {
      value.forEach((element) {
        if (element['savedStatus']=='new')
        {
          savedVideosList.add(element);
          IsSavedVideosInDatabaseList.addAll(
              {
                element['id']: element['savedVideos'],
              });
        }
      });
      emit(AppGetDatabaseState());
    });
  }

  List<Map<String, dynamic>> downloadedVideosList = [];
  Map<int, String> IsDownloadedVideosInDatabaseList = {};
  Future<void> getDataFromDatabaseForDownloadedVideos({database}) async {
    downloadedVideosList = [];
    IsDownloadedVideosInDatabaseList = {};
    emit(AppGetDatabaseLoadingState());
    await database.rawQuery('SELECT * FROM favorite').then((value) {
      value.forEach((element) {
        if (element['downloadStatus']=='new')
        {
          downloadedVideosList.add(element);
          IsDownloadedVideosInDatabaseList.addAll(
              {
                element['id']: element['downloadVideo'],
              });
        }
      });
      emit(AppGetDatabaseState());
    });
  }
  Future insertToDatabase({
    @required String? video,
  }) async {
    await database!.transaction((txn) async {
      txn.rawInsert(
        'INSERT INTO favorite(video,status) VALUES("$video","new")',)
          .then((value) {
        print('$value inserted successfully');
        //   emit(AppInsertDatabaseState());

        getDataFromDatabase(database: database!);
      }).catchError((error) {
        print('Error When Inserting New Record ${error.toString()}');
      });
    });
  }

  Future insertToDatabaseForSavedVideos({
    @required String? saveVideo,
    @required String? photo,
    @required String? title,
  }) async {
    await database!.transaction((txn) async {
      txn.rawInsert(
        'INSERT INTO favorite(savedVideos,savedStatus,photo,title) VALUES("$saveVideo","new","$photo","$title")',)
          .then((value) {
        print('$value inserted successfully');
        //   emit(AppInsertDatabaseState());

        getDataFromDatabaseForSavedVideos(database: database!);
      }).catchError((error) {
        print('Error When Inserting New Record ${error.toString()}');
      });
    });
  }

  Future insertToDatabaseForDownloadedVideos({
    @required String? downloadVideo,
    @required String? downloadphoto,
    @required String? downloadtitle,
  }) async {
    await database!.transaction((txn) async {
      txn.rawInsert(
        'INSERT INTO favorite(downloadVideo,downloadStatus,downloadPhoto,downloadTitle) VALUES("$downloadVideo","new","$downloadphoto","$downloadtitle")',)
          .then((value) {
        print('$value inserted successfully');
        //   emit(AppInsertDatabaseState());

        getDataFromDatabaseForDownloadedVideos(database: database!);
      }).catchError((error) {
        print('Error When Inserting New Record ${error.toString()}');
      });
    });
  }

  Future deleteDataFromDatabase({
    @required String? video,
  }) async {
    database!.rawDelete(
        'DELETE FROM favorite WHERE video = ?', [video])
        .then((value) {
      getDataFromDatabase(database: database);
      //     emit(AppDeleteDatabaseState());
    });
  }

  Future deleteDataFromDatabaseForSavedVideos({
    @required String? savedVideo,
  }) async {
    database!.rawDelete(
        'DELETE FROM favorite WHERE savedVideos = ?', [savedVideo])
        .then((value) {
      getDataFromDatabaseForSavedVideos(database: database);
      //     emit(AppDeleteDatabaseState());
    });
  }
  Future deleteDataFromDatabaseForDownloadVideos({
    @required String? downloadVideo,
  }) async {
    database!.rawDelete(
        'DELETE FROM favorite WHERE downloadVideo = ?', [downloadVideo])
        .then((value) {
      getDataFromDatabaseForDownloadedVideos(database: database);
      //     emit(AppDeleteDatabaseState());
    });
  }
  bool? a ;
 bool isItInFav({video})
  {
    if(IsFavoriteDatabaseList.containsValue(video))
    {
      a = true;
      return true;
    }
    else
      {
        a = false;
        return false;
      }
  }

   incrementViews({docId}) {
    FirebaseFirestore.instance.collection('Videos').doc(docId).update({'views': FieldValue.increment(1) });
  }

  String formatViews(views) {
    if (views >= 1000) {
      return (views / 1000).toStringAsFixed(1)+'k';
    } else {
      return views.toString();
    }
  }
  List<HomeModel>trendingList = [] ;

  List<HomeModel> trendsList =[];
   getTrends()
   {
     FirebaseFirestore.instance.collection('Videos').orderBy('views',descending: true).limit(3).get().then((value)
     {
       value.docs.forEach((element)
       {
         trendsList.add(HomeModel(video: element.data()['video'],photo: element.data()['ph'],
         views: element.data()['views'],text: element.data()['text'],likes: element.data()['likes'],));
       });
     });
   }
     Stream<QuerySnapshot> getLikes()
     {
       return FirebaseFirestore.instance.collection('Videos').snapshots();
     }
     int currentVideo = 0;
  PageController? contoller =PageController();

  changeCurentIndex(pagee)
  {
    page = pagee+2;
    emit(changeCurrentIndexState());
  }

   updateCurrentVideoIndex() {
     print(currentVideo);
  }

   DocumentSnapshot? lastDoc ;

   int currentIndex=0;

  int page = 1 ;

 List<notificationModel> englishNotificationList = [];
 List<notificationModel> arabicNotificationList= [];
  Stream<QuerySnapshot> getNotifications()
  {
    return FirebaseFirestore.instance.collection('Notifications').orderBy('Time',descending: true).snapshots();
  }

  String formatTimestamp({required Timestamp timestamp}) {
    DateTime dateTime = timestamp.toDate();
    Duration difference = DateTime.now().difference(dateTime);
    if (difference.inDays > 1) {
      return '${difference.inDays} days ago';
    } else if (difference.inDays == 1) {
      return '1 day ago';
    } else if (difference.inHours > 1) {
      return '${difference.inHours} hours ago';
    } else if (difference.inHours == 1) {
      return '1 hour ago';
    } else if (difference.inMinutes > 1) {
      return '${difference.inMinutes} minutes ago';
    } else if (difference.inMinutes == 1) {
      return '1 minute ago';
    } else {
      return 'just now';
    }
  }

  String formatTimestampForArabic({required Timestamp timestamp}) {
    DateTime dateTime = timestamp.toDate();
    Duration difference = DateTime.now().difference(dateTime);
    if (difference.inDays > 1) {
      return Intl.plural(
        difference.inDays,
        zero: 'اليوم',
        one: 'قبل يوم واحد',
        two: 'قبل يومين',
        few: 'قبل ${difference.inDays} أيام',
        many: 'قبل ${difference.inDays} يومًا',
        other: 'قبل ${difference.inDays} يومًا',
        locale: 'ar',
      );
    } else if (difference.inDays == 1) {
      return 'قبل يوم واحد';
    } else if (difference.inHours > 1) {
      return Intl.plural(
        difference.inHours,
        zero: 'الساعة الحالية',
        one: 'قبل ساعة واحدة',
        two: 'قبل ساعتين',
        few: 'قبل ${difference.inHours} ساعات',
        many: 'قبل ${difference.inHours} ساعة',
        other: 'قبل ${difference.inHours} ساعة',
        locale: 'ar',
      );
    } else if (difference.inHours == 1) {
      return 'قبل ساعة واحدة';
    } else if (difference.inMinutes > 1) {
      return Intl.plural(
        difference.inMinutes,
        zero: 'الدقيقة الحالية',
        one: 'قبل دقيقة واحدة',
        two: 'قبل دقيقتين',
        few: 'قبل ${difference.inMinutes} دقائق',
        many: 'قبل ${difference.inMinutes} دقيقة',
        other: 'قبل ${difference.inMinutes} دقيقة',
        locale: 'ar',
      );
    } else if (difference.inMinutes == 1) {
      return 'قبل دقيقة واحدة';
    } else {
      return 'الآن';
    }
  }


  void showBottomSheet(BuildContext context) {
    showModalBottomSheet(
        context: context,backgroundColor: Colors.transparent,isScrollControlled: true,
        enableDrag: true,isDismissible: true,
        builder: (BuildContext context) {
          return Container(
            height: 62.h,
            padding:  EdgeInsets.all(13.sp),
            decoration: BoxDecoration(color: color1,borderRadius: BorderRadius.only(topLeft:Radius.circular(30.sp),topRight:Radius.circular(30.sp))),
            child: Column(
              mainAxisSize: MainAxisSize.max,
              children: <Widget>[
                Text("Settings".tr(),
                    style: TextStyle(
                        fontWeight: FontWeight.w700, fontSize:translator.activeLanguageCode=='en'?15.sp:16.sp)),
                Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children:
                  [
                    Text('Notifications'.tr(),style: TextStyle(color: color3,fontSize:translator.activeLanguageCode=='en'? 12.sp:13.sp,fontWeight: FontWeight.w600),),
                    const Spacer(),
                    Switch(
                      value: notification,activeColor: color2,inactiveTrackColor: color3,
                      onChanged: (value) {
                        AppCubit.get(context).soundsFunc();
                        notification =!notification;
                        emit(NotificationState());
                      },
                    ),
                  ],
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children:
                  [
                    Text('nightMode'.tr(),style: TextStyle(color: color3,fontSize:translator.activeLanguageCode=='en'? 12.sp:13.sp,fontWeight: FontWeight.w600),),
                    const Spacer(),
                    Switch(
                      value: isDark,activeColor: color2,inactiveTrackColor: color3,
                      onChanged: (value) {
                        AppCubit.get(context).soundsFunc();
                        MakeItDarkk(dark: isDark);
                        if (isDark) {
                          SystemChrome.setSystemUIOverlayStyle(
                              const SystemUiOverlayStyle(
                                systemNavigationBarColor: Colors.black,
                                systemNavigationBarDividerColor: Colors.black,
                                systemNavigationBarIconBrightness: Brightness.light,
                                statusBarColor: Colors.transparent
                              ));
                        }
                        else {
                          SystemChrome.setSystemUIOverlayStyle(
                               SystemUiOverlayStyle(
                                systemNavigationBarColor: color1,
                                systemNavigationBarDividerColor:
                                color1,
                                systemNavigationBarIconBrightness:
                                Brightness.dark,
                                 statusBarIconBrightness: Brightness.light,
                                 statusBarColor: Colors.transparent,systemStatusBarContrastEnforced: true,statusBarBrightness: Brightness.light
                              ));
                        }

                        }
                    ),
                  ],
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children:
                  [
                    Text('Sounds'.tr(),style: TextStyle(color: color3,fontSize:translator.activeLanguageCode=='en'? 12.sp:13.sp,fontWeight: FontWeight.w600),),
                    const Spacer(),
                    Switch(
                      value: music,activeColor: color2,inactiveTrackColor: color3,
                      onChanged: (value) {
                         music =!music;
                         emit(MakeItSound());
                      },
                    ),
                  ],
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children:
                  [
                    Text('Language'.tr(),style: TextStyle(color: color3,fontSize: translator.activeLanguageCode=='en'? 12.sp:13.sp,fontWeight: FontWeight.w600),),
                    const Spacer(),
                    TextButton(
                        onPressed: ()
                        {
                          AppCubit.get(context).soundsFunc();
                          translator.isDirectionRTL(context)?translator.setNewLanguage(context, newLanguage: 'en',remember: true,restart: false).then((value)
                          {
                            emit(SetLanguageState());
                          }):
                          translator.setNewLanguage(context, newLanguage: 'ar',remember: true,restart: false).then((value)
                          {
                            emit(SetLanguageState());
                          });

                        }, child: Text(translator.isDirectionRTL(context)?'English':'عربي',style: TextStyle(color: color2,fontSize: 12.sp,fontWeight: FontWeight.w800),)),
                  ],
                ),
                SizedBox(height: 1.h,),
                Material(
                  color: color1,
                  child: InkWell(
                    splashColor: color3,
                    onTap: ()
                    {
                      AppCubit.get(context).soundsFunc();
                      Share.share('https://play.google.com/store/apps/details?id=com.dego.dego');
                    },
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children:
                      [
                        Text('shareApp'.tr(),style: TextStyle(color: color3,fontSize:translator.activeLanguageCode=='en'? 12.sp:13.sp,fontWeight: FontWeight.w600),),
                        const Spacer(),
                        Icon(Icons.arrow_forward_ios_sharp,color:color3),
                        SizedBox(width: 3.w,),
                      ],
                    ),
                  ),
                ),
                SizedBox(height: 2.h,),
                Material(
                  color: color1,
                  child: InkWell(
                    onTap: ()
                    {
                      AppCubit.get(context).soundsFunc();
                      _launchUrlForRateUsAndGooglePlay();
                    },
                    splashColor: color3,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children:
                      [
                        Text('rateApp'.tr(),style: TextStyle(color: color3,fontSize:translator.activeLanguageCode=='en'? 12.sp:13.sp,fontWeight: FontWeight.w600),),
                        const Spacer(),
                        Icon(Icons.arrow_forward_ios_sharp,color:color3),
                        SizedBox(width: 3.w,),
                      ],
                    ),
                  ),
                ),
                SizedBox(height: 2.h,),
                Material(
                  color: color1,
                  child: InkWell(
                    splashColor: color3,
                    onTap: ()
                    {
                      _launchUrlll();
                      AppCubit.get(context).soundsFunc();
                    },
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children:
                      [
                        Text('contactUs'.tr(),style: TextStyle(color: color3,fontSize:translator.activeLanguageCode=='en'? 12.sp:13.sp,fontWeight: FontWeight.w600),),
                        const Spacer(),
                        Icon(Icons.arrow_forward_ios_sharp,color:color3),
                        SizedBox(width: 3.w,),
                      ],
                    ),
                  ),
                ),
                SizedBox(height: 2.h,),
                Material(
                  color: color1,
                  child: InkWell(
                    splashColor: Colors.grey[300],
                    onTap: ()
                    {
                      _privacyPolicy();
                      AppCubit.get(context).soundsFunc();
                    },
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children:
                      [
                        Text('privacyPolicy'.tr(),style: TextStyle(color: color3,fontSize:translator.activeLanguageCode=='en'? 12.sp:13.sp,fontWeight: FontWeight.w600),),
                        const Spacer(),
                        Icon(Icons.arrow_forward_ios_sharp,color:color3),
                        SizedBox(width: 3.w,),
                      ],
                    ),
                  ),
                ),
                SizedBox(height: 4.h,),
                Row(
                  mainAxisAlignment:  MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text("Version".tr(),
                        style: TextStyle(
                            fontWeight: FontWeight.w700, fontSize: 10.sp)),
                    SizedBox(width: 1.sp),
                    Text(" 1.0.1",
                        style: TextStyle(
                            fontWeight: FontWeight.w500, fontSize: 10.sp)),
                  ],
                ),
              ],
            ),
          );
        });
  }

  MakeItDarkk({dark})  {
    if (dark == false) {
      isDark = true;
      CasheHelper.putBoolean(key:'isDark', value: isDark )!.then((value)
      {
        emit(MakeItDarkState());
      });
    } else {
      isDark = false;
      CasheHelper.putBoolean(key:'isDark', value: isDark )!.then((value)
      {
        emit(MakeItDarkState());
      });
    }
  }


  MakeItDark({shared})  {
    if (shared == false||shared==null) {
      isDark = false;
    } else {
      isDark = true;
      CasheHelper.putBoolean(key:'isDark', value: true )!.then((value)
      {
        /*
        SystemChrome.setSystemUIOverlayStyle(
            SystemUiOverlayStyle(
                systemNavigationBarColor: color1,
                systemNavigationBarDividerColor:
                color1,
                systemNavigationBarIconBrightness:
                Brightness.dark,
                statusBarIconBrightness: Brightness.light,
                statusBarColor: Colors.transparent,
                systemStatusBarContrastEnforced: true,statusBarBrightness: Brightness.light
            ));

         */
        emit(MakeItDarkState());
      });
    }
  }

  bool isDark = false;
  bool music  = true;
  bool notification = true;

  void showBottomSheet2(BuildContext context,video, photo, text,) {
    showModalBottomSheet(
        context: context,backgroundColor: Colors.transparent,isScrollControlled: true,
        enableDrag: true,isDismissible: true,
        builder: (BuildContext context) {
          return Container(
            height: 15.h,
            padding:  EdgeInsets.all(13.sp),
            decoration: BoxDecoration(color: color1,borderRadius: BorderRadius.only(topLeft:Radius.circular(40.sp),topRight:Radius.circular(40.sp))),
            child: Row(
              mainAxisSize: MainAxisSize.max,
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                SizedBox(width: 5.w,),
                InkWell(
                    onTap: circle == 0 && progresss == 0?()
                    async {
                      await downloadFromStatus(video:video,context: context,photo: photo,textt:text);
                    }:null,
                    child: Image(height: 6.h,width: 16.w,image: const AssetImage('assets/images/download2.png',),)),
                SizedBox(width: 5.w,),
                InkWell(
                    onTap: circle == 0 && progresss == 0?()
                    {
                      ShareToInst(video:video,context: context,);
                    }:null,
                    child: Image(height: 6.h,width: 16.w,image: const AssetImage('assets/images/instagram.png',),)),
                SizedBox(width: 5.w,),
                InkWell(
                    onTap: circle == 0 && progresss == 0?()
                    async {
                      ShareToWhats(video: video,context: context,);
                    }:null,
                    child: Image(height: 6.h,width: 16.w,image: const AssetImage('assets/images/whatsapp.png',),)),
                SizedBox(width: 5.w,),
              ],
            ),
          );
        });
  }
  int? index;
  double progresss = 0;
  String text = '';
  double circle = 0;
  Future startShare({video, Index,context}) async {
    index = Index;
    final url = video;
    final request = Request('GET', Uri.parse(url));
    final response = await Client().send(request);
    final contentLength = response.contentLength;

    final file = await getFile('file.mp4');
    final bytes = <int>[];
    response.stream.listen(
          (newBytes) {
        bytes.addAll(newBytes);
        {
          progresss = bytes.length / contentLength!;
          emit(GetLastVideosSliderSuccessState());
        }
      },
      onDone: () async {
        //      AppCubit.get(context).progresss = 1;
        await file.writeAsBytes(bytes);

        //     final url =Uri.parse(widget.video);
        //     final response = await http.get(url);
        //    final bytes = response.bodyBytes;
        final temp = await getTemporaryDirectory();
        final path = '${temp.path}/video.mp4';
        File(path).writeAsBytesSync(bytes);
        await Share.shareFiles([path]);


        //whts   XFile filee = new XFile(path);
   //whts     shareWhatsapp.shareFile(filee);

        progresss = 0;
        emit(GetLastVideosSliderSuccessState());
      },
      onError: (error) async {
        progresss = 0;
        Fluttertoast.showToast(
            msg: 'error on downloading video',
            gravity: ToastGravity.CENTER,
            backgroundColor: AppCubit.get(context).isDark ? Colors.green : Colors.black);
        emit(GetLastVideosSliderSuccessState());
      },
      cancelOnError: true,
    );
  }
  Future ShareToWhats({video, Index,context}) async {
    index = Index;
    final url = video;
    final request = Request('GET', Uri.parse(url));
    final response = await Client().send(request);
    final contentLength = response.contentLength;

    final file = await getFile('file.mp4');
    final bytes = <int>[];
    response.stream.listen(
          (newBytes) {
        bytes.addAll(newBytes);
        {
          progresss = bytes.length / contentLength!;
          emit(GetLastVideosSliderSuccessState());
        }
      },
      onDone: () async {
        //      AppCubit.get(context).progresss = 1;
        await file.writeAsBytes(bytes);

        //     final url =Uri.parse(widget.video);
        //     final response = await http.get(url);
        //    final bytes = response.bodyBytes;
        final temp = await getTemporaryDirectory();
        final path = '${temp.path}/video.mp4';
        File(path).writeAsBytesSync(bytes);
          XFile filee = new XFile(path);
          shareWhatsapp.shareFile(filee);
        progresss = 0;
        emit(GetLastVideosSliderSuccessState());
      },
      onError: (error) async {
        progresss = 0;
        Fluttertoast.showToast(
            msg: 'error on downloading video',
            gravity: ToastGravity.CENTER,
            backgroundColor: AppCubit.get(context).isDark ? Colors.green : Colors.black);
        emit(GetLastVideosSliderSuccessState());
      },
      cancelOnError: true,
    );
  }
  Future ShareToInst({video, Index,context}) async {
    index = Index;
    final url = video;
    final request = Request('GET', Uri.parse(url));
    final response = await Client().send(request);
    final contentLength = response.contentLength;

    final file = await getFile('file.mp4');
    final bytes = <int>[];
    response.stream.listen(
          (newBytes) {
        bytes.addAll(newBytes);
        {
          progresss = bytes.length / contentLength!;
          emit(GetLastVideosSliderSuccessState());
        }
      },
      onDone: () async {
        //      AppCubit.get(context).progresss = 1;
     //   await file.writeAsBytes(bytes);

      //       final url =Uri.parse(video);
      //       final response = await http.get(url);
    //        final bytes = response.bodyBytes;
        final temp = await getTemporaryDirectory();
        final path = '${temp.path}/video.mp4';
        File(path).writeAsBytesSync(bytes);
        InstagramShare.share(path,"video");
        progresss = 0;
        emit(GetLastVideosSliderSuccessState());
      },
      onError: (error) async {
        progresss = 0;
        Fluttertoast.showToast(
            msg: 'error on downloading video',
            gravity: ToastGravity.CENTER,
            backgroundColor: AppCubit.get(context).isDark ? Colors.green : Colors.black);
        emit(GetLastVideosSliderSuccessState());
      },
      cancelOnError: true,
    );
  }


  downloadFromStatus({video,Index,context,photo,textt}) async {
    index = Index;
    final temp = await getTemporaryDirectory();
    final path = '${temp.path}.mp4';
    await Dio().download(
      video,
      path,
      onReceiveProgress: (received, total) {
        if (total != -1) {
          print((received / total * 100).toStringAsFixed(0) + "%");
          print(received / total);
          {
            text = ((received / total * 100).toStringAsFixed(0) + "%");
            circle = received / total;
            emit(GetLastVideosSliderSuccessState());
          }
        }
      },
      deleteOnError: true,

    ).then((value) async {
      loadInterstialAd();
      await GallerySaver.saveVideo(path).then((value) {
        if( IsDownloadedVideosInDatabaseList.containsValue(video)) {
          //   deleteDataFromDatabaseForDownloadVideos(downloadVideo: video);
          null;
        } else {
          insertToDatabaseForDownloadedVideos(downloadVideo: video,
              downloadphoto: photo,downloadtitle: textt );
        }
      });
        Fluttertoast.showToast(msg: 'download'.tr(),fontSize:SizerUtil.deviceType==DeviceType.mobile?12.sp:5.sp,textColor:isDark?Colors.white:color2,gravity: ToastGravity.CENTER,backgroundColor:isDark? Colors.black:Colors.white).then((value)
        {
          Timer(const Duration(seconds: 2),()
          {
            showInterstialAd();
          });

        });
        text = '';
        circle=0;
        emit(GetLastVideosSliderSuccessState());

    }).catchError((error)
    {
      circle=0;
      text='';
      Fluttertoast.showToast(msg: 'Error'.tr(),fontSize: 11.sp,textColor:isDark?Colors.black:color2 ,gravity: ToastGravity.CENTER,backgroundColor:isDark? Colors.black:Colors.white);
      emit(GetLastVideosSliderSuccessState());
    });
  }

  Future<File> getFile(String filename) async {
/*
    final temp = await getTemporaryDirectory();
    final path = '${temp.path}/myfile.video.mp4';
    await Dio().download(widget.video, path).then((value)
    async {
      await GallerySaver.saveVideo(path).then((value)
      {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Downladed To Gallery')));
      });
    });
 */

    final dir = await getApplicationDocumentsDirectory();

    return File('${dir.path}/$filename');
  }

   soundsFunc()
   async {
     if(music==true)
     {
       final file = await AudioCache().loadAsFile('sounds/clickk.wav');
       final bytes = await file.readAsBytes();
       AudioCache().playBytes(bytes);
     }
   }
  soundsFunc2()
  async {
    if(music==true)
    {
      final file = await AudioCache().loadAsFile('sounds/search.mp3');
      final bytes = await file.readAsBytes();
      AudioCache().playBytes(bytes);
    }
  }

  int tabBarIndex = 0;


  changeTabBarColor()
  {
    print(tabController!.index);
    emit(ChangeTabBarState());
  }

  nightMode({isDark})
  {
    if (isDark) {
      SystemChrome.setSystemUIOverlayStyle(
          const SystemUiOverlayStyle(
            systemNavigationBarColor: Colors.black,
            systemNavigationBarDividerColor:
            Colors.black,
            systemNavigationBarIconBrightness:
            Brightness.dark,
          ));
    }
    else {
      SystemChrome.setSystemUIOverlayStyle(
          SystemUiOverlayStyle(
            systemNavigationBarColor: color1,
            systemNavigationBarDividerColor:
            color1,
            systemNavigationBarIconBrightness:
            Brightness.dark,
            statusBarIconBrightness: Brightness.dark,
          ));
    }
  }

  //google ads

  String bannarAdNumber='ca-app-pub-3940256099942544/6300978111';
  String interstitialAdNumber='ca-app-pub-3940256099942544/1033173712';
  String openAdNumber='ca-app-pub-3940256099942544/3419835294';
  late AppOpenAd  appOpenAd ;
  bool oppenAppLoaded = false;
  InterstitialAd ? interstitialAd;
  bool  isReady =false ;

  Future<void> loadInterstialAd ()
  async {
    await InterstitialAd.load(
      adUnitId: Platform.isAndroid? 'ca-app-pub-9120321344983600/5398334476':'ca-app-pub-3940256099942544/4411468910',
      request: const AdRequest(),
      adLoadCallback: InterstitialAdLoadCallback(
        onAdLoaded: (ad)
        {
          isReady = true;
          interstitialAd = ad;
        },
        onAdFailedToLoad: (error)
        {
          print('interstial ad is failed to load');
        },
      ),
    );
  }

  Future<void> showInterstialAd()
  async {
    if(isReady) {
      await  interstitialAd!.show();
    }
  }

  int interstialadCountForHomeScreen =0;
  void adCountForHomeScreen()
  {
    if(interstialadCountForHomeScreen<=5) {
      interstialadCountForHomeScreen++;
    } else {
      interstialadCountForHomeScreen=0;
    }
  }

  int interstialadCountForAllScreen =0;
  void adCountForAllScreen()
  {
    if(interstialadCountForAllScreen<=2) {
      interstialadCountForAllScreen++;
    } else {
      interstialadCountForAllScreen=0;
    }
  }


  int interstialadCountForTrendScreen =0;
  void adCountForTrendScreen()
  {
    if(interstialadCountForTrendScreen<=2) {
      interstialadCountForTrendScreen++;
    } else {
      interstialadCountForTrendScreen=0;
    }
  }

  final Uri _urlll = Uri.parse('mailto:VidlodApp@Gmail.com?subject=${Uri.encodeFull('Dego Contact')}&body=Send us a message we are happy to hear from you :)');
  void _launchUrlll() async {
    if (!await launchUrl(_urlll)) throw 'Could not launch $_urlll';
  }

  final Uri _urlForRateUs = Uri.parse('https://play.google.com/store/apps/details?id=com.dego.dego');
  void _launchUrlForRateUsAndGooglePlay() async {
    if (!await launchUrl(_urlForRateUs,mode: LaunchMode.externalApplication)) throw 'Could not launch $_urlForRateUs';
  }

  final Uri _url = Uri.parse('https://sites.google.com/view/dego-app');

  _privacyPolicy() async {
    if (!await launchUrl(_url)) throw 'Could not launch $_url';
  }

  void loadAppOpenAd()
   {
    AppOpenAd.load(
      adUnitId: Platform.isAndroid ? 'ca-app-pub-9120321344983600/5645746483':'ca-app-pub-3940256099942544/5662855259',
      orientation: AppOpenAd.orientationPortrait,
      request:  const AdRequest(),
      adLoadCallback: AppOpenAdLoadCallback(
        onAdLoaded: (ad) {
            appOpenAd = ad;
            oppenAppLoaded=true;
          // appOpenAd!.show();
          emit(OpenAppAdState());
        },
        onAdFailedToLoad: (error) {
          print('AppOpenAd failed to load: $error');
          // Handle the error.
        },
      ),
    );
  }
}
