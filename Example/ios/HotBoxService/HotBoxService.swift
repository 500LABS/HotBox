//
//  HotBoxService.swift
//  hotbox
//
//  Created by George Lim on 2017-08-08.
//  Copyright © 2017 George Lim. All rights reserved.
//

import Foundation
import RxSwift

@objc(HotBoxService)
class HotBoxService: RCTEventEmitter {
  
  var disposeBag = DisposeBag()
  
  private enum Events: String {
    case sessionDidConnect, sessionDidDisconnect, sessionStreamCreated, sessionDidFailWithError, sessionStreamDestroyed, sessionConnectionCreated, sessionReceivedSignalType, sessionConnectionDestroyed,publisherStreamCreated, publisherDidFailWithError, publisherStreamDestroyed, publisherAudioLevelUpdated, subscriberDidConnectToStream, subscriberDidFailWithError, subscriberDidDisconnectFromStream, subscriberAudioLevelUpdated
  }
  
  override func supportedEvents() -> [String]! {
    return [Events.sessionDidConnect.rawValue, Events.sessionDidDisconnect.rawValue, Events.sessionStreamCreated.rawValue, Events.sessionDidFailWithError.rawValue, Events.sessionStreamDestroyed.rawValue, Events.sessionConnectionCreated.rawValue, Events.sessionReceivedSignalType.rawValue, Events.sessionConnectionDestroyed.rawValue, Events.publisherStreamCreated.rawValue, Events.publisherDidFailWithError.rawValue, Events.publisherStreamDestroyed.rawValue, Events.publisherAudioLevelUpdated.rawValue, Events.subscriberDidConnectToStream.rawValue, Events.subscriberDidFailWithError.rawValue, Events.subscriberDidDisconnectFromStream.rawValue, Events.subscriberAudioLevelUpdated.rawValue]
  }
  
  @objc func bindSignals() {
    disposeBag = DisposeBag()
    
    HotBoxNativeService.shared.sessionDidConnect.asObservable().skip(1).subscribe(onNext: {
      [weak self]
      (signal) in
      self?.sendEvent(withName: Events.sessionDidConnect.rawValue, body: signal)
      print("Session connected")
    }).addDisposableTo(disposeBag)
    
    HotBoxNativeService.shared.sessionDidDisconnect.asObservable().skip(1).subscribe(onNext: {
      [weak self]
      (signal) in
      self?.sendEvent(withName: Events.sessionDidDisconnect.rawValue, body: signal)
      print("Session disconnected")
    }).addDisposableTo(disposeBag)
    
    HotBoxNativeService.shared.sessionConnectionCreated.asObservable().skip(1).subscribe(onNext: {
      [weak self]
      (signal) in
      self?.sendEvent(withName: Events.sessionConnectionCreated.rawValue, body: signal)
      print("Session connection created")
    }).addDisposableTo(disposeBag)
    
    HotBoxNativeService.shared.sessionConnectionDestroyed.asObservable().skip(1).subscribe(onNext: {
      [weak self]
      (signal) in
      self?.sendEvent(withName: Events.sessionConnectionDestroyed.rawValue, body: signal)
      print("Session connection destroyed")
    }).addDisposableTo(disposeBag)
    
    HotBoxNativeService.shared.sessionStreamCreated.asObservable().skip(1).subscribe(onNext: {
      [weak self]
      (signal) in
      self?.sendEvent(withName: Events.sessionStreamCreated.rawValue, body: signal)
      print("Session stream created")
    }).addDisposableTo(disposeBag)
    
    HotBoxNativeService.shared.sessionStreamDidFailWithError.asObservable().skip(1).subscribe(onNext: {
      [weak self]
      (signal) in
      if let signal = signal {
        self?.sendEvent(withName: Events.sessionStreamDidFailWithError.rawValue, body: signal)
        print("Session stream failed")
        print(signal)
      }
    }).addDisposableTo(disposeBag)
    
    HotBoxNativeService.shared.sessionStreamDestroyed.asObservable().skip(1).subscribe(onNext: {
      [weak self]
      (signal) in
      self?.sendEvent(withName: Events.sessionStreamDestroyed.rawValue, body: signal)
      print("Session stream destroyed")
    }).addDisposableTo(disposeBag)
    
    HotBoxNativeService.shared.sessionReceivedSignal.asObservable().skip(1).subscribe(onNext: {
      [weak self]
      (signal) in
      self?.sendEvent(withName: Events.sessionReceivedSignal.rawValue, body: signal)
      print("Session received signal")
      
      // Demo
      let alertController = UIAlertController(title: signal["connectionId"]!, message: signal["string"]!, preferredStyle: .alert)
      let dismissAction = UIAlertAction(title: "Dismiss", style: .cancel, handler: nil)
      alertController.addAction(dismissAction)
      UIApplication.shared.windows.first?.rootViewController?.present(alertController, animated: true, completion: nil)
    }).addDisposableTo(disposeBag)
    
    HotBoxNativeService.shared.publisherStreamCreated.asObservable().skip(1).subscribe(onNext: {
      [weak self]
      (signal) in
      self?.sendEvent(withName: Events.publisherStreamCreated.rawValue, body: signal)
      print("Publisher stream created")
      
      // Demo
      self?.createPublisherView()
    }).addDisposableTo(disposeBag)
    
    HotBoxNativeService.shared.publisherStreamDidFailWithError.asObservable().skip(1).subscribe(onNext: {
      [weak self]
      (signal) in
      if let signal = signal {
        self?.sendEvent(withName: Events.publisherStreamDidFailWithError.rawValue, body: signal)
        print("Publisher stream failed")
        print(signal)
      }
    }).addDisposableTo(disposeBag)
    
    HotBoxNativeService.shared.publisherStreamDestroyed.asObservable().skip(1).subscribe(onNext: {
      [weak self]
      (signal) in
      self?.sendEvent(withName: Events.publisherStreamDestroyed.rawValue, body: signal)
      print("Publisher stream destroyed")
    }).addDisposableTo(disposeBag)
    
    HotBoxNativeService.shared.subscriberDidConnect.asObservable().skip(1).subscribe(onNext: {
      [weak self]
      (signal) in
      self?.sendEvent(withName: Events.subscriberDidConnect.rawValue, body: signal)
      print("Subscriber stream connected")
      
      // Demo
      guard let streamId = signal else { return }
      self?.createSubscriberView(streamId: streamId)
    }).addDisposableTo(disposeBag)
    
    HotBoxNativeService.shared.subscriberDidFailWithError.asObservable().skip(1).subscribe(onNext: {
      [weak self]
      (signal) in
      if let signal = signal {
        self?.sendEvent(withName: Events.subscriberDidFailWithError.rawValue, body: signal)
        print("Subscriber stream failed")
        print(signal)
      }
    }).addDisposableTo(disposeBag)
    
    HotBoxNativeService.shared.subscriberDidDisconnect.asObservable().skip(1).subscribe(onNext: {
      [weak self]
      (signal) in
      self?.sendEvent(withName: Events.subscriberDidDisconnect.rawValue, body: signal)
      print("Subscriber stream disconnected")
    }).addDisposableTo(disposeBag)
  }
  
  @objc func disconnectAllSessions(resolver resolve: RCTPromiseResolveBlock, rejecter reject: RCTPromiseRejectBlock) {
    if HotBoxNativeService.shared.disconnectAllSessions() {
      resolve(nil)
    } else {
      reject("1", "", nil)
    }
  }
  
  @objc func createNewSession(apiKey: String, sessionId: String, token: String, resolver resolve: RCTPromiseResolveBlock, rejecter reject: RCTPromiseRejectBlock) {
    if HotBoxNativeService.shared.createNewSession(apiKey: apiKey, sessionId: sessionId, token: token) {
      resolve(nil)
    } else {
      reject("1", "", nil)
    }
  }
  
  @objc func createPublisher(resolver resolve: RCTPromiseResolveBlock, rejecter reject: RCTPromiseRejectBlock) {
    if HotBoxNativeService.shared.createPublisher() {
      resolve(nil)
    } else {
      reject("1", "", nil)
    }
  }
  
  @objc func createSubscriber(streamId: String, resolver resolve: RCTPromiseResolveBlock, rejecter reject: RCTPromiseRejectBlock) {
    if HotBoxNativeService.shared.createSubscriber(streamId: streamId) {
      resolve(nil)
    } else {
      reject("1", "", nil)
    }
  }
  
  @objc func sendSignal(type: String?, string: String?, to connectionId: String?, resolver resolve: RCTPromiseResolveBlock, rejecter reject: RCTPromiseRejectBlock) {
    if HotBoxNativeService.shared.sendSignal(type: type, string: string, to: connectionId) {
      resolve(nil)
    } else {
      reject("1", "", nil)
    }
  }
  
  @objc func requestVideoStream(for streamId: String? = nil, on: Bool, resolver resolve: RCTPromiseResolveBlock, rejecter reject: RCTPromiseRejectBlock) {
    if HotBoxNativeService.shared.requestVideoStream(for: streamId, on: on) {
      resolve(nil)
    } else {
      reject("1", "", nil)
    }
  }
  
  @objc func requestAudioStream(for streamId: String? = nil, on: Bool, resolver resolve: RCTPromiseResolveBlock, rejecter reject: RCTPromiseRejectBlock) {
    if HotBoxNativeService.shared.requestAudioStream(for: streamId, on: on) {
      resolve(nil)
    } else {
      reject("1", "", nil)
    }
  }
  
  @objc func requestCameraSwap(toBack: Bool, resolver resolve: RCTPromiseResolveBlock, rejecter reject: RCTPromiseRejectBlock) {
    if HotBoxNativeService.shared.requestCameraSwap(toBack: toBack) {
      resolve(nil)
    } else {
      reject("1", "", nil)
    }
  }
}
