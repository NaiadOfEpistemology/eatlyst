import 'package:flutter/cupertino.dart';
import '../color_palette.dart';
import 'food_log_screen.dart';
import 'ai_food_screen.dart';
import 'history_screen.dart';
import 'stats_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final List<GlobalKey<NavigatorState>> _navigatorKeys =
  List.generate(4, (_) => GlobalKey<NavigatorState>());

  final List<Widget> _screens = const [
    FoodLogScreen(),
    AiFoodScreen(),
    HistoryScreen(),
    StatsScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return CupertinoTabScaffold(
      tabBar: CupertinoTabBar(
        backgroundColor: CoffeeColors.background,
        activeColor: CoffeeColors.primary,
        items: const [
          BottomNavigationBarItem(
              icon: Icon(CupertinoIcons.doc_text), label: 'Log'),
          BottomNavigationBarItem(
              icon: Icon(CupertinoIcons.camera), label: 'AI'),
          BottomNavigationBarItem(
              icon: Icon(CupertinoIcons.clock), label: 'History'),
          BottomNavigationBarItem(
              icon: Icon(CupertinoIcons.chart_bar), label: 'Stats'),
        ],
      ),
      tabBuilder: (context, index) {
        return CupertinoTabView(
          navigatorKey: _navigatorKeys[index],
          builder: (_) => _screens[index],
        );
      },
    );
  }
}
