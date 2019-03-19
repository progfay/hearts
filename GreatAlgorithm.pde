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

      // もしプレイ可能な手札が1枚だった場合、それを出す
      List<Card> playableHand = Utils.getPlayableHand(hand, leadSuit, isHeartBroken);
      if (playableHand.size() == 0) return playableHand.get(0);
      
      // hoge
      int canReceive = this.NEVER;
      for (int i = 0; i < 3 - board.size(); i++) {
        int nextPlayer = (myStatus.id + i) % 4;
        int leadSuitCount = 0;
        for (int j = 0; j < 13; j++) {
          if (this.hasCard[nextPlayer][leadSuit][j] != this.NEVER) leadSuitCount++;
        }
        
      }

      this.isFirstTurn = false;
    }

    List<Card> playableHand = Utils.getPlayableHand(hand, leadSuit, isHeartBroken);

    return playableHand.get(0);
  }

  List<Card> choiceExchange(List hand) {
    this.passedCards = hand.subList(0, 3);
    return this.passedCards;
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
