import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../models/category/category_model.dart';
import '../../common/config.dart';
import '../../common/constants.dart';
import '../../data/boxes.dart';
import '../../models/app_model.dart';
import '../../modules/dynamic_layout/index.dart';
import '../../routes/flux_navigate.dart';
import '../../widgets/common/address_dropdown.dart';
import '../../widgets/home/index.dart';
import '../base_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({this.scrollController});

  final ScrollController? scrollController;

  @override
  State<StatefulWidget> createState() {
    return _HomeScreenState();
  }
}

class _HomeScreenState extends BaseScreen<HomeScreen> {
  // @override
  // bool get wantKeepAlive => true;
  List<CategoryItemConfig> catConfigItems = [];
  List<String> addresses = []; // Example list of addresses
  @override
  void dispose() {
    printLog('[Home] dispose');
    super.dispose();
  }

  @override
  void initState() {
    printLog('[Home] initState');
    super.initState();

    Future.microtask(() => Provider.of<CategoryModel>(context, listen: false)
        .refreshCategoryList());
  }

  void afterClosePopup(int updatedTime) {
    SettingsBox().popupBannerLastUpdatedTime = updatedTime;
  }

  @override
  Widget build(BuildContext context) {
    printLog('[Home] build');
    return Selector<AppModel, (AppConfig?, String, String?)>(
      selector: (_, model) =>
          (model.appConfig, model.langCode, model.countryCode),
      builder: (_, value, child) {
        var appConfig = value.$1;
        var langCode = value.$2;
        final countryCode = value.$3;

        if (appConfig == null) {
          return kLoadingWidget(context);
        }

        var isStickyHeader = appConfig.settings.stickyHeader;
        final horizontalLayoutList =
            List.from(appConfig.jsonData['HorizonLayout']);
        final isShowAppbar = horizontalLayoutList.isNotEmpty &&
            horizontalLayoutList.first['layout'] == 'logo';

        final bannerConfig = appConfig.settings.smartEngagementBannerConfig;

        final isShowPopupBanner = (SettingsBox().popupBannerLastUpdatedTime !=
                bannerConfig.popup.updatedTime) ||
            bannerConfig.popup.alwaysShowUponOpen;

        return Scaffold(
          backgroundColor: Theme.of(context).colorScheme.background,
          body: Stack(
            children: <Widget>[
              if (appConfig.background != null)
                isStickyHeader
                    ? SafeArea(
                        child: HomeBackground(config: appConfig.background),
                      )
                    : HomeBackground(config: appConfig.background),

              // // HomeLayout should be rendered separately from the container
              // HomeLayout(
              //   isPinAppBar: isStickyHeader,
              //   isShowAppbar: isShowAppbar,
              //   showNewAppBar:
              //       appConfig.appBar?.shouldShowOn(RouteList.home) ?? false,
              //   configs: appConfig.jsonData,
              //   key: Key('$langCode$countryCode'),
              //   scrollController: widget.scrollController,
              // ),
              // const SizedBox(height: 15.0),

              // This is the dropdown and search bar container that is placed separately
              Positioned(
                top: 0.0,
                left: 16.0,
                right: 16.0,
                child: Container(
                  margin: const EdgeInsets.only(
                      bottom: 0.0, left: 5.0, right: 5.0, top: 30.0),
                  // decoration: BoxDecoration(
                  //   border: Border.all(
                  //     color: Colors.grey, // Border color
                  //     width: 1.0, // Border width
                  //   ),
                  //   borderRadius: BorderRadius.circular(8.0),
                  // ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      HeaderSearch(
                        config: HeaderConfig.fromJson({
                          'title': 'search...',
                          'marginTop': 0.0,
                          'marginBottom': 0.0
                        }),
                        onSearch: () {
                          FluxNavigate.pushNamed(
                            RouteList.homeSearch,
                            forceRootNavigator: true,
                          );
                        },
                      ),
                      Row(
                        children: <Widget>[
                          const Icon(
                            Icons.location_on,
                            color: amamPrimaryColor,
                          ), // Map icon
                          const SizedBox(width: 8.0),
                          const Text('Deliver To:'),
                          const SizedBox(width: 8.0),
                          Expanded(
                            child: AddressDropdown(),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              // Container around HomeLayout with top margin to create space below search bar
              Container(
                margin: const EdgeInsets.only(
                    top: 100.0), // Add top margin to create space
                // decoration: BoxDecoration(
                //   border: Border.all(
                //     color: Colors.yellow, // Border color
                //     width: 1.0, // Border width
                //   ),
                //   borderRadius: BorderRadius.circular(8.0),
                // ),
                child: HomeLayout(
                  isPinAppBar: isStickyHeader,
                  isShowAppbar: isShowAppbar,
                  showNewAppBar:
                      appConfig.appBar?.shouldShowOn(RouteList.home) ?? false,
                  configs: appConfig.jsonData,
                  key: Key('$langCode$countryCode'),
                  scrollController: widget.scrollController,
                ),
              ),

              // Remove `WrapStatusBar` because we already have `SafeArea`
              // inside `HomeLayout`
              // const WrapStatusBar(),
            ],
          ),
        );
      },
    );
  }
}
