import 'dart:async';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:line_awesome_flutter/line_awesome_flutter.dart';
import 'package:provider/provider.dart';
import 'package:untitled/model/user_model.dart';
import 'package:untitled/provider/cart_provider.dart';
import 'package:untitled/utils/utils.dart';
import 'package:untitled/views/product/cart_page.dart';
import 'package:untitled/views/user/account_page.dart';
import 'package:untitled/views/user/address/location_page.dart';
import 'package:untitled/widgets/bottom_navigation_custom.dart';
import 'package:untitled/widgets/gird_items.dart';

class HomePage2 extends StatelessWidget {
  final UserModel userModel;

  const HomePage2({Key? key, required this.userModel}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Flutter APP DATN',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: Home(userModel: userModel),
    );
  }
}

class Home extends StatefulWidget {
  final UserModel userModel;

  const Home({Key? key, required this.userModel}) : super(key: key);

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  late final PageController pageController;
  final ScrollController _scrollController = ScrollController();
  int pageNo = 0;
  Timer? carouselTimer;

  Timer getTimer() {
    return Timer.periodic(const Duration(seconds: 3), (timer) {
      if (pageController.hasClients) {
        if (pageNo == 4) {
          pageNo = 0;
        }
        pageController.animateToPage(
          pageNo,
          duration: const Duration(seconds: 1),
          curve: Curves.easeInOutCirc,
        );
        pageNo++;
      }
    });
  }

  @override
  void initState() {
    super.initState();
    pageController = PageController(initialPage: 0, viewportFraction: 0.85);
    carouselTimer = getTimer();
    _scrollController.addListener(() {
      if (_scrollController.position.userScrollDirection ==
          ScrollDirection.reverse) {
        setState(() {
          showBottomAppBar = false;
        });
      } else {
        setState(() {
          showBottomAppBar = true;
        });
      }
    });
  }

  @override
  void dispose() {
    pageController.dispose();
    _scrollController.dispose();
    carouselTimer?.cancel();
    super.dispose();
  }

  bool showBottomAppBar = true;

  String _searchText = "";

  @override
  Widget build(BuildContext context) {
    final cartProvider = Provider.of<CartProvider>(context);
    cartProvider.init(widget.userModel.uid);
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          controller: _scrollController,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 36.0),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24.0),
                child: ListTile(
                  onTap: () {},
                  selected: true,
                  shape: const RoundedRectangleBorder(
                    borderRadius: BorderRadius.all(
                      Radius.circular(16.0),
                    ),
                  ),
                  selectedTileColor: Colors.indigoAccent.shade100,
                  title: Text(
                    "Welcome, ${widget.userModel.name}",
                    style: Theme.of(context).textTheme.titleMedium!.merge(
                          const TextStyle(
                            fontWeight: FontWeight.w700,
                            fontSize: 18.0,
                          ),
                        ),
                  ),
                  subtitle: Text(
                    "A Greet welcome to you all.",
                    style: Theme.of(context).textTheme.titleSmall,
                  ),
                  trailing: IconButton(
                    onPressed: () {},
                    icon: const Icon(
                      CupertinoIcons.bell_circle_fill,
                      size: 28.0,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(24.0),
                child: TextField(
                  onChanged: (text) {
                    setState(() {
                      _searchText = text;
                    });
                  },
                  decoration: InputDecoration(
                    hintText: 'Search...',
                    prefixIcon: const Icon(Icons.search),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10.0),
                      borderSide: BorderSide(color: Colors.grey.shade300),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10.0),
                      borderSide: const BorderSide(color: Colors.blue),
                    ),
                  ),
                ),
              ),
              SizedBox(
                height: 200,
                child: PageView.builder(
                  controller: pageController,
                  onPageChanged: (index) {
                    setState(() {
                      pageNo = index;
                    });
                  },
                  itemBuilder: (_, index) {
                    return GestureDetector(
                      onTap: () {
                        CustomSnackBar.show(
                            context, "Hello you tapped at ${index + 1}");
                      },
                      onPanDown: (d) {
                        carouselTimer?.cancel();
                        carouselTimer = null;
                      },
                      onPanCancel: () {
                        carouselTimer = getTimer();
                      },
                      child: Container(
                        margin: const EdgeInsets.symmetric(horizontal: 8.0),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(24.0),
                          color: Colors.amberAccent,
                        ),
                      ),
                    );
                  },
                  itemCount: 5,
                ),
              ),
              const SizedBox(height: 12.0),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(
                  5,
                  (index) => Container(
                    margin: const EdgeInsets.all(2.0),
                    child: Icon(
                      Icons.circle,
                      size: 12.0,
                      color: pageNo == index
                          ? Colors.indigoAccent
                          : Colors.grey.shade300,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 24.0),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Text(
                  'Featured Products',
                  style: Theme.of(context).textTheme.titleLarge!.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
              ),
              const SizedBox(height: 20),
              GridItems(searchQuery: _searchText),
            ],
          ),
        ),
      ),
      floatingActionButtonLocation: showBottomAppBar
          ? FloatingActionButtonLocation.centerDocked
          : FloatingActionButtonLocation.startFloat,
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => CartPage(
                userId: widget.userModel.uid,
              ),
            ),
          );
        },
        mini: true,
        child: const Icon(
          LineAwesomeIcons.shopping_bag,
        ),
      ),
      bottomNavigationBar: BottomNavigationCustom(
        showBottomAppBar: showBottomAppBar,
        onHomePressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const LocationPage(),
            ),
          );
          // Handle home button press
        },
        onProfilePressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => AccountPage(userModel: widget.userModel),
            ),
          );
        },
      ),
    );
  }
}
