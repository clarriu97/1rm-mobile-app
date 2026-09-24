import 'package:flutter/rendering.dart';
import 'package:flutter_test/flutter_test.dart';

/// Labels of every node screen readers announce as an image. Decorative
/// icons must not be among them.
List<String> imageLabels(WidgetTester tester) {
  final labels = <String>[];
  void visit(SemanticsNode node) {
    final data = node.getSemanticsData();
    if (data.flagsCollection.isImage) labels.add(data.label);
    node.visitChildren((child) {
      visit(child);
      return true;
    });
  }

  visit(
    tester.binding.renderViews.first.owner!.semanticsOwner!.rootSemanticsNode!,
  );
  return labels;
}
