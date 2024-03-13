import 'dart:ui';

import 'package:flutter/material.dart';
import 'dart:math' as math;

import 'package:flutter/services.dart';

/*import 'dart:js' as js;*/
void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      debugShowCheckedModeBanner: false,
      scrollBehavior: const MaterialScrollBehavior().copyWith(
        dragDevices: {
          PointerDeviceKind.mouse,
          PointerDeviceKind.touch,
          PointerDeviceKind.stylus,
          PointerDeviceKind.unknown
        },
      ),
      home: const HomePage(),
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List<String> imageList =
      List.generate(5, (index) => 'assets/images/banner0${index + 1}.png');

  final double radius = 36;
  final double itemMaxWidth = 370;
  int selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    return RawKeyboardListener(
      focusNode:
          FocusNode(), // Optional to listen for events even without focus
      onKey: (RawKeyEvent event) {
        if (event is RawKeyDownEvent) {
          if (event.logicalKey == LogicalKeyboardKey.arrowLeft) {
            if (canGoPrev()) {
              prev();
            }
          } else if (event.logicalKey == LogicalKeyboardKey.arrowRight) {
            if (canGoNext()) {
              next();
            }
          }
        }
      },
      child: Scaffold(
        body: Stack(
          fit: StackFit.expand,
          alignment: Alignment.center,
          children: [
            Positioned.fill(
              child: Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Color.fromARGB(255, 190, 225, 233),
                      Color.fromARGB(255, 222, 240, 243),
                    ],
                    begin: Alignment.centerLeft,
                    end: Alignment.centerRight,
                  ),
                ),
              ),
            ),
            Center(
              child: SizedBox(
                height: MediaQuery.of(context).size.height * 0.42,
                child: ListView.separated(
                  shrinkWrap: true,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 32,
                  ),
                  scrollDirection: Axis.horizontal,
                  itemBuilder: (context, index) {
                    double itemWidth = 0;
                    bool isBefore = index == selectedIndex - 1;
                    bool isAfter = index == selectedIndex + 1;

                    if ((isBefore || isAfter) && imageList.length > 3) {
                      itemWidth = 150;
                    } else if (selectedIndex == index) {
                      itemWidth = itemMaxWidth;
                    } else {
                      itemWidth = 100;
                    }

                    return InkWell(
                      onTap: () {
                        setState(() {
                          selectedIndex = index;
                        });
                      },
                      borderRadius: BorderRadius.circular(
                        radius + 3,
                      ),
                      child: AnimatedContainer(
                        width: itemWidth,
                        decoration: BoxDecoration(
                          border: selectedIndex == index
                              ? Border.all(
                                  color: const Color.fromARGB(255, 66, 121, 64),
                                  width: 3,
                                )
                              : null,
                          borderRadius: BorderRadius.circular(
                            radius + 3,
                          ),
                        ),
                        duration: const Duration(milliseconds: 1350),
                        curve: Curves.bounceOut,
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(
                            radius,
                          ),
                          child: Image.asset(
                            imageList[index],
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                    );
                  },
                  separatorBuilder: (context, index) {
                    return const SizedBox(width: 20);
                  },
                  itemCount: imageList.length,
                ),
              ),
            ),
            Positioned(
              bottom: 64,
              child: Builder(builder: (context) {
                return Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    InkWell(
                      onTap: (canGoPrev()) ? prev : null,
                      child: Container(
                        decoration: BoxDecoration(
                          color: (canGoPrev()) ? Colors.blueGrey : Colors.grey,
                          shape: BoxShape.circle,
                          boxShadow: (canGoPrev())
                              ? [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.25),
                                    blurRadius: 5,
                                    offset: const Offset(0, 2),
                                  )
                                ]
                              : [],
                        ),
                        padding: const EdgeInsets.all(8),
                        child: const Icon(
                          Icons.arrow_back,
                          color: Colors.white,
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Text(
                        "${(selectedIndex + 1)} / ${imageList.length}",
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: Colors.blueGrey,
                        ),
                      ),
                    ),
                    Visibility(
                      visible: true,
                      child: InkWell(
                        onTap: canGoNext() ? next : null,
                        child: Container(
                          decoration: BoxDecoration(
                            color: canGoNext() ? Colors.blueGrey : Colors.grey,
                            shape: BoxShape.circle,
                            boxShadow: canGoNext()
                                ? [
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.25),
                                      blurRadius: 5,
                                      offset: const Offset(0, 2),
                                    )
                                  ]
                                : [],
                          ),
                          padding: const EdgeInsets.all(8),
                          child: const Icon(
                            Icons.arrow_forward,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ],
                );
              }),
            ),
          ],
        ),
      ),
    );
  }

  void next() {
    if (canGoNext()) {
      setState(() {
        ++selectedIndex;
      });
    }
  }

  void prev() {
    if (canGoPrev()) {
      setState(() {
        --selectedIndex;
      });
    }
  }

  bool canGoNext() {
    return (selectedIndex < imageList.length - 1);
  }

  bool canGoPrev() {
    return (selectedIndex > 0);
  }
}

class ElasticOutCurve extends Curve {
  const ElasticOutCurve([this.period = 0.4]);

  final double period;

  @override
  double transformInternal(double t) {
    final double s = period / 4.0;
    return math.pow(2.7, -10 * t) *
            math.sin((t - s) * (math.pi * 2.0) / period) +
        1.0;
  }
}
