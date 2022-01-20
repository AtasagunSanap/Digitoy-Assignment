import 'lib/hand.dart';
import 'lib/piece.dart';
import 'lib/pieceBag.dart';

void main() {
  List<Hand> hands = [];
  PieceBag bag = PieceBag();
  Piece indicator = bag.getRandom();
  // we first get an indicator
  while (indicator.getId() > 50) {
    bag = PieceBag();
    indicator = bag.getRandom();
  }
  print("indicator is : " + bag.get(indicator.getId()).toString());

  print("okey is : " + bag.get(indicator.getId() + 1).toString());
  bag.setOkey(indicator);
/*
  hands.add(Hand([
    Piece(0),
    Piece(25),
    Piece(12),
    Piece(11),
    Piece(12),
    Piece(11),
    Piece(13),
    Piece(26),
    Piece(0),
    Piece(1)
  ]));

  print(hands);*/

  // then distribute pieces to hands and hand constructors do the arrangements in each of them
  for (int k = 0; k < 4; k++) {
    List<Piece> pieces = [];
    for (var i = 0; i < 14; i++) {
      pieces.add(bag.getRandom());
    }
    if (k == 3) pieces.add(bag.getRandom());
    hands.add(Hand(pieces));
  }

  // we get the best hand and display it, based on the scores that we get from hands and their comparisons with each other
  Hand minHand = hands.first;
  List<Hand> minHands = [];
  for (Hand hand in hands) {
    if (hand.getRemaining() < minHand.getRemaining()) {
      minHand = hand;
    }
  }

  for (Hand hand in hands) {
    if (hand.getRemaining() == minHand.getRemaining()) {
      minHands.add(hand);
    }
  }

  print(hands);
  print("\n--------------------------------");
  print("--------------------------------");

  for (Hand hand in minHands) {
    print("The best hand to win is : " + hand.toString());

    print("\n\n");
  }
}
