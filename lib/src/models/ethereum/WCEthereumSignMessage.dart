enum WCSignType { MESSAGE, PERSONAL_MESSAGE, TYPED_MESSAGE }

class WCEthereumSignMessage {
  List<dynamic> raw;
  WCSignType type;

  WCEthereumSignMessage(this.raw, this.type);
}
