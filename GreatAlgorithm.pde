class GreatAlgorithm extends Algorithm {

  final int ABSOLUTELY = 1;
  final int UNKNOWN = 0;
  final int NEVER = -1;

  int [][][] hasCard = new int [4][4][13];

  boolean isFirstTurn = true;
  List<Card> passedCards = new ArrayList<Card>();

  GreatAlgorithm () {
    for (int i = 0; i < 4; i++) {
      for (int j = 0; j < 4; j++) {
        for (int k = 0; k < 13; k++) {
          this.hasCard[i][j][k] = UNKNOWN;
        }
      }
    }
  }

  Card choiceCard(
    List<Card> board, 
    List<Card> hand, 
    Player.Status myStatus, 
    List<Player.Status> otherPlayerStatus, 
    Integer leadSuit, 
    boolean isHeartBroken) {
    // Card Counting
    if (this.isFirstTurn) {
      int passedPlayer = (myStatus.id + 1) % 4;
      for (Card card : this.passedCards) {
        for (int i = 0; i < 4; i++) {
          this.hasCard[i][card.suit][card.strength - 2] = i == passedPlayer ? this.ABSOLUTELY : this.NEVER;
        }
      }
      int firstPlayer = (myStatus.id - board.size() + 4) % 4;
      for (int i = 0; i < 4; i++) {
        this.hasCard[i][Card.CLUBS][2] = i == firstPlayer ? this.ABSOLUTELY : this.NEVER;
      }
      for (int i = 0; i < 4; i++) {
        for (int j = 0; j < 13; j++) {
          this.hasCard[myStatus.id][i][j] = this.NEVER;
        }
      }
      for (Card card : hand) {
        for (int i = 0; i < 3; i++) {
          this.hasCard[i][card.suit][card.strength - 2] = i == myStatus.id ? this.ABSOLUTELY : this.NEVER;
        }
      }

      for (int i = 0; i < board.size(); i++) {
        int submitter = (myStatus.id - board.size() + i + 4) % 4;
        Card card = board.get(i);
        for (int j = 0; j < 4; this.hasCard[j++][card.suit][card.strength - 2] = this.NEVER);
        if (card.suit != leadSuit) {
          for (int j = 0; j < 4; j++) {
            for (int k = 0; k < 13; k++) {
              this.hasCard[submitter][j][k] = this.NEVER;
            }
          }
        }
      }

      this.isFirstTurn = false;
    }

    // もしプレイ可能な手札が1枚だった場合、それを出す
    List<Card> playableHand = Utils.getPlayableHand(hand, leadSuit, isHeartBroken);
    if (playableHand.size() == 0) return playableHand.get(0);



    if (leadSuit == null) {
      // あぶり出し
      if (findCardFromCardsList(Card.SPADES, 13, playableHand)==null && findCardFromCardsList(Card.SPADES, 14, playableHand)==null) {
        for (int i = 11; i > 1; i--) {
          Card card = findCardFromCardsList(Card.SPADES, i, playableHand);
          if (card!=null) {
            return card;
          }
        }
      }

      // 初手で何を出すか
      Card[] weakestHand = new Card [4];
      for (Card card : playableHand) {
        weakestHand[card.suit] = weakestHand[card.suit] == null ? card
          : weakestHand[card.suit].strength < card.strength ? weakestHand[card.suit] : card;
      }
      boolean [] losable = new boolean [4];
      for (int suit = 0; suit < 4; suit++) {
        if (weakestHand[suit] == null || weakestHand[suit].number < 5) {
          losable[suit] = true;
          continue;
        }
        boolean [] lose = { true, true, true, true };
        for (int i = 0; i < 4; i++) {
          for (int j = 0; j < 13; j++) {
            if (this.hasCard[i][suit][j] == this.NEVER) continue;
            lose[i] = false;
            break;
          }
        }
        for (int i = 0; i < 4; i++) {
          for (int j = 0; j < weakestHand[suit].strength - 3; j++) {
            if (this.hasCard[i][suit][j] == this.NEVER) continue;
            lose[i] = true;
            break;
          }
        }
        for (int i = 0; i < 4; i++) {
          if (i == myStatus.id) continue;
          if (!lose[i]) losable[suit] = true;
        }
      }
      // losable[suit]がtrueなら、そのsuitで絶対負けられる

      // losable[suit]がtrueで枚数が最も少ないsuitを選ぶ
      int [] suitArray = suitNumFromList(playableHand);
      int minSuit = -1;
      for (int i = 0; i < 4; i++) {
        if (losable[i]) {
          if (minSuit == -1) {
            if ( suitArray[i] != 0) {
              minSuit = i;
              continue;
            }
          } else {
            if (suitArray[i] < suitArray[minSuit] && suitArray[i] != 0) {
              minSuit = i;
            }
          }
        }
      }
      if (minSuit != -1) {
        return weakestHand[minSuit];
      }

      return playableHand.get(0);
    }

    //  場のスートを持っているか
    boolean hasLeadSuit = false;
    for (Card card : playableHand) {
      if (card.suit == leadSuit) {
        hasLeadSuit = true;
        break;
      }
    }

    if (hasLeadSuit) { // 場のスートを持っている場合
      int maxStrength = 0;
      for (Card card : board) {
        if (card.suit == leadSuit && card.strength > maxStrength) {
          maxStrength = card.strength;
        }
      }
      Card returnCard = playableHand.get(0);
      for (Card card : playableHand) {
        if (maxStrength > card.strength && returnCard.strength < card.strength) {
          returnCard = card;
        }
      }
      return returnCard;
    } else {  // 場のスートを持っていない場合
      Card submit = null;
      int [] suitCount = suitNumFromList(playableHand);
      for (Card card : playableHand) {
        if (card.suit == Card.SPADES && card.number == 12) return card;
        submit = submit == null ? card
          : submit.strength > card.strength ? submit
          : submit.strength < card.strength ? card
          : suitCount[submit.suit] > suitCount[card.suit] ? submit
          : suitCount[submit.suit] < suitCount[card.suit] ? card
          : submit.suit < card.suit ? submit : card;
      }
      return submit;
    }
  }

  List<Card> choiceExchange(List hand) {
    this.passedCards = hand.subList(0, 3);
    return this.passedCards;
  }

  int [] suitNumFromList(List<Card> cards) {
    int [] suitArray = {0, 0, 0, 0};
    for (Card card : cards) suitArray[card.suit]++;
    return suitArray;
  }

  int countSuit(int suit, List<Card> cards) {
    int count = 0;
    for (Card card : cards) if (card.suit==suit)count++;
    return count;
  }

  Card findCardFromCardsList(int suit, int strength, List<Card> cards ) {
    for (Card card : cards)
      if (card.suit==suit && card.strength==strength)
        return card;
    return null;
  }

  //int canReceive (List<Card> board, Card card, int leadSuit) {
  //  if (card.suit != leadSuit) return this.NEVER;

  //  for (Card submitted : board) {
  //    if (submitted.suit != leadSuit) continue;
  //    if (submitted.strength > card.strength) return this.NEVER;
  //  }

  //  return 1;
  //}
}
