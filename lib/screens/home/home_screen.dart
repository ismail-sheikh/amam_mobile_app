import 'package:flutter/material.dart';
import 'package:inspireui/widgets/smart_engagement_banner/index.dart';
import 'package:provider/provider.dart';

import '../../../models/category/category_model.dart';
import '../../app.dart';
import '../../common/config.dart';
import '../../common/constants.dart';
import '../../data/boxes.dart';
import '../../models/app_model.dart';
import '../../modules/dynamic_layout/index.dart';
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
              Positioned(
                top: 50.0,
                left: 16.0,
                right: 16.0,
                child: Row(
                  children: <Widget>[
                    const Icon(
                      Icons.location_on,
                      color: amamPrimaryColor,
                    ), // Map icon
                    const SizedBox(width: 8.0),
                    const Text('Deliver To:'),
                    const SizedBox(width: 8.0),
                    Expanded(
                      child:
                          AddressDropdown(), // Your updated AddressDropdown widget
                    ),
                  ],
                ),
              ),
              HomeLayout(
                isPinAppBar: isStickyHeader,
                isShowAppbar: isShowAppbar,
                showNewAppBar:
                    appConfig.appBar?.shouldShowOn(RouteList.home) ?? false,
                configs: appConfig.jsonData,
                key: Key('$langCode$countryCode'),
                scrollController: widget.scrollController,
              ),
              SmartEngagementBanner(
                context: App.fluxStoreNavigatorKey.currentContext!,
                config: bannerConfig,
                enablePopup: isShowPopupBanner,
                afterClosePopup: () {
                  afterClosePopup(bannerConfig.popup.updatedTime);
                },
                childWidget: (data) {
                  return DynamicLayout(config: data);
                },
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

  List<DropdownMenuItem<String>> _buildDropdownItems() {
    return [
      ...addresses.map((address) {
        return DropdownMenuItem<String>(
          value: address,
          child: Text(address),
        );
      }).toList(),
      const DropdownMenuItem<String>(
        value: 'add_new',
        child: Text('Add New Address'),
      ),
    ];
  }

  void _showAddAddressDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Add New Address'),
          content: TextField(
            decoration:
                const InputDecoration(hintText: 'Enter your new address'),
            onSubmitted: (newAddress) {
              setState(() {
                addresses.add(newAddress);
              });
              Navigator.of(context).pop();
            },
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: const Text('Add'),
              onPressed: () {
                // Handle address addition logic here
              },
            ),
          ],
        );
      },
    );
  }
}
