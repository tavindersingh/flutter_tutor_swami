import 'dart:async';

import 'package:flutter/material.dart';
import 'package:form_app/auth/presentation/screens/login_screen.dart';

void main() {
  runApp(const BizNetworkTimerApp());
}

class BizNetworkTimerApp extends StatelessWidget {
  const BizNetworkTimerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Biz-Network Timer',
      debugShowCheckedModeBanner: false,
      // theme: ThemeData(
      //   useMaterial3: true,
      //   fontFamily: 'Roboto',
      //   scaffoldBackgroundColor: const Color(0xFFF4F4F4),
      //   colorScheme: ColorScheme.fromSeed(
      //     seedColor: const Color(0xFFD71932),
      //   ),
      // ),
      home: const LoginScreen(),
    );
  }
}

// ------------------------------------------------------------
// TIMER MODEL
// ------------------------------------------------------------

class TimerItem {
  String name;
  Duration duration;
  IconData icon;

  TimerItem({
    required this.name,
    required this.duration,
    required this.icon,
  });
}

// ------------------------------------------------------------
// HOME SCREEN
// ------------------------------------------------------------

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  static const Color red = Color(0xFFD71932);

  int selectedIndex = 0;

  Duration currentDuration = const Duration(minutes: 10);
  Duration remaining = const Duration(minutes: 10);

  Timer? timer;
  bool isRunning = false;

  final List<TimerItem> timers = [
    TimerItem(
      name: 'Weekly Presentation',
      duration: const Duration(seconds: 60),
      icon: Icons.analytics_outlined,
    ),
    TimerItem(
      name: 'Feature Presentation',
      duration: const Duration(minutes: 10),
      icon: Icons.show_chart,
    ),
    TimerItem(
      name: 'Education Moment',
      duration: const Duration(minutes: 5),
      icon: Icons.school_outlined,
    ),
    TimerItem(
      name: 'Open Networking',
      duration: const Duration(minutes: 15),
      icon: Icons.hub_outlined,
    ),
    TimerItem(
      name: 'One-to-One',
      duration: const Duration(minutes: 120),
      icon: Icons.people_outline,
    ),
    TimerItem(
      name: 'Custom Timer',
      duration: const Duration(minutes: 5),
      icon: Icons.tune,
    ),
  ];

  @override
  void dispose() {
    timer?.cancel();
    super.dispose();
  }

  String formatDuration(Duration duration) {
    final hours = duration.inHours;
    final minutes = duration.inMinutes.remainder(60);
    final seconds = duration.inSeconds.remainder(60);

    if (hours > 0) {
      return '${hours.toString().padLeft(2, '0')}:'
          '${minutes.toString().padLeft(2, '0')}:'
          '${seconds.toString().padLeft(2, '0')}';
    }

    return '${minutes.toString().padLeft(2, '0')}:'
        '${seconds.toString().padLeft(2, '0')}';
  }

  String durationLabel(Duration duration) {
    final totalSeconds = duration.inSeconds;

    if (totalSeconds < 60) {
      return '$totalSeconds seconds';
    }

    if (totalSeconds % 3600 == 0) {
      return '${duration.inHours} hours';
    }

    if (totalSeconds % 60 == 0) {
      return '${duration.inMinutes} minutes';
    }

    return formatDuration(duration);
  }

  void selectTimer(TimerItem item) {
    timer?.cancel();

    setState(() {
      currentDuration = item.duration;
      remaining = item.duration;
      isRunning = false;
    });
  }

  void toggleTimer() {
    if (isRunning) {
      pauseTimer();
    } else {
      startTimer();
    }
  }

  void startTimer() {
    if (remaining.inSeconds <= 0) {
      resetTimer();
    }

    timer?.cancel();

    setState(() {
      isRunning = true;
    });

    timer = Timer.periodic(
      const Duration(seconds: 1),
      (timer) {
        if (remaining.inSeconds <= 1) {
          timer.cancel();

          setState(() {
            remaining = Duration.zero;
            isRunning = false;
          });

          return;
        }

        setState(() {
          remaining -= const Duration(seconds: 1);
        });
      },
    );
  }

  void pauseTimer() {
    timer?.cancel();

    setState(() {
      isRunning = false;
    });
  }

  void resetTimer() {
    timer?.cancel();

    setState(() {
      remaining = currentDuration;
      isRunning = false;
    });
  }

  void manualBell() {
    // Sound intentionally not implemented.
    //
    // Later we can add:
    // AudioPlayer()
    //
    // without changing the UI.
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Bell pressed'),
        duration: Duration(milliseconds: 700),
      ),
    );
  }

  Future<Duration?> editTimer(TimerItem item) async {
    final minutesController = TextEditingController(
      text: item.duration.inMinutes.toString(),
    );

    final secondsController = TextEditingController(
      text: (item.duration.inSeconds % 60).toString(),
    );

    return await showDialog<Duration?>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Edit ${item.name}'),
          content: Row(
            children: [
              Expanded(
                child: TextField(
                  controller: minutesController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: 'Minutes',
                    border: OutlineInputBorder(),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: TextField(
                  controller: secondsController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: 'Seconds',
                    border: OutlineInputBorder(),
                  ),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text('Cancel'),
            ),
            FilledButton(
              style: FilledButton.styleFrom(
                backgroundColor: red,
              ),
              onPressed: () {
                final minutes = int.tryParse(minutesController.text) ?? 0;

                final seconds = int.tryParse(secondsController.text) ?? 0;

                final newDuration = Duration(
                  minutes: minutes,
                  seconds: seconds,
                );

                if (newDuration.inSeconds <= 0) {
                  return;
                }

                // setState(() {
                //   item.duration = newDuration;

                //   currentDuration = newDuration;
                //   remaining = newDuration;
                //   isRunning = false;
                // });

                Navigator.pop(context, newDuration);
              },
              child: const Text('Save'),
            ),
          ],
        );
      },
    );

    // minutesController.dispose();
    // secondsController.dispose();
  }

  void openHelp() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => const HelpScreen(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (selectedIndex == 1) {
      return const HelpScreen();
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF3F3F3),

      body: SafeArea(
        child: Column(
          children: [
            // --------------------------------------------------
            // RED TIMER HEADER
            // --------------------------------------------------
            _buildTimerHeader(),

            // --------------------------------------------------
            // TIMER LIST
            // --------------------------------------------------
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.fromLTRB(
                  14,
                  28,
                  14,
                  100,
                ),
                itemCount: timers.length,
                itemBuilder: (context, index) {
                  final item = timers[index];

                  return _buildTimerCard(item);
                },
              ),
            ),
          ],
        ),
      ),

      // ------------------------------------------------------
      // BOTTOM NAVIGATION
      // ------------------------------------------------------
      bottomNavigationBar: _buildBottomNavigation(),
    );
  }

  Widget _buildTimerHeader() {
    return Stack(
      children: [
        Container(
          width: double.infinity,
          color: red,
          padding: const EdgeInsets.only(
            top: 8,
            bottom: 25,
          ),
          margin: const EdgeInsets.only(bottom: 30),
          child: Column(
            children: [
              const SizedBox(height: 12),

              // Timer
              FittedBox(
                fit: BoxFit.scaleDown,
                child: Text(
                  formatDuration(remaining),
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 88,
                    fontWeight: FontWeight.w400,
                    letterSpacing: 2,
                  ),
                ),
              ),

              const SizedBox(height: 18),

              // Controls
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  IconButton(
                    onPressed: resetTimer,
                    icon: const Icon(
                      Icons.history,
                      color: Colors.white,
                      size: 46,
                    ),
                    tooltip: 'Reset',
                  ),

                  const SizedBox(width: 35),

                  IconButton(
                    onPressed: toggleTimer,
                    icon: Icon(
                      isRunning ? Icons.pause : Icons.play_arrow,
                      color: Colors.white,
                      size: 58,
                    ),
                    tooltip: isRunning ? 'Pause' : 'Start',
                  ),
                ],
              ),
            ],
          ),
        ),
        // --------------------------------------------------
        // FLOATING BELL
        // --------------------------------------------------
        Positioned(
          right: 14,
          bottom: 0,
          child: Material(
            color: Colors.white,
            elevation: 7,
            shadowColor: Colors.black26,
            shape: const CircleBorder(),
            child: InkWell(
              customBorder: const CircleBorder(),
              onTap: manualBell,
              child: const SizedBox(
                width: 72,
                height: 72,
                child: Icon(
                  Icons.notifications,
                  color: red,
                  size: 38,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTimerCard(TimerItem item) {
    final isSelected =
        currentDuration == item.duration && remaining == item.duration;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),

      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(1),
        boxShadow: const [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 2,
            offset: Offset(0, 1),
          ),
        ],
      ),

      child: InkWell(
        onTap: () {
          selectTimer(item);
        },

        child: SizedBox(
          height: 126,

          child: Row(
            children: [
              // ------------------------------------------------
              // RED SIDE LINE
              // ------------------------------------------------
              Container(
                width: 5,
                margin: const EdgeInsets.symmetric(
                  vertical: 14,
                ),
                decoration: const BoxDecoration(
                  color: red,
                ),
              ),

              const SizedBox(width: 16),

              // ------------------------------------------------
              // ICON
              // ------------------------------------------------
              SizedBox(
                width: 78,
                child: Icon(
                  item.icon,
                  color: red,
                  size: 58,
                ),
              ),

              const SizedBox(width: 18),

              // ------------------------------------------------
              // TITLE + DURATION
              // ------------------------------------------------
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 19,
                        fontWeight: isSelected
                            ? FontWeight.w600
                            : FontWeight.w400,
                        color: Colors.black,
                      ),
                    ),

                    const SizedBox(height: 12),

                    Text(
                      durationLabel(item.duration),
                      style: const TextStyle(
                        fontSize: 17,
                        color: Colors.black,
                      ),
                    ),
                  ],
                ),
              ),

              // ------------------------------------------------
              // EDIT
              // ------------------------------------------------
              IconButton(
                onPressed: () async {
                  final newDuration = await editTimer(item);

                  if (newDuration != null) {
                    setState(() {
                      item.duration = newDuration;

                      currentDuration = newDuration;
                      remaining = newDuration;
                      isRunning = false;
                    });
                  }
                },
                icon: const Icon(
                  Icons.edit,
                  color: Colors.black,
                  size: 27,
                ),
              ),

              const SizedBox(width: 12),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBottomNavigation() {
    return Container(
      height: 74,
      decoration: const BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 5,
            offset: Offset(0, -2),
          ),
        ],
      ),

      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,

        children: [
          // HOME
          IconButton(
            onPressed: () {
              setState(() {
                selectedIndex = 0;
              });
            },
            icon: Icon(
              Icons.home,
              size: 35,
              color: selectedIndex == 0 ? red : Colors.grey,
            ),
          ),

          // HELP
          IconButton(
            onPressed: openHelp,
            icon: Icon(
              Icons.help_outline,
              size: 35,
              color: selectedIndex == 1 ? red : Colors.grey,
            ),
          ),
        ],
      ),
    );
  }
}

// ------------------------------------------------------------
// HELP SCREEN
// ------------------------------------------------------------

class HelpScreen extends StatelessWidget {
  const HelpScreen({super.key});

  static const Color red = Color(0xFFD71932);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,

      body: SafeArea(
        child: Column(
          children: [
            Container(
              height: 5,
              color: red,
            ),

            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(
                  32,
                  45,
                  32,
                  40,
                ),

                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,

                  children: [
                    // ------------------------------------------
                    // LOGO PLACEHOLDER
                    // ------------------------------------------
                    Center(
                      child: Container(
                        width: 150,
                        height: 90,
                        alignment: Alignment.center,

                        child: const Text(
                          'BIZ',
                          style: TextStyle(
                            color: red,
                            fontSize: 55,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 45),

                    const Text(
                      'Biz-Network Timer',
                      style: TextStyle(
                        fontSize: 26,
                        fontWeight: FontWeight.w400,
                      ),
                    ),

                    const SizedBox(height: 42),

                    const Text(
                      'Biz-Network Timer is a simple meeting '
                      'management tool designed to keep '
                      'networking activities on time.',
                      style: TextStyle(
                        fontSize: 18,
                        height: 1.6,
                      ),
                    ),

                    const SizedBox(height: 30),

                    GestureDetector(
                      onTap: () {},
                      child: const Text(
                        'SUPPORT AND FEEDBACK',
                        style: TextStyle(
                          color: red,
                          fontSize: 17,
                          decoration: TextDecoration.underline,
                          decorationColor: red,
                        ),
                      ),
                    ),

                    const SizedBox(height: 70),

                    _buildButton(
                      'About Us',
                    ),

                    const SizedBox(height: 18),

                    _buildButton(
                      'About Biz-Network',
                    ),

                    const SizedBox(height: 18),

                    _buildButton(
                      'Visit Next Meeting?',
                    ),

                    const SizedBox(height: 18),

                    _buildButton(
                      'Privacy Policy',
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),

      bottomNavigationBar: Container(
        height: 74,
        decoration: const BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black12,
              blurRadius: 5,
              offset: Offset(0, -2),
            ),
          ],
        ),

        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,

          children: [
            IconButton(
              onPressed: () {
                Navigator.pop(context);
              },
              icon: const Icon(
                Icons.home,
                size: 35,
                color: Colors.grey,
              ),
            ),

            const Icon(
              Icons.help_outline,
              size: 35,
              color: red,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildButton(String text) {
    return SizedBox(
      width: double.infinity,
      height: 72,

      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: red,
          foregroundColor: Colors.white,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),

        onPressed: () {},

        child: Text(
          text,
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}
