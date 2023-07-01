 
 import 'dart:io';

import 'package:better_player/better_player.dart';
import 'package:dego/AppCubit/appCubitStates.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:localize_and_translate/localize_and_translate.dart';
import 'package:marquee/marquee.dart';
import 'package:sizer/sizer.dart';

import '../../AppCubit/appCubit.dart';

class BookmarkVideo extends StatefulWidget {
  String savedVideo;
  String savedPhoto;
  String savedText;

    BookmarkVideo(String this.savedVideo,String this.savedPhoto,String this.savedText, {Key? key}) : super(key: key);
 
   @override
   State<BookmarkVideo> createState() => _BookmarkVideoState();
 }
 
 class _BookmarkVideoState extends State<BookmarkVideo> {
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

   late BetterPlayerController _betterPlayerController;
   @override
   initState()  {
     super.initState();
     _createBottomBannerAd();
     _betterPlayerController = BetterPlayerController(
       const BetterPlayerConfiguration(
         autoPlay: true,
         fit: BoxFit.cover,
         aspectRatio: 8/19,
         autoDetectFullscreenAspectRatio: true,
         autoDetectFullscreenDeviceOrientation: true,handleLifecycle: true,
         looping: true,
         controlsConfiguration: BetterPlayerControlsConfiguration(
           enableProgressText: false,controlsHideTime: Duration(milliseconds: 0),
           showControlsOnInitialize: false,showControls: true,enablePlayPause: false,
           enableSkips: false,enablePip: false,enablePlaybackSpeed: false,enableMute: false,
           enableProgressBarDrag: false,enableProgressBar: false,enableAudioTracks: false,enableFullscreen: false,
           enableRetry: true,enableOverflowMenu: false,

         ),
       ),
       betterPlayerDataSource: BetterPlayerDataSource.network(widget.savedVideo),
     );

   }
   @override
   void dispose() {
     _bottomBannerAd.dispose();
     _betterPlayerController.dispose();
     super.dispose();
   }
   @override
   Widget build(BuildContext context) {
     return BlocConsumer<AppCubit,AppCubitStates>(
       listener: (BuildContext context, state) {  },
       builder: (BuildContext context, Object? state) {
         return AnnotatedRegion<SystemUiOverlayStyle>(
           value: const SystemUiOverlayStyle(
           statusBarColor: Colors.transparent,
           statusBarIconBrightness:  Brightness.light,
         ),
           child: Scaffold(
             appBar: null,
             body: Stack(
               children: [
                 BetterPlayer(
                   controller: _betterPlayerController,
                 ),
                 Positioned(
                   bottom: 10.3.h,
                   right: 6.w,
                   child: SizedBox(
                     width: 60.w,
                     height: 3.h,
                     child: Marquee(
                       text: widget.savedText,
                       style:  TextStyle(fontWeight: FontWeight.bold,color: Colors.white,fontSize: 11.sp,),
                       scrollAxis: Axis.horizontal,
                       crossAxisAlignment: CrossAxisAlignment.start,
                       blankSpace: 20.0,
                       velocity: 100.0,
                       pauseAfterRound: const Duration(seconds: 6),
                       startPadding: 10.0,
                       accelerationDuration: const Duration(seconds: 1),
                       accelerationCurve: Curves.linear,
                       decelerationDuration: const Duration(milliseconds: 500),
                       decelerationCurve: Curves.easeOut,
                     ),
                   ),),
                 Positioned(
                   bottom: 10.h,
                   left: 6.w,
                   child: Column(
                     children:
                     [
                       InkWell(
                           onTap: ()
                           {
                             if(AppCubit.get(context).visible)
                             {
                               if( AppCubit.get(context).IsSavedVideosInDatabaseList.containsValue(widget.savedVideo))
                                 AppCubit.get(context).deleteDataFromDatabaseForSavedVideos(savedVideo: widget.savedVideo);
                               else
                                 AppCubit.get(context).insertToDatabaseForSavedVideos(saveVideo: widget.savedVideo,photo:widget.savedPhoto,
                                     title: widget.savedText);
                             }
                             else
                               AppCubit.get(context).deleteDataFromDatabaseForDownloadVideos(downloadVideo: widget.savedVideo );
                           },
                           child: Image(fit: BoxFit.cover,image:AppCubit.get(context).visible?AssetImage('assets/images/bookmark.png')
                               :AssetImage('assets/images/trash.png'),
                               color:AppCubit.get(context).visible?AppCubit.get(context).IsSavedVideosInDatabaseList.containsValue(widget.savedVideo)?
                               Colors.yellow:Colors.white:Colors.white,height: 22.sp)),
                       SizedBox(height: 1.h),
                       AppCubit.get(context).visible?Text('Save'.tr(),style: TextStyle(fontSize: 11.sp,color: Colors.white,fontWeight: FontWeight.w600),):
                       Text('Delete'.tr(),style: TextStyle(fontSize: 11.sp,color: Colors.white,fontWeight: FontWeight.w600),),
                       SizedBox(height: 1.5.h),
                       InkWell(
                           onTap: AppCubit.get(context).progresss==0 && AppCubit.get(context).circle==0?()
                           {
                             AppCubit.get(context).startShare(video: widget.savedVideo,context: context);
                           }:null,
                           child: Image(fit: BoxFit.cover,image: const AssetImage('assets/images/forward.png'),color: Colors.white,height: 22.sp)),
                       SizedBox(height: 1.h),
                       Text('Share'.tr(),style: TextStyle(fontSize: 11.sp,color: Colors.white,fontWeight: FontWeight.w600),),
                       SizedBox(height: 1.5.h),
                       InkWell(
                           onTap: ()
                           {
                             AppCubit.get(context).showBottomSheet2(context,widget.savedVideo,widget.savedPhoto,widget.savedText);
                           },
                           child: Image(fit: BoxFit.cover,image: const AssetImage('assets/images/more.png'),color: Colors.white,height: 22.sp)),
                       SizedBox(height: 0.h),
                       Text('More'.tr(),style: TextStyle(fontSize: 11.sp,color: Colors.white,fontWeight: FontWeight.w600),),
                     ],
                   ),
                 ),
                 Align(
                   alignment: Alignment.bottomCenter,
                   child: _isBottomBannerAdLoaded? Container(
                     color: AppCubit.get(context).isDark
                         ? Colors.black
                         : Colors.white,
                     height: _bottomBannerAd.size.height.toDouble(),
                     width: _bottomBannerAd.size.width.toDouble(),
                     child: AdWidget(ad: _bottomBannerAd),
                   ):Container(),
                 ),
                 Positioned(
                     top: 7.h,
                     left: 6.w,
                     child: InkWell(
                         onTap: ()
                         {
                           Navigator.pop(context);
                         },
                         child: Image(image: AssetImage('assets/images/arrow-left.png'),height: 5.h,color: Colors.white,))),
                 if(AppCubit.get(context).circle != 0 || AppCubit.get(context).progresss != 0)
                   Positioned(
                       bottom: 33.h,
                       right: 35.w,
                       child: SizedBox(
                         height: 13.h,
                         width: 25.w,
                         child: const Image(image: AssetImage('assets/images/load.png',),color: Colors.white,),)),
                 if(AppCubit.get(context).circle != 0 || AppCubit.get(context).progresss != 0)
                   Positioned(
                       bottom: 36.5.h,
                       right: 46.5.w,
                       child: Text(AppCubit.get(context).circle!=0?
                       (AppCubit.get(context).circle * 100).toStringAsFixed(1):(AppCubit.get(context).progresss * 100).toStringAsFixed(1),
                         style: TextStyle(fontSize: 13.sp,color: Colors.white,fontWeight: FontWeight.w600),)),
               ],
             ),
           ),
         );
       },
     );
   }
 }
 