import 'package:flutter/material.dart';

import 'exposure_detector.dart';

class ExposurePage extends StatelessWidget {
  const ExposurePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('ImpressionPage'),
      ),
      body: ExposureBoundary(
        child: ListView.builder(
          itemBuilder: (context, index) {
            return SizedBox(
              height: 100,
              child: ExposureDetector(
                exposureKey: 'List-$index',
                threshold: const Duration(seconds: 2),
                onImpress: (info) {
                  debugPrint(
                      'info ${(info.key as ValueKey).value}, ${info.size}, ${info.visibleBounds}, ${info.visibleFraction}');
                },
                child: Text('index $index'),
              ),
            );
          },
        ),
      ),
    );
  }
}
