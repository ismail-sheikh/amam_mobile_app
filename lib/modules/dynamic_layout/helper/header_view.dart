import 'package:flutter/material.dart';

import '../../../generated/l10n.dart';
import '../config/box_shadow_config.dart';
import '../config/header_config.dart';
import '../header/header_text.dart';
import 'countdown_timer.dart';
import 'helper.dart';

class HeaderView extends StatelessWidget {
  final String? headerText;
  final VoidCallback? callback;
  final bool showSeeAll;
  final bool showCountdown;
  final Duration countdownDuration;
  final double? verticalMargin;
  final double? horizontalMargin;

  const HeaderView({
    this.headerText,
    this.showSeeAll = false,
    Key? key,
    this.callback,
    this.verticalMargin = 6.0,
    this.horizontalMargin,
    this.showCountdown = false,
    this.countdownDuration = const Duration(),
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    var isDesktop = Layout.isDisplayDesktop(context);

    return SizedBox(
      width: screenSize.width,
      child: Container(
        // 0x0E9E9E9E
        color: const Color(0xFFD7D7D7),
        // Theme.of(context).colorScheme.background
        margin: EdgeInsets.only(top: verticalMargin!, bottom: 5.0),
        // padding: EdgeInsets.only(
        //   left: horizontalMargin ?? 8.0,
        //   top: verticalMargin!,
        //   right: horizontalMargin ?? 8.0,
        //   bottom: verticalMargin!,
        // ),
        child: Row(
          textBaseline: TextBaseline.alphabetic,
          crossAxisAlignment: CrossAxisAlignment.baseline,
          children: <Widget>[
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (isDesktop) ...[
                    const Divider(height: 50, indent: 30, endIndent: 30),
                  ],
                  HeaderText(
                      config: HeaderConfig(
                          title: headerText,
                          textColor: '#000000',
                          marginBottom: 0.0,
                          marginTop: 0.0,
                          paddingLeft: 8.0,
                          paddingRight: 0.0,
                          fontSize: 15.0,
                          showSearch: false,
                          boxShadow: BoxShadowConfig(
                            blurRadius: 10.0,
                            spreadRadius: 10.0,
                          ))),

                  // Text(
                  //   headerText ?? '',
                  //   style: isDesktop
                  //       ? Theme.of(context)
                  //           .textTheme
                  //           .headlineSmall!
                  //           .copyWith(fontWeight: FontWeight.w700)
                  //       : Theme.of(context).textTheme.titleMedium,
                  // ),
                  if (showCountdown)
                    Row(
                      children: [
                        Text(
                          S.of(context).endsIn('').toUpperCase(),
                          style: Theme.of(context)
                              .textTheme
                              .titleMedium!
                              .copyWith(
                                color: Theme.of(context)
                                    .colorScheme
                                    .secondary
                                    .withOpacity(0.8),
                              )
                              .apply(fontSizeFactor: 0.6),
                        ),
                        CountDownTimer(countdownDuration),
                      ],
                    ),
                  if (isDesktop) const SizedBox(height: 10),
                ],
              ),
            ),
            if (showSeeAll)
              InkResponse(
                onTap: callback,
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(
                    S.of(context).seeAll,
                    style: Theme.of(context)
                        .textTheme
                        .bodySmall!
                        .copyWith(color: Theme.of(context).primaryColor),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
