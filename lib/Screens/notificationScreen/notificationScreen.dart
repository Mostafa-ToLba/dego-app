
import 'dart:io';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dego/AppCubit/appCubit.dart';
import 'package:dego/AppCubit/appCubitStates.dart';
import 'package:dego/Models/notificationModel/notificationModel.dart';
import 'package:dego/Screens/searchScreen/searchScreen.dart';
import 'package:dego/Shared/constans/constans.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:localize_and_translate/localize_and_translate.dart';
import 'package:sizer/sizer.dart';

class NotificationScreen extends StatefulWidget {
  const NotificationScreen({Key? key}) : super(key: key);

  @override
  State<NotificationScreen> createState() => _NotificationScreenState();
}

class _NotificationScreenState extends State<NotificationScreen> {
  bool _isVisible = false;
  late BannerAd _bottomBannerAd;
  bool _isBottomBannerAdLoaded = false;
  void _createBottomBannerAd() {
    _bottomBannerAd = BannerAd(
      adUnitId: Platform.isAndroid
          ? AppCubit.get(context).bannarAdNumber
          : 'ca-app-pub-9120321344983600/4388505138',
      size: AdSize.banner,
      request: const AdRequest(),
      listener: BannerAdListener(
        onAdLoaded: (_) {
          setState(() {
            _isBottomBannerAdLoaded = true;
          });
        },
        onAdFailedToLoad: (ad, error) {
          ad.dispose();
        },
      ),
    );
    _bottomBannerAd.load();
  }
   @override
  void initState() {
     Future.delayed(const Duration(seconds: 2)).then((value) {
       setState(() {
         _isVisible = true;
       });
     });
     _createBottomBannerAd();
    super.initState();
  }
  @override
  void dispose() {
    _bottomBannerAd.dispose();
    super.dispose();
  }
  @override
  Widget build(BuildContext context) {
    return BlocConsumer<AppCubit,AppCubitStates>(
      listener: (BuildContext context, state) {  },
      builder: (BuildContext context, Object? state) {
        return Scaffold(
          backgroundColor: Colors.white,
          appBar: AppBar(
            elevation: 0,
            titleSpacing: 4.w,
            title: Text('Notifications'.tr(),style: TextStyle(fontSize: 16.sp,color: AppCubit.get(context).isDark?
            Colors.white:color2,fontWeight: FontWeight.w700),),
            actions:
            [
              IconButton(onPressed: ()
              {
                AppCubit.get(context).soundsFunc();
                navigateTo(context, const SearchScreen());
              }, icon:Padding(
                padding:  EdgeInsets.only(left: translator.isDirectionRTL(context)?0:15.sp,right:translator.isDirectionRTL(context)?15.sp:0 ),
                child: Image(image:  const AssetImage('assets/images/search.png',),height: 18.sp,color: AppCubit.get(context).isDark?
                Colors.white:color3,),
              ),
                padding: EdgeInsets.zero, ),
              IconButton(onPressed: ()
              {
                AppCubit.get(context).soundsFunc();
                AppCubit.get(context).showBottomSheet(context);
              }, icon:Image(image: const AssetImage('assets/images/menu.png'),color: AppCubit.get(context).isDark?
              Colors.white:color3,)),
              SizedBox(width:translator.isDirectionRTL(context)?1.w:0,),
            ],
          ),
          body: Padding(
            padding:  EdgeInsets.all(0.sp),
            child:  StreamBuilder<QuerySnapshot>(
              stream: AppCubit.get(context).getNotifications(),
              builder: (context, snapshot) {
                if (!snapshot.hasData || snapshot.data!.size == 0) {
                  return const Text('');
                }
                else
                {
                  AppCubit.get(context).englishNotificationList = [];
                  AppCubit.get(context).arabicNotificationList= [];
                  for (var doc in snapshot.data!.docs) {
                    AppCubit.get(context).englishNotificationList.add(notificationModel(photo:doc['Ph'],title: doc['En']
                        ,notification: doc['En 2'],time: doc['Time']));
                    //arabic notification
                    AppCubit.get(context).arabicNotificationList.add(notificationModel(photo:doc['Ph'],time:doc['Time'],
                        title: doc['Ar'],notification:doc['Ar 2']));
                  }
                  if(AppCubit.get(context).englishNotificationList.isEmpty&&AppCubit.get(context).arabicNotificationList.isEmpty) {
                  return noNotification(context);
                  }
                  else {
                    return ListView.separated(
                      itemBuilder: (BuildContext, index)
                      {
                        if(translator.isDirectionRTL(context)) {
                          return  AnimationConfiguration.staggeredList(
                            position: index,
                            delay: const Duration(milliseconds: 100),
                            child: SlideAnimation(
                                duration: const Duration(milliseconds: 2500),
                                curve: Curves.fastLinearToSlowEaseIn,
                              horizontalOffset: 100,
                              verticalOffset: 0.0,
                              child: FadeInAnimation(
                                  curve: Curves.fastLinearToSlowEaseIn,
                                  duration: const Duration(milliseconds: 2500),
                                  child: ArbicNotificationItem(AppCubit.get(context).arabicNotificationList[index],context)),
                            ),
                          );

                        } else{
                          return  AnimationConfiguration.staggeredList(
                            position: index,
                            delay: const Duration(milliseconds: 100),
                            child: SlideAnimation(
                              duration: const Duration(milliseconds: 2500),
                              curve: Curves.fastLinearToSlowEaseIn,
                              horizontalOffset: 100,
                              verticalOffset: 0.0,
                              child: FadeInAnimation(
                                  curve: Curves.fastLinearToSlowEaseIn,
                                  duration: const Duration(milliseconds: 2500),
                                  child: NotificationItem(AppCubit.get(context).englishNotificationList[index],context)),
                            ),
                          );
                        }
                      },
                      separatorBuilder: (BuildContext, index)=>_isVisible ? Container(height: .1.sp,color: Colors.grey[900]) : Container(height: .1.sp,color: Colors.white,),
                      itemCount: translator.isDirectionRTL(context)?AppCubit.get(context).arabicNotificationList.length:AppCubit.get(context).englishNotificationList.length);
                  }
                }
              },
            ),
          ),
          bottomNavigationBar: _isBottomBannerAdLoaded
              ? Container(
            color: AppCubit.get(context).isDark
                ? Colors.black
                : Colors.white,
            height: _bottomBannerAd.size.height.toDouble(),
            width: _bottomBannerAd.size.width.toDouble(),
            child: AdWidget(ad: _bottomBannerAd),
          )
              : Container(height: 6.2.h),
        );
      },
    );
  }
}

 Widget NotificationItem(notificationModel englishNotificationList, BuildContext context)=>Container(

  width: double.infinity,
  decoration: BoxDecoration(
    /*
      border: Border.all(
        color: Colors.red,
        width: 1,
      ),

     */
      color:Colors.white,borderRadius: BorderRadius.circular(8.sp)),
  child: Stack(
    children:
    [
      Padding(
        padding:  EdgeInsets.all(10.sp),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children:
          [
            Container(
              height:8.h,
              width: 15.w,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(5.sp),
                color: Colors.white,
              ),
              child: SizedBox(
                  child: Image(image: CachedNetworkImageProvider(englishNotificationList.photo.toString(),),)),
            ),
            SizedBox(width: 3.w,),
            Padding(
              padding:  EdgeInsets.only(top: 5.sp),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(englishNotificationList.title.toString(),style: TextStyle(color:Colors.black,fontSize: 11.sp,fontWeight: FontWeight.w800,
                          fontFamily: 'BalooPaaji2',height: 1.sp),),
                      SizedBox(width: 3.w,),
                      Text(AppCubit.get(context).formatTimestamp(timestamp: englishNotificationList.time),style: TextStyle(fontWeight:FontWeight.w500,fontSize: 9.sp,color:Colors.black,),),
                    ],
                  ),
                  SizedBox(height: .4.h),
                  SizedBox(
                      width: 73.w,
                      child: Text(englishNotificationList.notification.toString(),style: TextStyle(height: 1.2.sp,fontWeight:FontWeight.w500,color:Colors.black,fontSize:10.sp,
                      fontFamily: 'BalooPaaji2'),)),
                ],
              ),
            ),
          ],
        ),
      ),
    ],
  ),
);
 Widget ArbicNotificationItem(notificationModel arabicNotificationList, BuildContext context)=>Container(

  width: double.infinity,
  decoration: BoxDecoration(
    /*
      border: Border.all(
        color: Colors.red,
        width: 1,
      ),

     */
      color:Colors.white,borderRadius: BorderRadius.circular(8.sp)),
  child: Stack(
    children:
    [
      Padding(
        padding:  EdgeInsets.all(10.sp),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children:
          [
            Container(
              height:8.h,
              width: 15.w,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(5.sp),
                color: Colors.white,
              ),
              child: SizedBox(
                  child: Image(image: CachedNetworkImageProvider(arabicNotificationList.photo.toString(),),)),
            ),
            SizedBox(width: 3.w,),
            Padding(
              padding:  EdgeInsets.only(top: 5.sp),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Text(arabicNotificationList.title.toString(),style: TextStyle(color:Colors.black,fontSize: 13.sp,fontWeight: FontWeight.w800,
                          height: 1.sp),),
                      SizedBox(width: 3.w,),
                      Text(AppCubit.get(context).formatTimestampForArabic(timestamp:  arabicNotificationList.time),style: TextStyle(fontWeight:FontWeight.w500,fontSize: 9.sp,color:Colors.black,),),
                    ],
                  ),
                  SizedBox(height: .4.h),
                  SizedBox(
                      width: 73.w,
                      child: Text(arabicNotificationList.notification.toString(),style: TextStyle(height: 1.2.sp,fontWeight:FontWeight.w400,color:Colors.black,fontSize:11.sp,
                          ),)),
                ],
              ),
            ),
          ],
        ),
      ),
    ],
  ),
);


Widget noNotification(context)=>Center(
  child: Container(
    child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Image(image: const AssetImage('assets/unDraw/notification1.png'),width: 80.w),
        Text(translator.isDirectionRTL(context)?'ليس لديك أي إشعارات':'you don\'t have any notifications',style: TextStyle(fontSize: 12.sp,color: color2),),
      ],
    ),
  ),
);

