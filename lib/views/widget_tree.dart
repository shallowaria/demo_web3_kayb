import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:web3_demo/data/constants.dart';
import 'package:web3_demo/data/notifiers.dart';
import 'package:web3_demo/views/pages/support_chain_page.dart';
import 'package:web3_demo/views/pages/transition_history_page.dart';
import 'package:web3_demo/widgets/navbar_widget.dart';

List<Widget> pages = [SupportChainPage(), TransitionHistoryPage()];

class WidgetTree extends StatelessWidget {
  const WidgetTree({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Web3 Demo'),
          centerTitle: true,
          actions: [
            IconButton(
              onPressed: () async {
                isDarkModeNotifier.value = !isDarkModeNotifier.value;
                // 保存数据
                final SharedPreferences prefs =
                    await SharedPreferences.getInstance();
                await prefs.setBool(
                  KConstants.themeModeKey,
                  isDarkModeNotifier.value,
                );
              },
              icon: ValueListenableBuilder(
                valueListenable: isDarkModeNotifier,
                builder: (context, isDarkMode, child) {
                  return Icon(isDarkMode ? Icons.light_mode : Icons.dark_mode);
                },
              ),
            ),
          ],
        ),
        body: ValueListenableBuilder(
          valueListenable: selectedPageNotifier,
          builder: (context, selectedValue, child) {
            return pages.elementAt(selectedValue);
          },
        ),
        bottomNavigationBar: const NavbarWidget(),
      ),
    );
  }
}
