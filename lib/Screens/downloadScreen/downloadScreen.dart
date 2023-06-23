
import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:conditional_builder_null_safety/conditional_builder_null_safety.dart';
import 'package:dego/AppCubit/appCubitStates.dart';
import 'package:dego/Screens/BookmarkVideo/BookmarkVideo.dart';
import 'package:dego/Screens/notificationScreen/notificationScreen.dart';
import 'package:dego/Screens/searchScreen/searchScreen.dart';
import 'package:dego/Screens/testScreen/testScreen.dart';
import 'package:dego/Shared/constans/constans.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:localize_and_translate/localize_and_translate.dart';
import 'package:sizer/sizer.dart';
import '../../AppCubit/appCubit.dart';

class DownloadScreen extends StatefulWidget {
  const DownloadScreen({Key? key}) : super(key: key);

  @override
  State<DownloadScreen> createState() => _DownloadScreenState();
}

class _DownloadScreenState extends State<DownloadScreen> {
  late BannerAd _bottomBannerAd;
  bool _isBottomBannerAdLoaded = false;
  void _createBottomBannerAd() {
    _bottomBannerAd = BannerAd(
      adUnitId: Platform.isAndroid
          ? AppCubit.get(context).bannarAdNumber
          : 'ca-app-pub-9120321344983600/4388505138',
      size: AdSize.banner,
      request: AdRequest(),
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
            title: Text('Downloads'.tr(),style: TextStyle(fontSize:translator.activeLanguageCode=='en'?16.sp:17.sp,fontWeight: FontWeight.w700,color: AppCubit.get(context).isDark?
            Colors.white:color2),),
            actions:
            [
              IconButton(onPressed: ()
              {
                AppCubit.get(context).soundsFunc();
                navigateTo(context, const SearchScreen());
              }, icon:Padding(
                padding:  EdgeInsets.only(left: translator.isDirectionRTL(context)?0:15.sp,right:translator.isDirectionRTL(context)?15.sp:0),
                child: Image(image:  const AssetImage('assets/images/search.png'),height: 18.sp,color: AppCubit.get(context).isDark?
                Colors.white:color3,),
              ),
                padding: EdgeInsets.zero, ),
              IconButton(onPressed: ()
              {
                AppCubit.get(context).soundsFunc();
                AppCubit.get(context).showBottomSheet(context);
              }, icon:Image(image: const AssetImage('assets/images/menu.png'),color: AppCubit.get(context).isDark?
              Colors.white:color3,),
              ),
              SizedBox(width:translator.isDirectionRTL(context)?1.w:0,),
            ],
          ),
          body: Padding(
            padding:  EdgeInsets.all(5.sp),
            child: ConditionalBuilder(
              condition: AppCubit.get(context).downloadedVideosList.isNotEmpty,
              builder: (BuildContext context)=>ListView.separated(
                  itemBuilder: (context,index)=>AnimationConfiguration.staggeredList(
                    position: index,
                    delay: const Duration(milliseconds: 100),
                    child: SlideAnimation(
                      duration: const Duration(milliseconds: 2500),
                      curve: Curves.fastLinearToSlowEaseIn,
                      child: FadeInAnimation(
                          curve: Curves.fastLinearToSlowEaseIn,
                          duration: const Duration(milliseconds: 2500),
                          child: DownloadWidget(AppCubit.get(context).downloadedVideosList[index],context)),
                    ),
                  ),
                  separatorBuilder: (context,index)=>SizedBox(height: 3.sp),
                  itemCount: AppCubit.get(context).downloadedVideosList.length),
              fallback: (BuildContext context) =>noDownload(),
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
              : Container(height: _bottomBannerAd.size.height.toDouble()),
        );
      },
    );
  }
}

Widget DownloadWidget(Map<String, dynamic> downloadedVideosList, BuildContext context)=>Stack(
  children: [
    Container(
      height: 24.h,
      width: double.infinity,
      decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20.sp),
          image:DecorationImage(fit: BoxFit.cover,image: CachedNetworkImageProvider('${downloadedVideosList['downloadPhoto']}'))),
    ),
    Positioned(
      top: .5.h,left: 1.w,
      child: IconButton(
        icon: Image(height: 21.sp,image: const AssetImage('assets/images/trash.png',),color: Colors.white),
        onPressed: () {
          AppCubit.get(context).deleteDataFromDatabaseForDownloadVideos(downloadVideo: downloadedVideosList['downloadVideo'] );
        },),
    ),
    Positioned(
      top: 9.h,left: 41.w,
      child: IconButton(
        iconSize: 10.w,
        icon: Image(
            height: 28.sp,
            image: const AssetImage('assets/images/play.png',),color: Colors.white),
        onPressed: () {
          AppCubit.get(context).soundsFunc();
          navigateTo(context, BookmarkVideo(downloadedVideosList['downloadVideo'],downloadedVideosList['downloadPhoto'],downloadedVideosList['downloadTitle'],));
        },),
    ),
    Positioned(
      bottom: 1.5.h,right: 4.w,
      child: SizedBox(
          width: 70.w,
          child: Text(
            textDirection: TextDirection.rtl,textAlign: TextAlign.start,'${downloadedVideosList['downloadTitle']}',style:
          TextStyle(fontSize: 12.sp,color: Colors.white,fontWeight: FontWeight.w800),)),
    ),
  ],
);

Widget noDownload()=> Center(
  child: Container(
    child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [

        Image(image: const AssetImage('assets/unDraw/download2.png'),width: 80.w),
      //  Text('downloadedVideos'.tr(),style: TextStyle(fontSize:translator.activeLanguageCode=='en'? 12.sp:14.sp,color: color2,fontWeight: FontWeight.w400),),
        /*
        AnimatedTextKit(
          animatedTexts: [
            TypewriterAnimatedText(
              'downloadedVideos'.tr(),
              speed: Duration(milliseconds: 80),
              textStyle: TextStyle(fontSize:translator.activeLanguageCode=='en'? 12.sp:14.sp,color: color2,fontWeight: FontWeight.w400)
            ),
          ],
          isRepeatingAnimation: false,
          repeatForever: false,
          displayFullTextOnTap: true,
          stopPauseOnTap: false,
        ),

         */
        SlideFadeTransition(
          curve: Curves.elasticOut,
          delayStart: Duration(milliseconds: 200),
          animationDuration: Duration(milliseconds: 1200),
          offset: 2,
          direction: Direction.vertical,
          child: FittedBox(child: Text('downloadedVideos'.tr(),style: TextStyle(fontSize:translator.activeLanguageCode=='en'? 13.sp:14.sp,color: color2,fontWeight: FontWeight.w400),)),
        ),
      ],
    ),
  ),
);
