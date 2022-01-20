import 'piece.dart';

class Serie {
  List<Piece> _pieces = [];

  void add(Piece piece) {
    _pieces.add(piece);
  }

  void remove(Piece piece) {
    _pieces.remove(piece);
  }

  Piece getByPosition(int pos) {
    return _pieces[pos];
  }

  int length() {
    return _pieces.length;
  }

  bool exists(Piece piece) {
    return (_pieces.where((e) => e.getId() == piece.getId())).length > 0;
  }

  List<Piece> getPieces() {
    return _pieces;
  }

  @override
  String toString() {
    return _pieces.toString();
  }
}
