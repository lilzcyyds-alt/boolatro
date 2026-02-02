import 'package:flutter_test/flutter_test.dart';
import 'package:boolatro/state/run_state.dart';
import 'package:boolatro/game/game_config.dart';
import 'package:boolatro/state/proof_state.dart';
import 'package:boolatro/boolatro/proof_core/play_card.dart';

void main() {
  setUpAll(() {
    // Basic initialization for tests
    GameConfig.allowedAtoms = ['P', 'Q', 'R', 'S', 'T'];
    GameConfig.initialHands = 3;
    GameConfig.initialDiscards = 3;
    GameConfig.maxHandSize = 6;
  });

  group('RunState Submission', () {
    test('only allows one submission per editor session', () async {
      final runState = RunState();
      
      // Setup a valid scenario for opening editor
      runState.proofState.premise = 'P';
      final card1 = PlayCard(id: 1, content: 'P', type: CardType.atom);
      runState.proofState.hand.add(card1);
      runState.addConclusionCard(card1);
      
      expect(runState.proofState.handsRemaining, 3);
      
      // Open editor (costs 1 hand)
      runState.openProofEditor();
      expect(runState.proofState.editorOpen, isTrue);
      expect(runState.proofState.handsRemaining, 2);
      expect(runState.proofState.sessionSubmitted, isFalse);

      // First submission
      runState.submitProof();
      expect(runState.proofState.sessionSubmitted, isTrue);
      expect(runState.proofState.editorOpen, isFalse); 

      // Try second submission (should be blocked by sessionSubmitted flag)
      final result2 = runState.submitProof();
      expect(result2.isValid, isFalse);
      expect(result2.message, 'Already submitted');
      
      // Ensure it can be reset by opening the editor again
      final card2 = PlayCard(id: 2, content: 'P', type: CardType.atom);
      runState.proofState.hand.add(card2);
      runState.addConclusionCard(card2);
      runState.openProofEditor(); 
      expect(runState.proofState.handsRemaining, 1);
      expect(runState.proofState.sessionSubmitted, isFalse);
    });
  });
}
