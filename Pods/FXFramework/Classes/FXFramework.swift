//
//  FXFramework.swift
//
//
//  Created by Savaş Salihoğlu on 12.10.2023.
//

import Foundation
import AppTrackingTransparency

private let kATTLAST_SENT_STATUS = "att_last_sent_status"

public class FX {
    
    public static let version = "0.2.11"
    
    
    public static let shared: FX = {
        let fx: FX = .init()
        return fx
    }()

    
    var defaultFXAnalytics: DefaultFXAnalytics?
    var adaptyFXPurchase: AdaptyFXPurchase?
    /*
    public func iniPurchase(with purchaseServiceType: FXPurchaseServiceType) -> FXPurchase {
        
        switch purchaseServiceType {
        case .adapty:
            return makeAdaptyFXPurchase()
        case .default:
            return makeDefaultFXPurchase()
        }
        
    }*/
    
    public func initAnalytics(with config: FXAnalyticsConfig) -> FXAnalytics {
        if let defaultFXAnalytics = defaultFXAnalytics {
            return defaultFXAnalytics
        }
        let defaultFXAnalytics: DefaultFXAnalytics = DefaultFXAnalytics(config: config)
        defaultFXAnalytics.adjustFXAnalyticsService?.delegate = self
        self.defaultFXAnalytics = defaultFXAnalytics
        return defaultFXAnalytics
    }
    
    
    public func update() async {
        print("TEST: FXFramework update")
        guard let defaultFXAnalytics = defaultFXAnalytics else { return }
        guard let adaptyFXPurchase = adaptyFXPurchase else { return }

        if let firebaseFXAnalyticsService = defaultFXAnalytics.firebaseFXAnalyticsService {
            await adaptyFXPurchase.setIntegrationIdentifier(key: "firebase_app_instance_id", value: firebaseFXAnalyticsService.firebaseInstanceId ?? "")
        }
        
        if let amplitudeFXAnalyticsService = defaultFXAnalytics.amplitudeFXAnalyticsService {
            await adaptyFXPurchase.setIntegrationIdentifier(key: "amplitude_device_id", value: amplitudeFXAnalyticsService.deviceId ?? "")
            await adaptyFXPurchase.setIntegrationIdentifier(key: "amplitude_user_id", value: amplitudeFXAnalyticsService.userId ?? "")
        }
    }
    
    @available(iOS 14, *)
    private func mapAdjustStatus(_ status: UInt) -> ATTrackingManager.AuthorizationStatus {
        switch status {
            case 3: return .authorized
            case 2: return .denied
            case 1: return .restricted
            default: return .notDetermined
        }
    }

    public func requestATT() {
        if let adjustFXAnalyticsService = defaultFXAnalytics?.adjustFXAnalyticsService {
            adjustFXAnalyticsService.requestATT { status in
                if #available(iOS 14, *) {
                    let mapped = self.mapAdjustStatus(status)
                    self.adaptyFXPurchase?.updateProfile(params: AdaptyFXPurchaseProfileParameters(appTrackingTransparencyStatus: mapped))
                    self.handleATTEventIfNeeded(status: mapped)
                }
            }
        } else {
            if #available(iOS 14, *) {
                ATTrackingManager.requestTrackingAuthorization { status in
                    self.adaptyFXPurchase?.updateProfile(params: AdaptyFXPurchaseProfileParameters(appTrackingTransparencyStatus: status))
                    self.handleATTEventIfNeeded(status: status)
                }
            }
        }
    }

    @available(iOS 14, *)
    private func handleATTEventIfNeeded(status: ATTrackingManager.AuthorizationStatus) {
        let raw: Int
        switch status {
            case .authorized: raw = 3
            case .denied: raw = 2
            default: return
        }
        print("FXTEST: attLastSentStatus: \(status)")
        if UserDefaults.standard.attLastSentStatus != raw {
            if raw == 3 {
                self.defaultFXAnalytics?.send(event: "att_permission_allow", properties: nil, onlyFor: nil)
            } else {
                self.defaultFXAnalytics?.send(event: "att_permission_decline", properties: nil, onlyFor: nil)
            }
            print("FXTEST: defaultFXAnalytics sent")
            UserDefaults.standard.attLastSentStatus = raw
        }
    }
    
    public func makeAdaptyFXPurchase(config: AdaptyFXPurchaseConfig) -> AdaptyFXPurchase {
        let adaptyFXPurchase = AdaptyFXPurchase(config: config)
        self.adaptyFXPurchase = adaptyFXPurchase
        return adaptyFXPurchase
    }
    
    public func makeDefaultFXPurchase() -> DefaultFXPurchase {
        return DefaultFXPurchase(config: .init(localeCode: ""))
    }
    
}


extension FX: AdjustFXAnalyticsServiceDelegate {
    
    public func AdjustFXAnalyticsServiceAttributionChanged(_ attribution: [AnyHashable : Any]) {
        if let adaptyFXPurchase = adaptyFXPurchase {
            print("TEST: AdjustFXAnalyticsServiceAttributionChanged", FXAnalyticsServiceType.adjust.attributionSource)
            adaptyFXPurchase.updateAttribution(attribution: attribution,
                                               source: FXAnalyticsServiceType.adjust.attributionSource)
        }
    }
    
    public func AdjustFXAnalyticsServiceSetIntegrationId(_ key: String, value: String) async {
        if let adaptyFXPurchase = adaptyFXPurchase {
            print("TEST: AdjustFXAnalyticsServiceSetIntegrationId", value)
            await adaptyFXPurchase.setIntegrationIdentifier(key: key, value: value)
        }
    }
    
}

extension UserDefaults {
    var attLastSentStatus: Int? {
        get { object(forKey: kATTLAST_SENT_STATUS) == nil ? nil : integer(forKey: kATTLAST_SENT_STATUS) }
        set { newValue == nil ? removeObject(forKey: kATTLAST_SENT_STATUS) : set(newValue, forKey: kATTLAST_SENT_STATUS) }
    }
}
