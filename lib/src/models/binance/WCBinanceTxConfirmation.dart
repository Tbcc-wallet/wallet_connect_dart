class WCBinanceTxConfirmation {
  bool? ok;
  String? errorMessage;

  WCBinanceTxConfirmation.fromJson(Map<String, dynamic> json) {
    ok = json['ok'];
    errorMessage = json['error'];
  }

  Map<String, dynamic> toJson() => <String, dynamic>{
        'ok': ok,
        'error': errorMessage,
      };
}
