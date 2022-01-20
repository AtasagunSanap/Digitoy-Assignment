import 'globals.dart';

class Piece {
  String _color = "";
  int _value = -1;
  int _id = -1;
  bool _isOkey = false;
  bool _isJoker = false;

  Piece(int id) {
    this._id = id;
    if (id == 52) {
      _isJoker = true;
      _color = "joker";
    } else {
      this._value = (id % 13) + 1;
      this._color = colorCodes[id ~/ 13];
    }
  }

  void resetJoker() {
    _value = -1;
    _color = "";
  }

  void setAsOkey(bool isOkey) {
    this._isOkey = isOkey;
  }

  int getId() {
    return _id;
  }

  int getValue() {
    return _value;
  }

  void setValue(int value) {
    _value = value;
  }

  String getColor() {
    return _color;
  }

  void setColor(String color) {
    _color = color;
  }

  bool isOkey() {
    return _isOkey;
  }

  void setOkey(bool isOkey) {
    _isOkey = true;
  }

  bool isJoker() {
    return _isJoker;
  }

  @override
  String toString() {
    return _color + " " + _value.toString();
  }
}
