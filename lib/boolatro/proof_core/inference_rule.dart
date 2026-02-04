class InferenceRuleReward {
  const InferenceRuleReward({
    required this.ruleChips,
    required this.ruleMult,
  });

  final int ruleChips;
  final int ruleMult;
}

class InferenceRuleRewards {
  static const Map<String, InferenceRuleReward> table = {
    'reit': InferenceRuleReward(ruleChips: 10, ruleMult: 0),
    '&elim': InferenceRuleReward(ruleChips: 30, ruleMult: 2),
    '&intro': InferenceRuleReward(ruleChips: 20, ruleMult: 1),
    '~elim': InferenceRuleReward(ruleChips: 40, ruleMult: 2),
    '~intro': InferenceRuleReward(ruleChips: 20, ruleMult: 1),
  };

  static InferenceRuleReward getReward(String ruleName) {
    return table[ruleName.toLowerCase()] ?? const InferenceRuleReward(ruleChips: 0, ruleMult: 0);
  }
}
