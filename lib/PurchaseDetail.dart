import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:barcode_widget/barcode_widget.dart';
import 'package:h4pay_flutter/Payment.dart';
import 'package:h4pay_flutter/Product.dart';
import 'package:h4pay_flutter/Purchase.dart';
import 'package:h4pay_flutter/User.dart';
import 'package:h4pay_flutter/Util.dart';
import 'package:screen_brightness/screen_brightness.dart';
import 'package:wakelock/wakelock.dart';
import 'package:collection/collection.dart';

class PurchaseDetailPage extends StatefulWidget {
  final Purchase purchase;

  const PurchaseDetailPage({Key? key, required this.purchase})
      : super(key: key);
  @override
  PurchaseDetailPageState createState() => PurchaseDetailPageState();
}

class PurchaseDetailPageState extends State<PurchaseDetailPage> {
  Future<Map>? _fetchProduct;
  double? brightness;

  @override
  void initState() {
    super.initState();
    _fetchProduct = _loadThings();
    _setUpBrightness();
  }

  _setUpBrightness() async {
    await ScreenBrightness.setScreenBrightness(1.0);
    await Wakelock.toggle(enable: true);
  }

  Future<Map> _loadThings() async {
    Map result = {};
    result['product'] = await fetchProduct('PurchaseDetail');
    result['user'] = await userFromStorage();
    return result;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("주문 상세 내역"),
        leading: new IconButton(
          icon: new Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context, brightness);
          },
        ),
      ),
      body: FutureBuilder(
        future: _fetchProduct,
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            final Map data = snapshot.data as Map;
            final List<Product> products = data['product'];
            final H4PayUser user = data['user'];
            return Container(
              margin: EdgeInsets.all(40),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  BarcodeWidget(
                    barcode: Barcode.code128(),
                    data: widget.purchase.orderId,
                  ),
                  Spacer(),
                  ReceiptText(title: "주문 번호", content: widget.purchase.orderId),
                  ReceiptText(
                    title: "상품명",
                    content: getProductName(
                      widget.purchase.item,
                      products
                          .singleWhereOrNull(
                            (element) =>
                                element.id ==
                                int.parse(widget.purchase.item.entries
                                    .elementAt(0)
                                    .key),
                          )!
                          .productName,
                    ),
                  ),
                  ReceiptText(
                    title: "주문 일시",
                    content: getPrettyDateStr(widget.purchase.date, true),
                  ),
                  ReceiptText(
                    title: "만료 일시",
                    content: getPrettyDateStr(widget.purchase.expire, true),
                  ),
                  ReceiptText(
                    title: "결제 금액",
                    content: getPrettyAmountStr(widget.purchase.amount),
                  ),
                  Container(
                    child: widget.purchase.uid == null
                        ? Column(
                            children: [
                              ReceiptText(
                                title: "수신자 ID",
                                content: widget.purchase.uidto!,
                              )
                            ],
                          )
                        : Container(),
                  ),
                ],
              ),
            );
          } else {
            return CircularProgressIndicator();
          }
        },
      ),
    );
  }
}