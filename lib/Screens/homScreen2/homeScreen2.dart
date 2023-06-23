
import 'dart:async';
import 'dart:io';

import 'package:better_player/better_player.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:conditional_builder_null_safety/conditional_builder_null_safety.dart';
import 'package:dego/AppCubit/appCubit.dart';
import 'package:dego/AppCubit/appCubitStates.dart';
import 'package:dego/Models/homeModel/homeModel.dart';
import 'package:dego/Screens/searchScreen/searchScreen.dart';
import 'package:dego/Screens/videoOpen/videoOpen.dart';
import 'package:dego/Shared/casheHelper/sharedPreferance.dart';
import 'package:dego/Shared/constans/constans.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:localize_and_translate/localize_and_translate.dart';
import 'package:marquee/marquee.dart';
import 'package:paginate_firestore/paginate_firestore.dart';
import 'package:sizer/sizer.dart';

class HomeScreen2 extends StatefulWidget {
    const HomeScreen2({Key? key}) : super(key: key);
   @override
   State<HomeScreen2> createState() => _HomeScreen2State();
 }
 class _HomeScreen2State extends State<HomeScreen2> {
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
         if(CasheHelper.getData(key: 'currentVideo')!=null&&CasheHelper.getData(key: 'currentVideo')!=0)
         {
           AppCubit.get(context).contoller = PageController(keepPage: true, initialPage: CasheHelper.getData(key: 'currentVideo'));
         }
         return ConditionalBuilder(
           condition: true,
           builder: (BuildContext context) {
             return  Scaffold(
               backgroundColor: Colors.black,
               body: Stack(
                 children: [
                   TabBarView(
                     controller: AppCubit.get(context).tabController,
                     children:
                     [
                       PaginateFirestore(
                         itemBuilder: (context, documentSnapshots, index)
                         {
                           AppCubit.get(context).VideosList = [];
                           for (var doc in documentSnapshots) {
                             AppCubit.get(context).VideosList.add(HomeModel(video: doc['Vi'],text: doc['Tx'],docId: doc.id,
                                 likes: doc.data()!.toString().contains('likes') ? doc['likes'] : 0,
                                 views:doc.data()!.toString().contains('views') ? doc['views'] : 0,photo: doc['Ph']
                             ));
                           }
                           return VideoItem(AppCubit.get(context).VideosList[index],index);
                         }, // orderBy is compulsary to enable pagination
                         query: AppCubit.get(context).GetHomeVideos(),
                         itemBuilderType: PaginateBuilderType.pageView,
                         pageController: AppCubit.get(context).contoller,
                         scrollDirection: Axis.vertical,includeMetadataChanges: true,
                         onPageChanged: (index) {
                           setState(() {
                             CasheHelper.SaveData(key: 'currentVideo', value: AppCubit.get(context).currentIndex);
                           });
                           if(AppCubit.get(context).interstialadCountForHomeScreen==6)
                           {
                             Timer(const Duration(milliseconds: 500),()
                             {
                               AppCubit.get(context).showInterstialAd();
                             });
                           }
                           else if(AppCubit.get(context).interstialadCountForHomeScreen==0) {
                             AppCubit.get(context).loadInterstialAd();
                           }
                           AppCubit.get(context).adCountForHomeScreen();
                         },
                         shrinkWrap:true ,
                         bottomLoader:const Text(''),
                         initialLoader:  Container(height: 100.h,width: 100.w,color: Colors.black,),
                         isLive: false,
                         itemsPerPage:CasheHelper.getData(key:'currentVideo')!=null
                             &&CasheHelper.getData(key:'currentVideo')!=0?CasheHelper.getData(key:'currentVideo'):1,
                       ),
                       PaginateFirestore(
                         itemBuilder: (context, documentSnapshots, index)
                         {
                           AppCubit.get(context).AllList = [];
                           for (var doc in documentSnapshots) {
                             AppCubit.get(context).AllList.add(HomeModel(photo: doc['Ph'],video: doc['Vi'],text: doc['Tx'],
                               docId: doc.id,views:doc.data()!.toString().contains('views') ? doc['views'] : 0,
                               likes:doc.data()!.toString().contains('likes') ? doc['likes'] : 0, ));
                           }

                           return AllVideosWidget(AppCubit.get(context).AllList[index],context,index);

                         }, // orderBy is compulsary to enable pagination
                         query: AppCubit.get(context).GetAllVideos(),
                         itemBuilderType: PaginateBuilderType.gridView,
                         gridDelegate:  const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 2, childAspectRatio: 1.5/2.8,
                           crossAxisSpacing: 0,
                           mainAxisSpacing: 0,),
                         scrollDirection: Axis.vertical,
                         itemsPerPage:4,
                         shrinkWrap: false,
                         bottomLoader:const Text(''),
                         initialLoader: const Center(child: CircularProgressIndicator(backgroundColor: Colors.black,)),
                         onEmpty: const Center(child: CircularProgressIndicator(backgroundColor: Colors.black,)),
                         isLive: true,
                       ),
                     ],
                   ),
                   Padding(
                     padding:  EdgeInsets.only(top: 5.h),
                     child: Align(
                       alignment: Alignment.topCenter,
                       child: TabBar(
                         isScrollable: true,
                         physics: const BouncingScrollPhysics(),
                         labelColor: Colors.white,
                         unselectedLabelColor: Colors.grey,
                         indicatorColor: Colors.white,
                         indicatorSize:TabBarIndicatorSize.label ,
                         labelPadding: EdgeInsets.symmetric(horizontal: 8.sp),
                         controller: AppCubit.get(context).tabController,
                         onTap: (index)
                         {

                         },

                         tabs:  [
                           Tab(text: 'Home'.tr(),),
                           Tab(text: 'All'.tr()),
                         ],
                       ),
                     ),
                   ),
                   Positioned(
                     top: 5.5.h,
                     left:  6.w,
                     child: IconButton(icon: Image(image: const AssetImage('assets/images/search.png'),
                         height: 18.sp,
                         color: Colors.white), onPressed: () {
                       navigateTo(context,  const SearchScreen());
                     },),),
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
                 ],
               ),
             );
           },
           fallback: (BuildContext context)=>const Center(child: CircularProgressIndicator()),
         );
       },
     );
   }
 }


 class VideoItem extends StatefulWidget {
  HomeModel videosList;
  int index;

    VideoItem(HomeModel this.videosList, int this.index, {Key? key}) : super(key: key);

   @override
   State<VideoItem> createState() => _VideoItemState();
 }

 class _VideoItemState extends State<VideoItem> {
   late BetterPlayerController _betterPlayerController;
   bool buttonClicked = true;
   @override
   initState()  {
     super.initState();
       AppCubit.get(context).currentIndex=widget.index;
     AppCubit.get(context).incrementViews(docId: widget.videosList.docId);
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
       betterPlayerDataSource: BetterPlayerDataSource.network(widget.videosList.video.toString()),
     );

   }
   @override
  void dispose() {
     _betterPlayerController.dispose();
    super.dispose();
  }
   @override
   Widget build(BuildContext context) {
     return BlocConsumer<AppCubit,AppCubitStates>(
       listener: (BuildContext context, state) {  },
       builder: (BuildContext context, Object? state) {
         return Stack(
           alignment: Alignment.centerLeft,
           children: [
             BetterPlayer(
               controller: _betterPlayerController,
             ),
             Positioned(
               bottom: 8.h,
               left: translator.isDirectionRTL(context)?5.w:6.w,
               child: Column(
                 children:
                 [
                   GestureDetector(
                       onTap:buttonClicked? ()
                       {
                         if(AppCubit.get(context).isItInFav(video:widget.videosList.video))
                         {
                           buttonClicked=false;
                           AppCubit.get(context).deleteDataFromDatabase(video:widget.videosList.video);
                           AppCubit.get(context).removeLoveFunction(widget.videosList.docId).then((value)
                           {
                             buttonClicked=true;
                           });
                         }
                         else
                         {
                           buttonClicked=false;
                           AppCubit.get(context).insertToDatabase(video:widget.videosList.video);
                           AppCubit.get(context).loveFunction(widget.videosList.docId).then((value)
                           {
                             buttonClicked=true;
                           });
                         }
                       }:null,
                       child: Image(fit: BoxFit.cover,image:  const AssetImage('assets/images/heart.png'),color:
                       AppCubit.get(context).isItInFav(video:widget.videosList.video)?Colors.red:Colors.white,height: 22.sp)),
                   SizedBox(height: .2.h),
                   StreamBuilder<QuerySnapshot>(
                     stream:AppCubit.get(context).getLikes(),
                     builder: (BuildContext context, AsyncSnapshot<dynamic> snapshot) {
                       int likes = 0;
                       if (!snapshot.hasData || snapshot.data!.size == 0) {
                         return Text('0',style: TextStyle(fontSize: 11.sp,color: Colors.white,fontWeight: FontWeight.w600),);
                       } else {
                         likes = 0;
                         for (var doc in snapshot.data!.docs) {
                           if (doc.id == widget.videosList.docId)
                           {

                             likes = doc.data()!.toString().contains('likes') ? doc['likes'] : 0;
                           }
                         }
                       }
                       return Text(AppCubit.get(context).formatViews(likes),style: TextStyle(fontSize:translator.isDirectionRTL(context)?12.sp:11.sp,color: Colors.white,fontWeight: FontWeight.w600),);
                     },
                   ),
                   //    Text(AppCubit.get(context).formatViews(widget.videosList.likes),style: TextStyle(fontSize: 11.sp,color: Colors.white,fontWeight: FontWeight.w600),),
                   SizedBox(height: 1.5.h),
                   InkWell(
                       onTap: ()
                       {
                         if( AppCubit.get(context).IsSavedVideosInDatabaseList.containsValue(widget.videosList.video)) {
                           AppCubit.get(context).deleteDataFromDatabaseForSavedVideos(savedVideo: widget.videosList.video);
                         } else {
                           AppCubit.get(context).insertToDatabaseForSavedVideos(saveVideo: widget.videosList.video,
                               photo:widget.videosList.photo,title: widget.videosList.text );
                         }
                       },
                       child: Image(fit: BoxFit.cover,image: const AssetImage('assets/images/bookmark.png'),
                           color:AppCubit.get(context).IsSavedVideosInDatabaseList.containsValue(widget.videosList.video)?
                           Colors.yellow:Colors.white,height: 22.sp)),
                   SizedBox(height: .2.h),
                   Text('Save'.tr(),style: TextStyle(fontSize:translator.isDirectionRTL(context)?12.sp :11.sp,color: Colors.white,fontWeight: FontWeight.w600),),
                   SizedBox(height: 1.5.h),
                   InkWell(
                       onTap: AppCubit.get(context).circle == 0 && AppCubit.get(context).progresss == 0?()
                       {
                         AppCubit.get(context).startShare(video:widget.videosList.video,context: context);
                       }:null,
                       child: Image(fit: BoxFit.cover,image: const AssetImage('assets/images/forward.png'),color: Colors.white,height: 22.sp)),
                   SizedBox(height: .2.h),
                   Text('Share'.tr(),style: TextStyle(fontSize: translator.isDirectionRTL(context)?12.sp :11.sp,color: Colors.white,fontWeight: FontWeight.w600),),
                   SizedBox(height: 1.0.h),
                   InkWell(
                       onTap: ()
                        {
                         AppCubit.get(context).showBottomSheet2(context,widget.videosList.video,widget.videosList.photo,widget.videosList.text);
                       },
                       child: Image(fit: BoxFit.cover,image: const AssetImage('assets/images/more.png'),color: Colors.white,height: 22.sp)),
                   Text('More'.tr(),style: TextStyle(fontSize: translator.isDirectionRTL(context)?12.sp :11.sp,color: Colors.white,fontWeight: FontWeight.w600),),
                 ],
               ),
             ),
             Positioned(
               bottom: 10.h,
               right: 6.w,
               child: SizedBox(
                 width: 60.w,
                 height: 3.h,
                 child: Marquee(
                   text: widget.videosList.text.toString(),
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
                 /*
                 Text(widget.videosList.text.toString(),
                   style: TextStyle(color:Colors.white,),textDirection: TextDirection.rtl,textAlign: TextAlign.start,)),

                  */
               ),),
             if(AppCubit.get(context).circle != 0 || AppCubit.get(context).progresss != 0)
             Positioned(
                 bottom: 28.h,
                 right: 35.w,
                 child: SizedBox(
                     height: 13.h,
                     width: 25.w,
                     child: const Image(image: AssetImage('assets/images/load.png',),color: Colors.white,),)),
             if(AppCubit.get(context).circle != 0 || AppCubit.get(context).progresss != 0)
             Positioned(
                 bottom: 31.5.h,
                 right: 46.5.w,
                 child: Text(AppCubit.get(context).circle!=0?
                 (AppCubit.get(context).circle * 100).toStringAsFixed(1):(AppCubit.get(context).progresss * 100).toStringAsFixed(1),
                   style: TextStyle(fontSize: 13.sp,color: Colors.white,fontWeight: FontWeight.w600),)),
           ],
         );
       },
     );
   }
 }

class AllVideosWidget extends StatefulWidget {
  HomeModel allList;
  int index;

   AllVideosWidget(HomeModel this.allList, BuildContext context, int this.index, {Key? key}) : super(key: key);

  @override
  State<AllVideosWidget> createState() => _AllVideosWidgetState();
}

class _AllVideosWidgetState extends State<AllVideosWidget> {

@override
  void initState() {
    super.initState();
  }
  @override
  Widget build(BuildContext context) {
    return BlocConsumer<AppCubit,AppCubitStates>(
      listener: (BuildContext context, state) {  },
      builder: (BuildContext context, Object? state) {
        return InkWell(
          onTap: ()
          {
            if(AppCubit.get(context).interstialadCountForAllScreen==3)
            {
              Timer(const Duration(milliseconds: 500),()
              {
                AppCubit.get(context).showInterstialAd();
                AppCubit.get(context).loadInterstialAd();
              });
            }
            else if(AppCubit.get(context).interstialadCountForAllScreen==0) {
              AppCubit.get(context).loadInterstialAd();
            }
            AppCubit.get(context).adCountForAllScreen();
            AppCubit.get(context).incrementViews(docId:widget.allList.docId);
            navigateTo(context, VideoOpen(widget.allList.video!,widget.allList.docId!,widget.allList.likes!
                ,widget.allList.text!,widget.allList.photo!,widget.index));
          },
          child: Container(
            decoration: BoxDecoration(color: AppCubit.get(context).isDark?Colors.black:Colors.black,image: DecorationImage(image: CachedNetworkImageProvider('${widget.allList.photo}',),fit: BoxFit.cover),
              border: Border.all(
                color:AppCubit.get(context).isDark?Colors.black:Colors.white,
                width: 1,
              ),),
            child: Align(
              alignment: Alignment.bottomRight,
              child: Padding(
                padding: EdgeInsets.only(bottom: translator.isDirectionRTL(context)?8.sp:5.sp,right:8.sp),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  textDirection: TextDirection.ltr,
                  children: [
                    Text(AppCubit.get(context).formatViews(widget.allList.views),style: TextStyle(color:Colors.white,fontSize: 11.sp,fontWeight: FontWeight.w500),),
                    SizedBox(width: 1.5.sp,),
                    Padding(
                      padding:  EdgeInsets.only(top: translator.isDirectionRTL(context)?3.sp:0),
                      child: Image.asset(
                        'assets/images/play.png',
                        width: translator.isDirectionRTL(context)?9.sp:8.sp,
                        height:translator.isDirectionRTL(context)?9.sp:8.sp,color: Colors.white,
                      ),
                    )
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
