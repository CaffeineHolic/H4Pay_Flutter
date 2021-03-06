import 'dart:async';
import 'package:flutter/material.dart';
import 'package:h4pay/Page/Account/ChangePassword.dart';
import 'package:h4pay/Purchase/Gift.dart';
import 'package:h4pay/H4PayInfo.dart';
import 'package:h4pay/IntroPage.dart';
import 'package:h4pay/Purchase/Order.dart';
import 'package:h4pay/Page/Purchase/PurchaseList.dart';
import 'package:h4pay/Page/Voucher/VoucherList.dart';
import 'package:h4pay/Result.dart';
import 'package:h4pay/Success.dart';
import 'package:h4pay/User.dart';
import 'package:h4pay/Util.dart';
import 'package:h4pay/components/Button.dart';
import 'package:h4pay/main.dart';
import 'package:shared_preferences/shared_preferences.dart';

class MyPage extends StatefulWidget {
  final SharedPreferences prefs;
  final Map<String, int> badges;

  MyPage({required this.prefs, required this.badges});

  @override
  MyPageState createState() => MyPageState();
}

class MyPageState extends State<MyPage> {
  Future<H4PayUser?>? _fetchUser;
  MyHomePageState? myHomePageState;

  @override
  void initState() {
    super.initState();
    _fetchUser = userFromStorage();
  }

  FutureOr updateBadges(value) {
    myHomePageState = context.findAncestorStateOfType<MyHomePageState>();
    myHomePageState!.updateBadges();
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: FutureBuilder(
        future: _fetchUser,
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            final H4PayUser user = snapshot.data as H4PayUser;
            return Container(
              margin: EdgeInsets.all(18),
              child: Column(
                children: [
                  HelloUser(
                    user: user,
                    withButton: true,
                  ),
                  Container(
                    margin: EdgeInsets.only(top: 40),
                    child: InfoMenuList(
                      menu: [
                        InfoMenu(
                          icon: Icon(Icons.list_alt),
                          text: "?????? ??????",
                          badgeCount: widget.badges['order'],
                          onClick: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => PurchaseList(
                                    type: Order, appBar: true, title: "?????? ??????"),
                              ),
                            ).then(updateBadges);
                          },
                        ),
                        InfoMenuTitle(title: "??????"),
                        InfoMenu(
                          icon: Icon(Icons.markunread_mailbox),
                          text: "?????????",
                          badgeCount: widget.badges['gift'],
                          onClick: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => PurchaseList(
                                    type: Gift, appBar: true, title: "?????? ?????????"),
                              ),
                            ).then(updateBadges);
                          },
                        ),
                        InfoMenu(
                          icon: Icon(Icons.send),
                          text: "?????? ?????? ??????",
                          onClick: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => PurchaseList(
                                    type: SentGift,
                                    appBar: true,
                                    title: "?????? ?????? ??????"),
                              ),
                            );
                          },
                        ),
                        InfoMenu(
                          icon: Icon(Icons.card_giftcard),
                          text: "????????? ?????????",
                          badgeCount: widget.badges['voucher'],
                          onClick: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => VoucherList(),
                              ),
                            ).then(updateBadges);
                          },
                        ),
                        Container(
                          margin: EdgeInsets.only(top: 40),
                          child: InfoMenu(
                            icon: Icon(Icons.info),
                            text: "?????? ??????",
                            onClick: () {
                              navigateRoute(context, H4PayInfoPage());
                            },
                          ),
                        ),
                        InfoMenu(
                          icon: Icon(Icons.logout),
                          text: "????????????",
                          onClick: () {
                            showAlertDialog(context, "????????????", "????????? ???????????? ???????????????????",
                                () {
                              logout();
                              navigateRoute(
                                context,
                                IntroPage(canGoBack: false),
                              );
                            }, () {
                              Navigator.pop(context);
                            });
                          },
                        ),
                      ],
                    ),
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

class HelloUser extends StatelessWidget {
  final H4PayUser user;
  final bool withButton;

  HelloUser({required this.user, required this.withButton});
  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text.rich(
          TextSpan(
            children: [
              TextSpan(
                text: "???????????????,\n",
                style: TextStyle(fontSize: 25),
              ),
              TextSpan(
                text: "${user.name} ",
                style: TextStyle(fontSize: 35, fontWeight: FontWeight.w700),
              ),
              TextSpan(
                text: "???",
                style: TextStyle(fontSize: 30),
              )
            ],
          ),
        ),
        withButton
            ? H4PayButton(
                text: "??? ?????? ??????",
                onClick: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => MyInfoPage(
                        user: user,
                      ),
                    ),
                  );
                },
                backgroundColor: Theme.of(context).primaryColor,
              )
            : Container(),
      ],
    );
  }
}

class InfoMenuTitle extends StatelessWidget {
  final String title;
  const InfoMenuTitle({Key? key, required this.title}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(top: 40, bottom: 8),
      child: Text(
        title,
        style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700),
      ),
    );
  }
}

class InfoMenuList extends StatelessWidget {
  final List<Widget> menu;

  const InfoMenuList({Key? key, required this.menu}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return ListView(
      physics: NeverScrollableScrollPhysics(),
      shrinkWrap: true,
      children: menu,
    );
  }
}

class InfoMenu extends StatelessWidget {
  final int? badgeCount;
  final Icon icon;
  final String text;
  final Function()? onClick;

  const InfoMenu(
      {Key? key,
      this.badgeCount,
      required this.icon,
      required this.text,
      this.onClick})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onClick,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(margin: EdgeInsets.only(right: 8), child: icon),
              Text(
                text,
                textAlign: TextAlign.left,
              ),
              Spacer(),
              badgeCount != null && badgeCount != 0
                  ? Badge(count: badgeCount!)
                  : Container(),
            ],
          ),
          Divider(
            thickness: 1,
          )
        ],
      ),
    );
  }
}

class Badge extends StatefulWidget {
  final int count;
  Badge({required this.count});

  @override
  BadgeState createState() => BadgeState();
}

class BadgeState extends State<Badge> {
  @override
  Widget build(BuildContext context) {
    return ClipOval(
      child: Container(
        width: 20,
        height: 20,
        decoration: BoxDecoration(
          color: Colors.red,
          shape: BoxShape.circle,
        ),
        child: Center(
          child: Text(
            widget.count.toString(),
            style: TextStyle(color: Colors.white),
          ),
        ),
      ),
    );
  }
}

class MyInfoPage extends StatefulWidget {
  final H4PayUser user;
  MyInfoPage({required this.user});

  @override
  MyInfoPageState createState() => MyInfoPageState();
}

class MyInfoPageState extends State<MyInfoPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController prevPassword = TextEditingController();
  final TextEditingController pw2Change = TextEditingController();
  final TextEditingController pwCheck = TextEditingController();

  _withdraw(H4PayUser user) async {
    final H4PayResult withdrawResult = await withdraw(user.uid!, user.name!);
    if (withdrawResult.success) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => SuccessPage(
            canGoBack: false,
            title: "?????? ?????? ??????",
            successText: "?????? ?????? ?????? ??? ??? ?????? ???????????????.",
            bottomDescription: [Text("??????????????? ??????????????? ?????????????????????.")],
            actions: [
              H4PayButton(
                text: "????????? ????????????",
                onClick: () {
                  navigateRoute(
                    context,
                    IntroPage(
                      canGoBack: false,
                    ),
                  );
                },
                backgroundColor: Theme.of(context).primaryColor,
                width: double.infinity,
              )
            ],
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: H4PayAppbar(title: "??? ??????", height: 56.0, canGoBack: true),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(18),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.end,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            HelloUser(user: widget.user, withButton: false),
            InfoMenuList(
              menu: [
                InfoMenuTitle(title: "??? ??????"),
                InfoMenu(
                  icon: Icon(Icons.perm_identity),
                  text: widget.user.uid!,
                ),
                InfoMenu(
                  icon: Icon(Icons.badge),
                  text: widget.user.name!,
                ),
                InfoMenu(
                  icon: Icon(Icons.email),
                  text: widget.user.email!,
                ),
                InfoMenu(
                  icon: Icon(Icons.work),
                  text: roleStrFromLetter(widget.user.role!),
                ),
                InfoMenuTitle(title: "?????? ??????"),
                InfoMenu(
                  icon: Icon(Icons.password),
                  text: "???????????? ??????",
                  onClick: () {
                    showComponentDialog(
                      context,
                      ChangePWDialog(
                        formKey: _formKey,
                        prevPassword: prevPassword,
                        pw2Change: pw2Change,
                        pwCheck: pwCheck,
                        user: widget.user,
                      ),
                      true,
                    );
                  },
                ),
              ],
            ),
          ],
        ),
      ),
      bottomNavigationBar: Container(
        padding: EdgeInsets.all(18),
        child: H4PayButton(
          text: "H4Pay ????????????",
          onClick: () async {
            final H4PayUser? user = await userFromStorage();
            if (user != null) {
              showAlertDialog(
                context,
                "????????????",
                "?????? ????????? ?????? ?????????, ?????? ?????? ??????, ?????? ?????? ?????? ????????? ?????? ???????????????.\n????????? ?????????????????????????",
                () {
                  _withdraw(user);
                },
                () {
                  Navigator.pop(context);
                },
              );
            }
          },
          backgroundColor: Colors.red,
          width: double.infinity,
        ),
      ),
    );
  }
}
