import 'package:ai_voice_orb_example/main.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('Example app boots and renders playground screen',
      (tester) async {
    await tester.pumpWidget(const AiVoiceOrbExampleApp());
    expect(find.text('AI Voice Orb Playground'), findsOneWidget);
    expect(find.text('AI STATE'), findsOneWidget);
    await tester.pump(const Duration(milliseconds: 100));
  });
}
