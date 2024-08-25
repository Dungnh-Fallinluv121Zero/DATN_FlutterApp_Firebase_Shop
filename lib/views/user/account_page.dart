import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:line_awesome_flutter/line_awesome_flutter.dart';
import 'package:provider/provider.dart';
import 'package:untitled/model/user_model.dart';
import 'package:untitled/provider/auth_provider.dart';
import 'package:untitled/views/home2_page.dart';
import 'package:untitled/views/user/address/user_address_page.dart';
import 'package:untitled/views/user/edit_profile_page.dart';

class AccountPage extends StatefulWidget {
  final UserModel? userModel;

  const AccountPage({Key? key, required this.userModel}) : super(key: key);

  @override
  _AccountPageState createState() => _AccountPageState();
}

class _AccountPageState extends State<AccountPage> {
  late String imageUrl;
  late List<MenuItem> myOrdersItems;
  late List<MenuItem> paymentAccountItems;
  late List<MenuItem> settingAccountItems;

  @override
  void initState() {
    super.initState();
    imageUrl = widget.userModel!.photo;
    myOrdersItems = [
      MenuItem(title: "Order 1", onPressed: () {}),
      MenuItem(title: "Order 2", onPressed: () {}),
    ];

    paymentAccountItems = [
      MenuItem(title: "Add Credit Card", onPressed: () {}),
      MenuItem(title: "Add PayPal", onPressed: () {}),
    ];

    settingAccountItems = [
      MenuItem(
          title: "Setting 1",
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => UserAddressPage(
                  userId: widget.userModel!.uid,
                ),
              ),
            );
          }),
      MenuItem(title: "Setting PayPal", onPressed: () {}),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          onPressed: () {
            Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(
                  builder: (context) => HomePage2(userModel: widget.userModel!),
                ),
                (route) => false);
          },
          icon: const Icon(CupertinoIcons.arrow_left_circle),
        ),
        title: Text(
          'Account Setting',
          style: Theme.of(context).textTheme.titleLarge,
          textAlign: TextAlign.center,
        ),
      ),
      body: SingleChildScrollView(
        child: Container(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              SizedBox(
                height: 120,
                child: imageUrl.isEmpty
                    ? CircleAvatar(
                        backgroundColor: Colors.blueAccent,
                        radius: 50,
                        child: Icon(
                          Icons.account_circle,
                          size: 50,
                          color: Colors.white,
                        ))
                    : CircleAvatar(
                        backgroundImage: NetworkImage(imageUrl),
                        radius: 50,
                      ),
              ),
              SizedBox(height: 10),
              Text(
                widget.userModel!.name,
                style: Theme.of(context).textTheme.headline6,
              ),
              Text(
                widget.userModel!.email,
                style: Theme.of(context).textTheme.bodyText2,
              ),
              SizedBox(height: 20),
              ElevatedButton.icon(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) =>
                          EditProfilePage(userModel: widget.userModel!),
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  side: BorderSide.none,
                  shape: const StadiumBorder(),
                ),
                icon: Icon(Icons.edit_outlined),
                label: Text(
                  'Edit Information',
                  style: TextStyle(color: Colors.blue),
                ),
              ),
              SizedBox(height: 20),
              ProfileMenuWidget(
                title: "My Orders",
                icon: LineAwesomeIcons.shopping_cart,
                onPress: () {
                  _showSubMenu(context, myOrdersItems);
                },
              ),
              ProfileMenuWidget(
                title: "Payment Account",
                icon: LineAwesomeIcons.paypal_credit_card,
                onPress: () {
                  _showSubMenu(context, paymentAccountItems);
                },
              ),
              ProfileMenuWidget(
                title: "Setting",
                icon: LineAwesomeIcons.cog,
                onPress: () {
                  _showSubMenu(context, settingAccountItems);
                },
              ),
              ProfileMenuWidget(
                title: "Help",
                icon: LineAwesomeIcons.helping_hands,
                onPress: () {},
              ),
              ProfileMenuWidget(
                title: "Logout",
                icon: LineAwesomeIcons.alternate_sign_out,
                textColor: Colors.red,
                endIcon: false,
                onPress: () {
                  Provider.of<AuthProvider>(context, listen: false)
                      .signOut(context);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showSubMenu(BuildContext context, List<MenuItem> items) {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return ListView.builder(
          shrinkWrap: true,
          itemCount: items.length,
          itemBuilder: (BuildContext context, int index) {
            return InkWell(
              splashColor: Colors.yellow,
              child: ListTile(
                title: Center(child: Text(items[index].title)),
                onTap: items[index].onPressed,
              ),
            );
          },
        );
      },
    );
  }
}

class MenuItem {
  final String title;
  final VoidCallback onPressed;

  MenuItem({required this.title, required this.onPressed});
}

class ProfileMenuWidget extends StatelessWidget {
  const ProfileMenuWidget({
    super.key,
    required this.title,
    required this.icon,
    required this.onPress,
    this.endIcon = true,
    this.textColor,
  });

  final String title;
  final IconData icon;
  final VoidCallback onPress;
  final bool endIcon;
  final Color? textColor;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      onTap: onPress,
      leading: Container(
        width: 30,
        height: 30,
        decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(100),
            color: Colors.blueAccent.withOpacity(0.1)),
        child: Icon(icon, color: Colors.blueAccent),
      ),
      title: Text(
        title,
        style: TextStyle(color: textColor, fontWeight: FontWeight.w600),
      ),
      trailing: endIcon
          ? Container(
              width: 30,
              height: 30,
              decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(100),
                  color: Colors.blueAccent.withOpacity(0.1)),
              child: const Icon(LineAwesomeIcons.angle_right,
                  size: 18, color: Colors.grey),
            )
          : null,
    );
  }
}
