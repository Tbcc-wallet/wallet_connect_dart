class Jsonable {
  Map<String, dynamic> toJson() {}
}

enum MessageType { pub, sub }
enum WCInteractorState { connected, connecting, paused, disconnected }
enum Error { badServerResponse, badJSONRPCRequest, sessionInvalid, sessionRequestTimeout, unknown }
enum WCWevent {
  wc_sessionRequest,
  wc_sessionUpdate,
  eth_sign,
  personal_sign,
  eth_signTypedData,
  eth_signTransaction,
  eth_sendTransaction,
  bnb_sign,
  bnb_tx_confirmation,
  trust_signTransaction,
  get_accounts,
}

List<String> defaultMethods = [
  'wc_sessionRequest',
  'wc_sessionUpdate',
  'eth_sign',
  'personal_sign',
  'eth_signTypedData',
  'eth_signTransaction',
  'eth_sendTransaction',
  'bnb_sign',
  'bnb_tx_confirmation',
  'trust_signTransaction',
  'get_accounts',
];
