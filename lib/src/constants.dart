enum MessageType { pub, sub }
enum WCInteractorState { connected, connecting, paused, disconnected }
//enum Error { badServerResponse, badJSONRPCRequest, sessionInvalid, sessionRequestTimeout, unknown }

List<String> defaultMethods = [
// wc session
  'wc_sessionRequest',
  'wc_sessionUpdate',
// ethereum
  'eth_sign',
  'personal_sign',
  'eth_signTypedData',
  'eth_signTransaction',
  'eth_sendTransaction',
// binance chain
  'bnb_sign',
  'bnb_tx_confirmation',
// other
  'trust_signTransaction',
  'get_accounts',
];
