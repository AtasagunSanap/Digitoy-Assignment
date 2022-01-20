import 'dart:math';

import 'piece.dart';

class PieceBag {
  List<Piece> _pieces = [];
  List<Piece> _tempPieces = [];
  List<Piece> _okeys = [];

  PieceBag() {
    for (int i = 0; i < 53; i++) {
      Piece piece = Piece(i);
      Piece piece2 = Piece(i);
      _pieces.add(piece);
      _pieces.add(piece2);
      _tempPieces.add(piece);
      _tempPieces.add(piece2);
    }
  }
  Piece get(int id) {
    for (Piece piece in _pieces) {
      if (piece.getId() == id) return piece;
    }
    return Piece(-2);
  }

  Piece getRandom() {
    Random rng = new Random();
    Piece piece = _tempPieces[rng.nextInt(_tempPieces.length)];
    _tempPieces.remove(piece);
    return piece;
  }

  void setOkey(Piece indicator) {
    for (Piece piece in _pieces) {
      if (piece.getId() == indicator.getId() + 1) {
        _okeys.add(piece);
        piece.setAsOkey(true);
      }
    }

    _pieces[_pieces.length - 1]
        .setValue(indicator.getValue() == 13 ? 1 : indicator.getValue() + 1);
    _pieces[_pieces.length - 1].setColor(indicator.getColor().toUpperCase());
    _pieces[_pieces.length - 2]
        .setValue(indicator.getValue() == 13 ? 1 : indicator.getValue() + 1);
    _pieces[_pieces.length - 2].setColor(indicator.getColor().toUpperCase());
  }
}
