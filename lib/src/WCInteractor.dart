import 'dart:convert';

import 'package:wallet_connect/src/WCEncryptor.dart';
import 'package:wallet_connect/src/WCSession.dart';
import 'package:wallet_connect/src/constants.dart';
import 'package:wallet_connect/src/models/JSONRPCModels.dart';
import 'package:wallet_connect/src/models/WCPeerMeta.dart';
import 'package:wallet_connect/src/models/WCSessionModels.dart';
import 'package:wallet_connect/src/models/WCSocetMessage.dart';
import 'package:web_socket_channel/io.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

import 'WCEncryptor.dart';
import 'constants.dart';
import 'models/WCSocetMessage.dart';

class WCInteractor {
  WCSession session;
  WCInteractorState state;

  ///optional : uuid
  String clientId;
  WCPeerMeta clientMeta;

  // TODO subinteractors

  //incoming event handlers:
  Function(int id, WCSessionRequestParam peerParam) onSessionRequest;
  Function(Error error) onDisconnect;
  Function(Error error) onError;
  Function(int id, Map<String, dynamic> request) onCustomRequest;

  IOWebSocketChannel socket;
  int handshakeId;

  String peerId;
  WCPeerMeta peerMeta;

  WCInteractor({
    this.session,
    this.clientMeta,
    this.clientId,
  }) {
    state = WCInteractorState.disconnected;
  }

  Future<bool> connect() async {
    if (socket?.sink != null) return true;
    state = WCInteractorState.connecting;
    print(session.bridgeUrl);
    socket = IOWebSocketChannel.connect(session.bridgeUrl);
    socket.stream.listen(
      onReceiveMessage,
      onError: (_) {
        print(_);
        print(socket.closeCode);
        print(socket.closeReason);
      },
    );
    subscribe(session.topic);
    subscribe(clientId);

    socket.sink.add('ping');
    print('>>>> connected');
    state = WCInteractorState.connected;
  }

  void onReceiveMessage(event) {
    var msg;
    print('>>>> received: $event');
    try {
      msg = Map<String, dynamic>.from(json.decode(event));
    } catch (_) {
      msg = event;
    }

    if (msg.runtimeType is String) {
      if (msg == 'text') socket.sink.add('');
      print('<<<< pong');
    } else {
      var topic = msg['topic'];

      var payload = WCEncryptionPayload.fromJson(json.decode(msg['payload']));

      var decrypted = WCEncryptor().decrypt(payload, session.key);
      var json_ = json.decode(decrypted);

      print('>>>> decrypted: $decrypted');
      var method = json_['method'] as String;

      if (defaultMethods.contains(method)) {
        handleEvent(topic, method, json_);
      } else {
        handleCustomRequest(json_);
      }
    }
  }

  void handleEvent(String topic, String event, Map<String, dynamic> decrypted) {
    switch (event) {
      case 'wc_sessionRequest':
        var jsonrpc = JSONRPCRequest.fromJson(decrypted, [WCSessionRequestParam.fromJson(decrypted['params'].first)]);

        handshakeId = jsonrpc.id;
        peerId = jsonrpc.params.first.peerId;
        peerMeta = jsonrpc.params.first.peerMeta;
        if (onSessionRequest != null) onSessionRequest(handshakeId, jsonrpc.params.first);
        break;
      case 'wc_sessionUpdate':
        var params = WCSessionUpdateParam.fromJson(decrypted['params'].first);
        if (params.approved == false) {
          disconnect();
        }
        break;
      default:
    }
  }

  void handleCustomRequest(Map<String, dynamic> decrypted) {}
  void subscribe(String topic) {
    var message = WCSocketMessage(topic: topic, messageType: MessageType.sub, payload: '');

    socket.sink.add(json.encode(message));
    print('>>>> subscribe: ${json.encode(message)}');
  }

  void approveSession(int chainId, List<String> accounts) {
    if (handshakeId <= 0) throw Exception('Invalid session');
    var result = WCApproveSessionResponse(
      approved: true,
      chainId: chainId,
      accounts: accounts,
      peerId: clientId,
      peerMeta: clientMeta,
    );
    var jsonrpc = JSONRPCResponse(id: handshakeId, result: result);

    encryptAndSend(json.encode(jsonrpc));
  }

  void encryptAndSend(String data) {
    print('>>>> encrypt: $data');
    var payload = WCEncryptor().encrypt(data, session.key);
    var payloadString = json.encode(payload);
    var message = WCSocketMessage(messageType: MessageType.pub, payload: payloadString, topic: peerId ?? session.topic);
    var msgstr = json.encode(message);
    print('>>>> msgstr: $msgstr');
    socket.sink.add(msgstr);
  }

  void disconnect() {
    socket.sink.close(1000);
    state = WCInteractorState.disconnected;
    handshakeId = -1;
  }
}
