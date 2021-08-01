class ValidateNickname {
  bool is28Characters;
  bool isNotContainSpace;
  bool isNotContainSpecial;

  ValidateNickname(
      {this.is28Characters = false,
        this.isNotContainSpace = false,
        this.isNotContainSpecial = false});
  bool getIsCorrected() => (is28Characters && isNotContainSpecial && isNotContainSpace);

  ValidateNickname checkPassword(String value) {
    var correctWordParameter = new ValidateNickname();
    final validSpecial = RegExp(r'[!@#$%^&*(),.?":{}|<>]');

    if (value.isEmpty) {
      return ValidateNickname();
    }


    if(value.length <= 8 && value.length >=2) {
      correctWordParameter.is28Characters = true;
    }
    else {
      correctWordParameter.is28Characters = false;
    }

    if (validSpecial.hasMatch(value)) {
      correctWordParameter.isNotContainSpecial = false;
    }
    else {
      correctWordParameter.isNotContainSpecial =true;
    }

    if (value.contains(" ")) {
      correctWordParameter.isNotContainSpace = false;
    }
    else {
      correctWordParameter.isNotContainSpace = true;
    }
    print("글자수:${correctWordParameter.is28Characters}");
    print("공백포함X:${correctWordParameter.isNotContainSpace}");
    print("특수문자포함X:${correctWordParameter.isNotContainSpecial}");
    print(correctWordParameter.getIsCorrected());
    return correctWordParameter;
  }
}



