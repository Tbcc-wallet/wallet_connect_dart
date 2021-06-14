import 'dart:convert';
import 'dart:developer';
import 'package:web_socket_channel/io.dart';

import 'WCEncryptor.dart';
import 'WCSession.dart';
import 'constants.dart';

import 'models/JSONRPCModels.dart';

import 'models/internal/WCPeerMeta.dart';
import 'models/internal/WCSession.dart';
import 'models/internal/WCSocketMessage.dart';

import 'models/ethereum/WCEthereumSignMessage.dart';
import 'models/ethereum/WCEthereumTransaction.dart';

import 'models/binance/WCBinanceSign.dart';
import 'models/binance/WCBinanceTxConfirmation.dart';

class WCInteractor {
  bool debugLog;

  bool? autoreconnect;

  WCSession? session;
  WCInteractorState? state;

  bool? disconnectedManually;

  ///optional : uuid
  String? clientId;
  WCPeerMeta? clientMeta;

  // TODO subinteractors

  //incoming event handlers:
  Function(int? id, WCSessionRequestParam peerParam)? onSessionRequest;
  Function(int? closeCode, String? closeReason)? onDisconnect;
  Function(dynamic error)? onError;
  Function(int id, Map<String, dynamic> request)? onCustomRequest;

  // eth requests handlers:
  Function(int? id, WCEthereumSignMessage)? onEthSign;
  Function(int? id, WCEthereumTransaction)? onEthSignTransaction;
  Function(int? id, WCEthereumTransaction)? onEthSendTransaction;

  // bnb requests handlers:
  Function(int? id, WCBinanceSign)? onBnbSign;
  Function(int id, WCBinanceSign)? onBnbTxConfirmation;

  IOWebSocketChannel? socket;
  int? handshakeId;

  String? peerId;
  WCPeerMeta? peerMeta;

  WCInteractor({
    this.session,
    this.clientMeta,
    this.clientId,
    this.debugLog = false,
  }) {
    state = WCInteractorState.disconnected;
  }

  void wcEventsLog(String? msg, [bool incoming = true]) {
    if (debugLog) log('${incoming ? '>>>>>' : '<<<<<'} : $msg');
  }

  bool connect() {
    if (socket?.sink != null) return true;
    state = WCInteractorState.connecting;
    wcEventsLog(session!.bridgeUrl);
    wcEventsLog('connecting....');

    socket = IOWebSocketChannel.connect(session!.bridgeUrl!);
    disconnectedManually = false;
    socket!.stream.listen(onReceiveMessage, onError: (err) {
      wcEventsLog(
        '<Socket Error>:\n'
        '  close code: ${socket!.closeCode}\n'
        '  close code: ${socket!.closeReason}\n'
        '  error msg: $err',
      );
      onError?.call(err);
    }, onDone: () {
      if (socket!.closeCode != 1000) {
        wcEventsLog('DISCONNECTED WITH CODE: ${socket!.closeCode}\n');
        socket?.sink.close();
        onDisconnect?.call(socket!.closeCode, socket!.closeReason);
        socket = null;

        if (autoreconnect == true && disconnectedManually == true) {
          wcEventsLog('RECONNECTING...');
          connect();
        }
      }
    });
    subscribe(session!.topic);
    subscribe(clientId);

    wcEventsLog('connected');
    state = WCInteractorState.connected;
    return true;
  }

  void onReceiveMessage(event) {
    var msg;
    wcEventsLog('received: $event');
    try {
      msg = Map<String, dynamic>.from(json.decode(event));
    } catch (_) {
      msg = event;
    }

    if (msg.runtimeType is String) {
      if (msg == 'text') socket!.sink.add('');
      wcEventsLog('pong', false);
    } else {
      var topic = msg['topic'];

      var payload = WCEncryptionPayload.fromJson(json.decode(msg['payload']));

      var decrypted = WCEncryptor().decrypt(payload, session!.key);
      var decoded_json = json.decode(decrypted);

      wcEventsLog('decrypted: $decrypted');
      var method = decoded_json['method'] as String?;

      if (defaultMethods.contains(method)) {
        handleEvent(topic, method, decoded_json);
      } else {
        //handleCustomRequest(decoded_json);
      }
    }
  }

  void handleEvent(String? topic, String? event, Map<String, dynamic> decrypted) {
    try {
      switch (event) {
        case 'wc_sessionRequest':
          var jsonrpc = JSONRPCRequest.fromJson(decrypted, [WCSessionRequestParam.fromJson(decrypted['params'].first)]);
          handshakeId = jsonrpc.id;
          peerId = jsonrpc.params!.first.peerId;
          peerMeta = jsonrpc.params!.first.peerMeta;
          onSessionRequest?.call(handshakeId, jsonrpc.params!.first);
          break;
        case 'wc_sessionUpdate':
          var params = WCSessionUpdateParam.fromJson(decrypted['params'].first);
          if (params.approved == false) {
            disconnect();
          }
          break;

        case 'eth_sign':
          if (onEthSign != null) {
            var jsonrpc = JSONRPCRequest.fromJson(decrypted, decrypted['params']);
            if (jsonrpc.params!.length < 2) {
              throw ArgumentError('invalid jsonrpc params; request id: ${jsonrpc.id}');
            }
            onEthSign!.call(jsonrpc.id, WCEthereumSignMessage(jsonrpc.params!.cast<String>(), WCSignType.MESSAGE));
          }
          break;

        case 'personal_sign':
          if (onEthSign != null) {
            var jsonrpc = JSONRPCRequest.fromJson(decrypted, decrypted['params']);
            if (jsonrpc.params!.length < 2) {
              throw ArgumentError('invalid jsonrpc params; request id: ${jsonrpc.id}');
            }
            onEthSign!.call(jsonrpc.id, WCEthereumSignMessage(jsonrpc.params!.cast<String>(), WCSignType.PERSONAL_MESSAGE));
          }
          break;

        case 'eth_signTypedData':
          if (onEthSign != null) {
            var jsonrpc = JSONRPCRequest.fromJson(decrypted, decrypted['params']);
            if (jsonrpc.params!.length < 2) {
              throw ArgumentError('invalid jsonrpc params; request id: ${jsonrpc.id}');
            }
            onEthSign!.call(jsonrpc.id, WCEthereumSignMessage(jsonrpc.params, WCSignType.TYPED_MESSAGE));
          }
          break;

        case 'eth_signTransaction':
          if (onEthSignTransaction != null) {
            var jsonrpc = JSONRPCRequest.fromJson(decrypted, [WCEthereumTransaction.fromJson(decrypted['params'].first)]);

            onEthSignTransaction?.call(jsonrpc.id, jsonrpc.params!.first);
          }
          break;

        case 'eth_sendTransaction':
          if (onEthSendTransaction != null) {
            var jsonrpc = JSONRPCRequest.fromJson(decrypted, [WCEthereumTransaction.fromJson(decrypted['params'].first)]);

            onEthSendTransaction?.call(jsonrpc.id, jsonrpc.params!.first);
          }
          break;

        case 'bnb_sign':
          if (onBnbSign != null) {
            var jsonrpc = JSONRPCRequest.fromJson(decrypted, [WCBinanceSign.fromJson(decrypted['params'].first)]);

            onBnbSign?.call(jsonrpc.id, jsonrpc.params!.first);
          }
          break;

        case 'bnb_tx_confirmation':
          if (onBnbTxConfirmation != null) {
            var jsonrpc = JSONRPCRequest.fromJson(decrypted, [WCBinanceTxConfirmation.fromJson(decrypted['params'].first)]);
          }
          break;
      }
    } catch (e, st) {
      print(e);
      print(st);
    }
  }

  //void handleCustomRequest(Map<String, dynamic> decrypted) {}
  void subscribe(String? topic) {
    var message = WCSocketMessage(topic: topic, messageType: MessageType.sub, payload: '');

    socket!.sink.add(json.encode(message));
    wcEventsLog('subscribe: ${json.encode(message)}');
  }

  void approveSession(int chainId, List<String> accounts) {
    if (handshakeId! <= 0) throw Exception('Invalid session');
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

  void approveRequest(result) {
    encryptAndSend(json.encode(result));
  }

  void encryptAndSend(String data) {
    wcEventsLog('to encrypt: $data', false);
    var payload = WCEncryptor().encrypt(data, session!.key);
    var message = WCSocketMessage(messageType: MessageType.pub, payload: json.encode(payload), topic: peerId ?? session!.topic);
    var msgstr = json.encode(message);
    wcEventsLog('msg str sent: $msgstr', false);
    socket!.sink.add(msgstr);
  }

  void disconnect() {
    disconnectedManually = true;

    socket!.sink.close(1000);
    state = WCInteractorState.disconnected;
    handshakeId = -1;
    onDisconnect?.call(null, null);
  }

  void killSession() {
    var result = WCApproveSessionResponse(
      approved: false,
      chainId: null,
      accounts: null,
    );
    var jsonrpc = JSONRPCResponse(id: handshakeId, result: result);
    encryptAndSend(json.encode(jsonrpc));
    disconnect();
  }
}
