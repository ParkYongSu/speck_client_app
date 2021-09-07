import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:photo_view/photo_view.dart';
import 'package:photo_view/photo_view_gallery.dart';
import 'package:speck_app/ui/ui_color.dart';
import 'package:speck_app/ui/ui_criteria.dart';

class PlacePhotoView extends StatefulWidget {
  final List<String> imagePath;
  final String placeName;
  final int count;

  const PlacePhotoView({Key key, this.imagePath, this.placeName, this.count}) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return PlacePhotoViewState();
  }
}

class PlacePhotoViewState extends State<PlacePhotoView> {
  UICriteria _uiCriteria = new UICriteria();

  int _page;
  @override
  void initState() {
    super.initState();
    _page = 1;
  }

  @override
  Widget build(BuildContext context) {
    _uiCriteria.init(context);

    return MaterialApp(
      title: "장소 사진 뷰어",
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        appBar: AppBar(
          toolbarHeight: _uiCriteria.appBarHeight,
          elevation: 0,
          centerTitle: true,
          titleSpacing: 0,
          backwardsCompatibility: false,
          // brightness: Brightness.dark,
          systemOverlayStyle: SystemUiOverlayStyle(statusBarColor: mainColor, statusBarBrightness: Brightness.dark),
          title: Stack(
              alignment: Alignment.center,
              children: <Widget>[
                Container(
                  padding: EdgeInsets.only(left: _uiCriteria.screenWidth * 0.008, right: _uiCriteria.horizontalPadding),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: <Widget>[
                      GestureDetector(
                          child: Icon(Icons.chevron_left_rounded,
                              color: Colors.white, size: _uiCriteria.screenWidth * 0.1),
                          onTap: () => Navigator.pop(context)),
                      RichText(
                        text: TextSpan(
                          style: TextStyle(fontSize: _uiCriteria.textSize16),
                          children: <TextSpan>[
                            TextSpan(text: "$_page", style: TextStyle(fontWeight: FontWeight.w700, color: Colors.white)),
                            TextSpan(text:  " / ${widget.count}", style: TextStyle(fontWeight: FontWeight.w500, color: greyB3B3BC))
                          ]
                        ),

                      )
                    ],
                  ),
                ),
                Text("${widget.placeName}",
                    style: TextStyle(
                      letterSpacing: 0.8,
                      fontSize: _uiCriteria.textSize16,
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                    )
                ),
              ]
          ),
          backgroundColor: mainColor,
        ),
        body: Container(
          width: _uiCriteria.screenWidth,
          height: _uiCriteria.totalHeight,
          alignment: Alignment.center,
          decoration: BoxDecoration(
              color: Colors.white,
          ),
          child: Stack(
            alignment: Alignment.center,
            children: [
              PhotoViewGallery.builder(
                  onPageChanged: (int page) {
                    print(page);
                    setState(() {
                      _page = page + 1;
                    });
                  },
                  loadingBuilder: (BuildContext context, ImageChunkEvent ice) {
                    return Container(
                      alignment: Alignment.center,
                      child: Container(
                        width: _uiCriteria.screenWidth * 0.065,
                        height: _uiCriteria.screenWidth * 0.065,
                        child: CircularProgressIndicator(
                          valueColor: AlwaysStoppedAnimation<Color>(mainColor),
                        ),
                      ),
                    );
                  },
                  backgroundDecoration: BoxDecoration(
                      color: Colors.white
                  ),
                  itemCount: widget.imagePath.length,
                  builder: (BuildContext context, int index) {
                    return PhotoViewGalleryPageOptions(
                      /// 런칭 후 변
                      imageProvider: Image.network(widget.imagePath[index], fit: BoxFit.fill,).image,
                      minScale: PhotoViewComputedScale.contained ,
                      // maxScale: PhotoViewComputedScale.covered
                    );
                  }),
              Container(
                padding: EdgeInsets.symmetric(horizontal: _uiCriteria.horizontalPadding),
                child: Row(
                  children: <Widget>[

                  ]
                )
              )
            ],
          ),
        ),
      ),
    );
  }
}
