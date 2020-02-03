import 'dart:typed_data';

class Song {
  String _path;
  String _artist;
  String _title;
  bool _isMenuExpanded = false;

  Song(this._path, this._artist, this._title, [this._isMenuExpanded = false]);

  bool get isMenuExpanded => _isMenuExpanded;

  set isMenuExpanded(bool value) {
    _isMenuExpanded = value;
  }

  String get path => _path;

  set path(String value) {
    _path = value;
  }

  String get artist => _artist;

  String get title => _title;

  set artist(String value) {
    _artist = value;
  }

  set title(String value) {
    _title = value;
  }
}
