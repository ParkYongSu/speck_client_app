import 'package:flutter/cupertino.dart';
import 'package:naver_map_plugin/naver_map_plugin.dart';

class SearchingWordState extends ChangeNotifier{
  String _searchingWord = "스펙존 지도";

  void setSearchingWord(String word) {
    this._searchingWord = word;
    notifyListeners();
  }

  String getSearchingWord() {
    return this._searchingWord;
  }
}