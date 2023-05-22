
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dego/AppCubit/appCubit.dart';
import 'package:dego/AppCubit/appCubitStates.dart';
import 'package:dego/Models/homeModel/homeModel.dart';
import 'package:dego/Shared/constans/constans.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:paginate_firestore/paginate_firestore.dart';
import 'package:sizer/sizer.dart';

class HomeScreen extends StatefulWidget {
   HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  Widget build(BuildContext context) {
    return BlocConsumer<AppCubit,AppCubitStates>(
      listener: (BuildContext context, state)
      {
        if(state is getHomeState)
        {
        }
      },
      builder: (BuildContext context, Object? state) {
        return PaginateFirestore(
          query: AppCubit.get(context).GetAppbarListItems(),
          itemBuilder: (context, documentSnapshots, index)
          {
            AppCubit.get(context).HomeList = [];
            for (var doc in documentSnapshots) {
              AppCubit.get(context).HomeList.add(HomeModel(ph: doc['ph']));
            }

            return BuildHomeWidget(AppCubit.get(context).HomeList[index]);

          }, // orderBy is compulsary to enable pagination
          itemBuilderType: PaginateBuilderType.gridView,
          scrollDirection: Axis.vertical,
          itemsPerPage:4,
          gridDelegate:  SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 2, childAspectRatio: .6,
            crossAxisSpacing: 1.5,
            mainAxisSpacing: 1.5,),
          shrinkWrap: false,
          bottomLoader: Text(''),includeMetadataChanges: true,
          isLive: true,initialLoader:  Center(child: CircularProgressIndicator()),onEmpty: Center(
          child: Text(
            'No videos',
            style: TextStyle(color:Colors.black,fontSize: 12.sp,fontWeight: FontWeight.w600,fontFamily: 'VarelaRound',),

          ),
        ),
        );
      },
    );
  }
}




 class BuildHomeWidget extends StatefulWidget {
  HomeModel homeList;

    BuildHomeWidget(HomeModel this.homeList, {Key? key}) : super(key: key);

   @override
   State<BuildHomeWidget> createState() => _BuildHomeWidgetState();
 }

 class _BuildHomeWidgetState extends State<BuildHomeWidget> {
   @override
   Widget build(BuildContext context) {
     return BlocConsumer<AppCubit,AppCubitStates>(
       listener: (BuildContext context, state) {  },
       builder: (BuildContext context, Object? state) {
         return Container(
           decoration: BoxDecoration(color: Colors.white,image: DecorationImage(image: NetworkImage('${widget.homeList.ph}',),fit: BoxFit.cover)),
           child: Align(
             alignment: Alignment.bottomRight,
             child: Padding(
               padding:  EdgeInsets.only(bottom: 9.sp,right:8.sp),
               child: Row(
                 mainAxisAlignment: MainAxisAlignment.end,
                 crossAxisAlignment: CrossAxisAlignment.center,
                 children: [
                   Text('5.1k',style: TextStyle(color:Colors.white,fontSize: 10.sp,fontWeight: FontWeight.w500),),
                   SizedBox(width: 1.5.sp,),
                   Image.asset(
                     'assets/images/play.png',
                     width: 8.sp,
                     height: 8.sp,color: Colors.white,
                   )
                 ],
               ),
             ),
           ),
         );
       },
     );
   }
 }


/*
Widget AppbarWidgett() => BlocConsumer<AppCubit,AppCubitStates>(
  listener: (BuildContext context, state) {  },
  builder: (BuildContext context, Object? state) {
    return Padding(
      padding: EdgeInsets.only(left: 5.w),
      child: Container(
        height: 6.h,
        child: StreamBuilder<QuerySnapshot>(
          stream: AppCubit.get(context).GetAppbarList(),
          builder: (context, snapshot) {
            if (!snapshot.hasData || snapshot.data!.size == 0)
              return SizedBox(height: 0.h,);
            else
            {
              AppCubit.get(context).AppbarList = [];
              AppCubit.get(context).AppbarListIds=[];
              for (var doc in snapshot.data!.docs) {
                AppCubit.get(context).AppbarList.add(doc['name']);
                AppCubit.get(context).AppbarListIds.add(doc.id);
              }
              return ListView.separated(
                  scrollDirection: Axis.horizontal,
                  itemBuilder: (context,index)=>AppbarItem(AppCubit.get(context).AppbarList[index],
                      AppCubit.get(context).AppbarListIds[index]),
                  separatorBuilder: (context,index)=>SizedBox(width: 2.w,),
                  itemCount: AppCubit.get(context).AppbarList.length);
            }
          },
        ),
      ),
    );
  },
);

 */

 class AppbarWidget extends StatefulWidget {
    AppbarWidget({Key? key}) : super(key: key);

   @override
   State<AppbarWidget> createState() => _AppbarWidgetState();
 }

 class _AppbarWidgetState extends State<AppbarWidget> {
   @override
   Widget build(BuildContext context) {
     return BlocConsumer<AppCubit,AppCubitStates>(
       listener: (BuildContext context, state) {  },
       builder: (BuildContext context, Object? state) {
         return Padding(
           padding: EdgeInsets.only(left: 5.w),
           child: Container(
             height: 6.h,
             child: StreamBuilder<QuerySnapshot>(
               stream: AppCubit.get(context).GetAppbarList(),
               builder: (context, snapshot) {
                 if (!snapshot.hasData || snapshot.data!.size == 0)
                   return SizedBox(height: 0.h,);
                 else
                 {
                   AppCubit.get(context).AppbarList = [];
                   AppCubit.get(context).AppbarListIds=[];
                   for (var doc in snapshot.data!.docs) {
                     AppCubit.get(context).AppbarList.add(doc['name']);
                     AppCubit.get(context).AppbarListIds.add(doc.id);
                   }
                   return ListView.separated(
                       scrollDirection: Axis.horizontal,
                       itemBuilder: (context,index)=>AppbarItem(AppCubit.get(context).AppbarList[index],
                           AppCubit.get(context).AppbarListIds[index]),
                       separatorBuilder: (context,index)=>SizedBox(width: 2.w,),
                       itemCount: AppCubit.get(context).AppbarList.length);
                 }
               },
             ),
           ),
         );
       },
     );
   }
 }



/*
Widget AppbarItemm(String appbarList, String appbarListId)=>BlocConsumer<AppCubit,AppCubitStates>(
  listener: (BuildContext context, state) {  },
  builder: (BuildContext context, Object? state) {
    return  InkWell(
      onTap: ()
      {
        AppCubit.get(context).function(appbarListId);

      },
      child:   Center(
        child: Container(
            decoration: BoxDecoration(color: Colors.white,borderRadius:BorderRadius.circular(8.sp)),
            child: Padding(
              padding:  EdgeInsets.all(3.sp),
              child: Text('${appbarList}',style: TextStyle(fontSize: 15.sp,color: color2,fontWeight: FontWeight.w600),),
            )),
      ),
    );
  },
);

 */

 class AppbarItem extends StatefulWidget {
  String appbarList;

  String appbarListId;

    AppbarItem(String this.appbarList, String this.appbarListId, {Key? key}) : super(key: key);

   @override
   State<AppbarItem> createState() => _AppbarItemState();
 }

 class _AppbarItemState extends State<AppbarItem> {
   @override
   Widget build(BuildContext context) {
     return BlocConsumer<AppCubit,AppCubitStates>(
       listener: (BuildContext context, state) {  },
       builder: (BuildContext context, Object? state) {
         return  InkWell(
           onTap: ()
           {
               AppCubit.get(context).function(widget.appbarListId);
           },
           child:   Center(
             child: Container(
                 decoration: BoxDecoration(color: Colors.white,borderRadius:BorderRadius.circular(8.sp)),
                 child: Padding(
                   padding:  EdgeInsets.all(3.sp),
                   child: Text('${widget.appbarList}',style: TextStyle(fontSize: 15.sp,color: color2,fontWeight: FontWeight.w600),),
                 )),
           ),
         );
       },
     );
   }
 }


