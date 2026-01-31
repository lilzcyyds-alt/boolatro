import '../boolatro/effects/effects.dart';

class ShopState {
  int money = 0;
  int inventoryLimit = 3;

  final List<SpecialCard> owned = <SpecialCard>[];
  final List<SpecialCard> inventory = <SpecialCard>[];

  void seedDemoInventory() {
    inventory
      ..clear()
      ..addAll(const [
        PartnerCard(),
        AlchemyCard(),
        ExtraHandCard(),
      ]);
  }

  bool canBuy(SpecialCard card) {
    if (owned.length >= inventoryLimit) {
      return false;
    }
    return money >= card.cost;
  }

  bool buy(SpecialCard card) {
    if (!canBuy(card)) {
      return false;
    }
    money -= card.cost;
    owned.add(card);
    inventory.remove(card);
    return true;
  }
}
