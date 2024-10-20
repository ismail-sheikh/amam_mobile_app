import 'package:flutter/material.dart';

import '../../../common/config.dart';
import '../../../models/index.dart' show PaymentMethod;
import '../../../services/index.dart';
import '../../../widgets/common/flux_image.dart';
import '../../../widgets/html/index.dart';

class PaymentMethodItem extends StatelessWidget {
  const PaymentMethodItem(
      {Key? key,
      required this.paymentMethod,
      this.onSelected,
      this.selectedId,
      this.descWidget})
      : super(key: key);
  final PaymentMethod paymentMethod;
  final Function(String?)? onSelected;
  final String? selectedId;
  final Widget? descWidget;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        InkWell(
          onTap: () {
            if (onSelected != null) onSelected!(paymentMethod.id);
          },
          child: Container(
            decoration: BoxDecoration(
                color: paymentMethod.id == selectedId
                    ? Theme.of(context).primaryColorLight
                    : Colors.transparent),
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 10),
              child: Column(
                children: [
                  Row(
                    children: <Widget>[
                      Radio<String?>(
                        value: paymentMethod.id,
                        groupValue: selectedId,
                        onChanged: onSelected,
                      ),
                      const SizedBox(width: 10),
                      Builder(builder: (context) {
                        return Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              Row(
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: [
                                  if (paymentMethod.title != null) ...[
                                    Flexible(
                                      child: Services()
                                          .widget
                                          .renderShippingPaymentTitle(
                                              context, paymentMethod.title!),
                                    ),
                                    const SizedBox(width: 15),
                                  ],
                                  if (kPayments[paymentMethod.id] != null || paymentMethod.icon != null)
                                    FluxImage(
                                      imageUrl: paymentMethod.icon != null ? paymentMethod.icon: kPayments[paymentMethod.id],
                                      height: 30,
                                    ),
                                ],
                              ),
                              if (paymentMethod.description != null)
                                if (paymentMethod.id == selectedId) ...[
                                  const SizedBox(height: 15),
                                  HtmlWidget(paymentMethod.description!),
                                ],
                            ],
                          ),
                        );
                      })
                    ],
                  ),
                  if (descWidget != null) descWidget!
                ],
              ),
            ),
          ),
        ),
        const Divider(height: 1)
      ],
    );
  }
}
