enum WCSignType { MESSAGE, PERSONAL_MESSAGE, TYPED_MESSAGE }

class WCEthereumSignMessage {
  List<String> raw;
  WCSignType type;

  WCEthereumSignMessage(this.raw, this.type);
}
