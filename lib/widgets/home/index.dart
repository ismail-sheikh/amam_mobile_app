import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart' as foundation;
import 'package:flutter/material.dart';
import 'package:inspireui/icons/constants.dart';
import 'package:provider/provider.dart';

import '../../../models/category/category_model.dart';
import '../../../models/entities/index.dart';
import '../../common/config.dart';
import '../../common/constants.dart';
import '../../common/tools.dart';
import '../../models/app_model.dart';
import '../../models/cart/cart_base.dart';
import '../../models/notification_model.dart';
import '../../modules/dynamic_layout/config/logo_config.dart';
import '../../modules/dynamic_layout/dynamic_layout.dart';
import '../../modules/dynamic_layout/helper/helper.dart';
import '../../modules/dynamic_layout/logo/logo.dart';
import '../../routes/flux_navigate.dart';
import '../../screens/common/app_bar_mixin.dart';
import '../../services/index.dart';
import '../common/dialogs.dart';
import 'preview_overlay.dart';

class HomeLayout extends StatefulWidget {
  final configs;
  final bool isPinAppBar;
  final bool isShowAppbar;
  final bool showNewAppBar;
  final bool enableRefresh;
  final ScrollController? scrollController;

  const HomeLayout({
    this.configs,
    this.isPinAppBar = false,
    this.isShowAppbar = true,
    this.showNewAppBar = false,
    this.enableRefresh = true,
    this.scrollController,
    Key? key,
  }) : super(key: key);

  @override
  State<HomeLayout> createState() => _HomeLayoutState();
}

class _HomeLayoutState extends State<HomeLayout> with AppBarMixin {
  late List widgetData;
  Map<String?, Category> categoriesData = {};

  final Services _service = Services();
  Map<String, dynamic> topCategoriesLayout = {
    'layout': 'category',
    'type': 'image',
    'wrap': false,
    'showShortDescription': true,
    'size': 1.0,
    // 'radius': 150.0,
    // 'spacing': 12,
    // 'line': false,
    'line': true,
    'marginLeft': 0,
    'marginRight': 0,
    // 'marginTop': 10,
    // 'marginBottom': 10,
    // 'paddingX': 12,
    'paddingY': 5,
    // 'marginX': 0,
    // 'marginY': 0,
    // 'hideTitle': false,
    // 'noBackground': false,
    // 'imageBorderWidth': 0,
    // 'imageBorderColor': 'ffe61a00',
    // 'imageBorderStyle': 'dot',
    // 'imageSpacing': 0,
    // 'labelFontSize': 14,
    'labelFontSize': 12,
    // 'horizontalItem': false,
    'horizontalItem': true,
    // 'separateWidth': 24,
    // 'gradientStyle': false,
    // 'border': 0.6,
    // 'enableBorder': false,
    'textAlignment': 'topCenter',
    // 'imageBoxFit': 'fill',
    // 'pos': 400
  };

  dynamic verticalWidgetData;
  var _useNestedScrollView = true;

  bool isPreviewingAppBar = false;

  bool cleanCache = false;
  // CategoryModel get categoryModel =>
  //     Provider.of<CategoryModel>(context, listen: false);

  Future<void> initTopCategories() async {
    var categories = <Map<String, dynamic>>[];
    // printLog(categoriesData);
    try {
      final categorieList = await _service.api.getCategories();
      if (categorieList == null) {
        return;
      }
      for (var cat in categorieList) {
        if (cat.parent == '0') {
          var image = cat.image;
          if (image != null && image.contains('trello')) {
            image = 'assets/images/app_icon.png';
          }
          categories.add(<String, dynamic>{
            'category': cat.id,
            'image': image,
            'showText': true,
            'originalColor': true,
            'keepDefaultTitle': true,
            'showDescription': false,
            'productType': false,
            'title': cat.displayName,
            'onSale': false,
            'isFeatured': false
          });
        }
      }
      topCategoriesLayout['items'] = categories;
    } catch (err) {
      printLog('initTopCategories $err');
    }
    setState(() {});
  }

  void waitForInitTopCategories() async {
    await initTopCategories();
  }

  @override
  void initState() {
    super.initState();
    Future.microtask(() => Provider.of<CategoryModel>(context, listen: false)
        .refreshCategoryList());
    Future.microtask(() => categoriesData =
        Provider.of<CategoryModel>(context, listen: false).categoryList);

    /// init config data
    // waitForInitTopCategories();
    widgetData =
        List<Map<String, dynamic>>.from(widget.configs['HorizonLayout']);
    if (widgetData.isNotEmpty && widget.isShowAppbar && !widget.showNewAppBar) {
      widgetData.removeAt(0);
    }
    // widgetData.insert(3, topCategoriesLayout);
    // printLog(topCategoriesLayout);

    /// init single vertical layout
    if (widget.configs['VerticalLayout'] != null &&
        widget.configs['VerticalLayout'].isNotEmpty) {
      Map verticalData =
          Map<String, dynamic>.from(widget.configs['VerticalLayout']);
      verticalData['type'] = 'vertical';
      verticalWidgetData = verticalData;
    }
  }

  @override
  void didUpdateWidget(HomeLayout oldWidget) {
    if (oldWidget.configs != widget.configs) {
      /// init config data
      List data =
          List<Map<String, dynamic>>.from(widget.configs['HorizonLayout']);
      if (data.isNotEmpty && widget.isShowAppbar && !widget.showNewAppBar) {
        data.removeAt(0);
      }
      widgetData = data;

      /// init vertical layout
      if (widget.configs['VerticalLayout'] != null) {
        Map verticalData =
            Map<String, dynamic>.from(widget.configs['VerticalLayout']);
        verticalData['type'] = 'vertical';
        verticalWidgetData = verticalData;
      }
      setState(() {});
    }
    super.didUpdateWidget(oldWidget);
  }

  Future<void> onRefresh() async {
    /// No need refreshBlogs anymore because we will reload appConfig like below
    // await Provider.of<ListBlogModel>(context, listen: false).refreshBlogs();

    // refresh the product request and clean up cache
    setState(() => cleanCache = true);
    await Future<void>.delayed(const Duration(milliseconds: 1000));
    setState(() => cleanCache = false);

    var appModel = Provider.of<AppModel>(context, listen: false);
    final oldAppConfig = appModel.appConfig;

    // reload app config will refresh all tabs in tabbar, not only home screen
    final newAppconfig = await appModel.loadAppConfig(config: kLayoutConfig);

    // Show a popup if there is a big difference in config
    if (newAppconfig?.tabBar.length != oldAppConfig?.tabBar.length) {
      await showDialogNewAppConfig(context);
    }
  }

  Widget renderAppBar() {
    if (Layout.isDisplayDesktop(context)) {
      return const SliverToBoxAdapter();
    }

    List<dynamic> horizonLayout = widget.configs['HorizonLayout'] ?? [];
    Map logoConfig = horizonLayout.firstWhere(
        (element) => element['layout'] == 'logo',
        orElse: () => Map<String, dynamic>.from({}));
    var config = LogoConfig.fromJson(logoConfig);

    /// customize theme
    // config
    //   ..opacity = 0.9
    //   ..iconBackground = HexColor('DDDDDD')
    //   ..iconColor = HexColor('330000')
    //   ..iconOpacity = 0.8
    //   ..iconRadius = 40
    //   ..iconSize = 24
    //   ..cartIcon = MenuIcon(name: 'cart')
    //   ..showSearch = false
    //   ..showLogo = true
    //   ..showCart = true
    //   ..showMenu = true;

    return SliverAppBar(
      pinned: widget.isPinAppBar,
      snap: true,
      floating: true,
      titleSpacing: 0,
      elevation: 0,
      forceElevated: true,
      backgroundColor: config.color ??
          Theme.of(context).colorScheme.background.withOpacity(config.opacity),
      title: PreviewOverlay(
          index: 0,
          config: logoConfig as Map<String, dynamic>?,
          builder: (value) {
            final appModel = Provider.of<AppModel>(context, listen: true);
            return Selector<CartModel, int>(
              selector: (_, cartModel) => cartModel.totalCartQuantity,
              builder: (context, totalCart, child) {
                return Selector<NotificationModel, int>(
                  selector: (context, notificationModel) =>
                      notificationModel.unreadCount,
                  builder: (context, unreadCount, child) {
                    return Logo(
                      config: config,
                      logo: appModel.themeConfig.logo,
                      notificationCount: unreadCount,
                      totalCart: totalCart,
                      onSearch: () {
                        FluxNavigate.pushNamed(RouteList.homeSearch);
                      },
                      onCheckout: () {
                        FluxNavigate.pushNamed(RouteList.cart);
                      },
                      onTapNotifications: () {
                        FluxNavigate.pushNamed(RouteList.notify);
                      },
                      onTapDrawerMenu: () =>
                          NavigateTools.onTapOpenDrawerMenu(context),
                    );
                  },
                );
              },
            );
          }),
    );
  }

  // void addProductsListToWidgetData(categoriesData) async {
  //   if (categoriesData != null) {
  //     for (var cat in categoriesData) {
  //       var productList = await _service.api.fetchProductsByCategory(
  //           categoryId: cat.id, page: 1, orderBy: 'date', order: 'desc');
  //     }
  //     printLog(widgetData);
  //   }
  // }

  @override
  Widget build(BuildContext context) {
    if (widget.configs == null) return const SizedBox();
    // addProductsListToWidgetData(categoriesData);
    ErrorWidget.builder = (error) {
      if (foundation.kReleaseMode) {
        return const SizedBox();
      }
      //   return Consumer<CategoryModel>(
      //     builder:(context, provider, child){
      //     final categories = provider.categories ;
      // })
      return Container(
        constraints: const BoxConstraints(minHeight: 150),
        decoration: BoxDecoration(
            color: Colors.lightBlue.withOpacity(0.5),
            borderRadius: BorderRadius.circular(5)),
        margin: const EdgeInsets.symmetric(
          horizontal: 15,
        ),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),

        /// Hide error, if you're developer, enable it to fix error it has
        child: Center(
          child: Text('Error in ${error.exceptionAsString()}'),
        ),
      );
    };
    if (horizontalLayouts.length == 1 && widget.enableRefresh) {
      _useNestedScrollView = false;
    }

    return SafeArea(
      bottom: false,
      child: verticalWidgetData == null
          ? CustomScrollView(
              cacheExtent: 2000,
              slivers: horizontalLayouts,
              controller: widget.scrollController,
              physics: const BouncingScrollPhysics(),
            )
          : horizontalLayouts.isNotEmpty
              ? NestedScrollView(
                  controller: widget.scrollController,
                  headerSliverBuilder: (context, _) {
                    return horizontalLayouts;
                  },
                  body: verticalLayout,
                )
              : verticalLayout,
    );
  }

  List<Widget> get horizontalLayouts => <Widget>[
        if (widget.showNewAppBar) sliverAppBarWidget,
        if (widget.isShowAppbar && !widget.showNewAppBar) renderAppBar(),
        if (widget.enableRefresh)
          CupertinoSliverRefreshControl(
            onRefresh: onRefresh,
            refreshTriggerPullDistance: 175,
          ),
        if (widgetData.isNotEmpty)
          SliverList(
            delegate: SliverChildBuilderDelegate(
              (context, index) {
                var config = widgetData[index];

                /// if show app bar, the preview should plus +1
                var previewIndex = widget.isShowAppbar ? index + 1 : index;
                Widget body = PreviewOverlay(
                  index: previewIndex,
                  config: config,
                  builder: (value) {
                    return DynamicLayout(config: value, cleanCache: cleanCache);
                  },
                );

                /// Use row to limit the drawing area.
                /// If you delete the row, setting the size for the body will not work.
                return LayoutBuilder(
                  builder: (_, constraints) => Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      ConstrainedBox(
                        constraints: BoxConstraints(
                          maxWidth: constraints.maxWidth < kLimitWidthScreen
                              ? constraints.maxWidth
                              : kLimitWidthScreen,
                        ),
                        child: body,
                      ),
                    ],
                  ),
                );
              },
              childCount: widgetData.length,
            ),
          ),
      ];

  Widget get verticalLayout => PreviewOverlay(
        index: widgetData.length,
        config: verticalWidgetData,
        builder: (value) {
          return Services().widget.renderVerticalLayout(
                value,
                horizontalLayouts.isEmpty || _useNestedScrollView == false,
                onRefresh: widget.enableRefresh && _useNestedScrollView == false
                    ? onRefresh
                    : null,
              );
        },
      );
}
