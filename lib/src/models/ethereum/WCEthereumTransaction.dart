class WCEthereumTransaction {
  String? from;
  String? to;
  String? nonce;
  String? gasPrice;
  String? gas;
  String? gasLimit;
  String? value;
  String? data;

  WCEthereumTransaction({
    this.from,
    this.to,
    this.nonce,
    this.gasPrice,
    this.gas,
    this.gasLimit,
    this.value,
    this.data,
  });

  WCEthereumTransaction.fromJson(Map<String, dynamic> json) {
    from = json['from'];
    to = json['to'];
    nonce = json['nonce'];
    gasPrice = json['gasPrice'];
    gas = json['gas'];
    gasLimit = json['gasLimit'];
    value = json['value'];
    data = json['data'];
  }

  Map<String, dynamic> toJson() => <String, dynamic>{
        'from': from,
        'to': to,
        'nonce': nonce,
        'gasPrice': gasPrice,
        'gas': gas,
        'gasLimit': gasLimit,
        'value': value,
        'data': data,
      };
}

class WCEthereumTransactionResult {
  String hash;
  WCEthereumTransactionResult(this.hash);

  String toJson() {
    return hash;
  }
}
