import 'package:flutter/material.dart';
import 'package:snapcrescent_mobile/asset/asset_timeline.dart';
import 'package:snapcrescent_mobile/asset/asset_view_arguments.dart';
import 'package:snapcrescent_mobile/asset/screens/asset_view.dart';
import 'package:snapcrescent_mobile/asset/screens/widgets/asset_thumbnail.dart';
import 'package:snapcrescent_mobile/asset/state/asset_state.dart';
import 'package:snapcrescent_mobile/asset/unified_asset.dart';
import 'package:snapcrescent_mobile/utils/constants.dart';
import 'package:snapcrescent_mobile/utils/date_utilities.dart';

class AssetYearGrid extends StatefulWidget {
  
  final List<AssetTimeline> assetTimelines;
  AssetYearGrid(this.assetTimelines);

  @override
  createState() => _AssetYearGridState(assetTimelines);
}

class _AssetYearGridState extends State<AssetYearGrid> {

  final List<AssetTimeline> assetTimelines;
  DateTime currentDateTime = DateTime.now();

  _AssetYearGridState(this.assetTimelines);

  @override
  void initState() {
    super.initState();


  }




  _body() {
    return ListView.builder(
            itemCount: assetTimelines.length,
            physics:
                NeverScrollableScrollPhysics(), // to disable GridView's scrolling
            shrinkWrap: true,
            itemBuilder: (BuildContext context, int assetTimelineIndex) {
              var keys = assetTimelines;
              return Column(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Column(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Padding(
                          padding: EdgeInsets.all(5),
                          child: Text(
                              _getFormattedGroupKey(keys
                                  .elementAt(assetTimelineIndex)
                                  .creationDateTime),
                              style: TextStyle(
                                color: Colors.white,
                              )),
                        ),
                        GridView.builder(
                            gridDelegate:
                                const SliverGridDelegateWithMaxCrossAxisExtent(
                              maxCrossAxisExtent: 150,
                              crossAxisSpacing: 8,
                              mainAxisSpacing: 8,
                            ),
                            physics:
                                NeverScrollableScrollPhysics(), // to disable GridView's scrolling
                            shrinkWrap: true,
                            itemCount: keys.elementAt(assetTimelineIndex).count,
                            itemBuilder: (BuildContext context2, index) {
                              //final asset = keys.elementAt(timeLineIndex).unifiedAssets!.elementAt(index);
                              final asset = UniFiedAsset(
                                  AppAssetType.PHOTO,
                                  AssetSource.CLOUD,
                                  keys
                                      .elementAt(assetTimelineIndex)
                                      .creationDateTime,
                                  0);

                              return GestureDetector(
                                onLongPress: () {
                                  asset.selected = !asset.selected;
                                  setState(() {});
                                },
                                onTap: () {
                                  //Grid is in selection mode
                                  if (AssetState().isAnyItemSelected()) {
                                    asset.selected = !asset.selected;
                                    setState(() {});
                                  } //No asset is selected, proceed to asset detail page
                                  else {
                                    _onAssetTap(context,
                                        AssetState().assetList.indexOf(asset));
                                  }
                                },
                                child: AssetThumbnail(
                                    asset,
                                    asset.assetSource == AssetSource.CLOUD
                                        ? Future.value(asset.asset)
                                        : asset.assetEntity!.thumbnailData,
                                    asset.selected),
                              );
                            })
                      ])
                ],
              );
            },
          );
  }

    _getFormattedGroupKey(DateTime groupDateTime) {
    String formattedKey = "";
    if (currentDateTime.year == groupDateTime.year) {
      if (DateUtilities().weekNumber(currentDateTime) ==
          DateUtilities().weekNumber(groupDateTime)) {
        if (currentDateTime.day == groupDateTime.day) {
          formattedKey = 'Today';
        } else {
          formattedKey = DateUtilities()
              .formatDate(groupDateTime, DateUtilities.currentWeekFormat);
        }
      } else {
        formattedKey = DateUtilities()
            .formatDate(groupDateTime, DateUtilities.currentYearFormat);
      }
    } else {
      formattedKey = DateUtilities()
          .formatDate(groupDateTime, DateUtilities.defaultYearFormat);
    }

    return formattedKey;
  }

    _onAssetTap(BuildContext context, int assetIndex) {
    AssetViewArguments arguments = AssetViewArguments(assetIndex: assetIndex);

    Navigator.pushNamed(
      context,
      AssetViewScreen.routeName,
      arguments: arguments,
    );
  }

  @override
  Widget build(BuildContext context) {
    return _body();
  }
}
