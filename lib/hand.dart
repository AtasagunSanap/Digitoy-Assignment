import 'piece.dart';
import 'serie.dart';

class Hand {
  late final List<Piece> _pieces; // contains all pieces of the hand
  List<Serie> _series = []; // series are 3 pieces together that compose a serie
  List<Serie> _pairs =
      []; // pairs have two pieces that are close to being a completed serie
  List<Piece> _unallocated =
      []; // contains the pieces that do not fit into a serie or pair
  List<Piece> _okeys = []; // contains okeys
  int _remaining = 0; // acts as a score, lower is better
  String _state = ""; //shows if the hand is ordered by pairs or series

  // constructor
  Hand(List<Piece> pieces) {
    this._pieces = pieces;
    for (Piece piece in _pieces) {
      if (piece.isOkey())
        _okeys.add(piece);
      else
        _unallocated.add(piece); //
    }
    // we first sort the pieces by number and then color
    _numberSort();

    // then we split the pieces into series and pairs and decide for the best ordering style (by duplicates or by series)
    _typeSort();
  }

  void _numberSort() {
    // sorting by number and then color
    _unallocated.sort((a, b) => a.getId().compareTo(b.getId()));
    _unallocated.sort((a, b) => a.getValue().compareTo(b.getValue()));
  }

  void _typeSort() {
    // sort by duplicates and series
    // see which gives a best outcome
    // decide to go for either duplicate or series
    int duplicateRem = duplicateSort();
    int seriesRem = seriesSort();

    _remaining = duplicateRem < seriesRem ? duplicateRem : seriesRem;

    if (duplicateRem < seriesRem) {
      _remaining = duplicateRem;
      _state = "By Duplicates";
      duplicateSort();
    } else {
      _remaining = seriesRem;
      _state = "By Series";
      seriesSort();
    }
  }

  String getState() {
    return _state;
  }

  int getRemaining() {
    return _remaining;
  }

  int getUnallocated() {
    return _remaining;
  }

  int duplicateSort() {
    // we restore the pieces to the initial state and sort them
    _restorePieces();
    _numberSort();
    int pos = 1;
    int _remaining = 0;
    // checking for same pairs
    while (pos < _unallocated.length) {
      if (_unallocated[pos - 1].getId() == _unallocated[pos].getId()) {
        Serie serie = Serie();
        serie.add(_unallocated[pos - 1]);
        serie.add(_unallocated[pos]);
        _unallocated.removeAt(pos);
        _unallocated.removeAt(pos - 1);
        _series.add(serie);
      } else {
        pos = pos + 1;
      }
    }
    // when all splitting is done, add okeys to the game
    for (Piece okey in _okeys) {
      if (_unallocated.isNotEmpty) {
        Serie serie = Serie();
        serie.add(okey);
        serie.add(_unallocated.first);
        _unallocated.removeAt(0);
        _series.add(serie);
      }
    }

    // _remaining holds the score, lower is better.
    // it is the score of the number of remaining pieces
    // if there are 15 pieces, one of them will be thrown, so its not accounted
    _remaining =
        _pieces.length == 15 ? _unallocated.length - 1 : _unallocated.length;

    return _remaining;
  }

  int seriesSort() {
    // we restore the pieces to the initial state and sort them
    _restorePieces();
    _numberSort();

    int position = 0;
    Piece mainPiece, sidePiece = Piece(-2);

    // splitting into series is a little complex
    // we check for successive series and pair series (like blue 1, black 1, red 1)
    // for each piece and try to get the best combination

    // for each piece, we do the checking of all the other pieces and try to get a serie
    while (position < _unallocated.length) {
      Serie serieSuc = Serie();
      Serie seriePeer = Serie();
      Serie pairSuc = Serie();
      Serie pairPeer = Serie();
      Serie finalSerie = Serie();

      // check for successive
      int index = position;
      mainPiece = _unallocated[position];
      pairSuc.add(mainPiece);
      while (index < _unallocated.length) {
        sidePiece = _unallocated[index];
        // if we find two successive peaces, the second is also added to the serie
        // and mainpiece becomes the second for comparison in the next step
        if (_isSuccessive(mainPiece, sidePiece)) {
          pairSuc.add(sidePiece);
          mainPiece = sidePiece;
        }
        index++;
      }

      // checking for pairs or series of "12-13-1" or "13-1"
      // this part seems to be working, but might not work as intended all the time, I hope it works.
      index = 0;
      bool cont = true;
      for (Piece piece in _unallocated) {
        if (cont && _isSuccessive(mainPiece, piece)) {
          pairSuc.add(piece);
          cont = false;
        }
      }

      // checking for previously created pairs to see
      // if it contains 1 to add to 12-13
      // I basically go throgh each pair and see if mainpiece is successive to any element in those pairs
      // which in this case I am looking for 13-1
      // if so, I merge them to form a serie of 12-13-1
      Piece foundPiece = Piece(-2);
      bool found = false;

      List<Piece> tempUnallocated = [];
      if (pairSuc.getPieces().last == mainPiece && pairSuc.length() > 1) {
        Serie removal = Serie();
        for (int i = 0; (i < _pairs.length); i++) {
          Serie tempPair = _pairs[i];
          List<Piece> tempPieces = _pairs[i].getPieces();
          Piece tempPiece = tempPieces.first;

          if (_isSuccessive(mainPiece, tempPieces.first)) {
            tempPiece = tempPieces.first;
            found = true;
          } else if (_isSuccessive(mainPiece, tempPieces.last)) {
            tempPiece = tempPieces.last;
            found = true;
          }

          if (found) {
            found = false;
            foundPiece = tempPiece;
            removal = tempPair;
          }
        }
        if (foundPiece.getId() != -2) {
          pairSuc.add(foundPiece);

          if (removal.getByPosition(0) == foundPiece) {
            _unallocated.add(removal.getByPosition(1));
          } else {
            _unallocated.add(removal.getByPosition(0));
          }
          List<Serie> tempPairs = [];
          for (Serie tempPair in _pairs) {
            if (tempPair != removal) tempPairs.add(tempPair);
          }
          _pairs = tempPairs;
        }
      }

      for (Piece piece in tempUnallocated) {
        _unallocated.add(piece);
      }

      // if we found a serie, we add it to series of successive pieces
      if (pairSuc.length() > 2) {
        for (int i = 0; i < pairSuc.length(); i++) {
          serieSuc.add(pairSuc.getByPosition(i));
        }
        pairSuc = Serie();
      }

      // check for peer
      // we follow a similar path
      index = position;
      mainPiece = _unallocated[position];
      pairPeer.add(mainPiece);
      while (index < _unallocated.length) {
        sidePiece = _unallocated[index];
        if (_isPeer(mainPiece, sidePiece)) {
          pairPeer.add(sidePiece);
          mainPiece = sidePiece;
        }
        index++;
      }

      if (pairPeer.length() > 2) {
        for (int i = 0; i < pairPeer.length(); i++) {
          seriePeer.add(pairPeer.getByPosition(i));
        }
        pairPeer = Serie();
      }

      // now here happens the final decision of serie forming
      // if we have a full serie at the end, we add it to series
      // if not, we add the pair to pairs
      if (serieSuc.length() > 0) {
        finalSerie =
            serieSuc.length() > seriePeer.length() ? serieSuc : seriePeer;
      } else if (seriePeer.length() > 0) {
        finalSerie = seriePeer;
      } else if (pairSuc.length() == 2) {
        finalSerie = pairSuc;
      } else if (pairPeer.length() == 2) {
        finalSerie = pairPeer;
      } else {
        // if no pair or serie formed, go to next piece
        position++;
      }

      // we eventually remove the pieces that we added to finalSerie, from _unallocated
      if (finalSerie.length() > 0) {
        for (int i = 0; i < finalSerie.length(); i++)
          _unallocated.remove(finalSerie.getByPosition(i));

        if (finalSerie.length() > 2)
          _series.add(finalSerie);
        else
          _pairs.add(finalSerie);
      }
    }

    // lastly we add okeys to our pairs so that we form one last serie, or extend one
    // this has one or two minor flows such as
    // it does not try to form a serie of 1-2-3-okey-5
    if (_pieces.length != 15 || _pairs.length > 1) {
      if (_pairs.length > 0) {
        for (Piece okey in _okeys) {
          _pairs.first.add(okey);
          _series.add(_pairs.first);
          List<Serie> tempPairs = [];
          for (int i = 1; i < _pairs.length; i++) {
            tempPairs.add(_pairs[i]);
          }
          _pairs = tempPairs;
        }
      }
    } else {
      for (Piece okey in _okeys) {
        _series.first.add(okey);
      }
    }

    // one of the pieces will be thrown if there are 15 pieces
    return _pieces.length == 15
        ? _unallocated.length + _pairs.length - 1
        : _unallocated.length + _pairs.length;
  }

  void _restorePieces() {
    _unallocated = [];
    _series = [];
    _pairs = [];
    _okeys = [];
    for (Piece piece in _pieces) {
      if (piece.isOkey())
        _okeys.add(piece);
      else
        _unallocated.add(piece);
    }
  }

  bool _isSuccessive(Piece first, Piece second) {
    return (first.getColor().toLowerCase() == second.getColor().toLowerCase() &&
            first.getValue() == 13 &&
            second.getValue() == 1) ||
        (first.getColor().toLowerCase() == second.getColor().toLowerCase() &&
            first.getValue() == second.getValue() - 1);
  }

  bool _isPeer(Piece first, Piece second) {
    return (first.getColor().toLowerCase() != second.getColor().toLowerCase() &&
        first.getValue() == second.getValue());
  }

  @override
  String toString() {
    return "\n\n" +
        _series.toString() +
        " || " +
        _pairs.toString() +
        " || " +
        _unallocated.toString() +
        " || State: " +
        _state +
        " || Remaining is: " +
        _remaining.toString();
  }
}
