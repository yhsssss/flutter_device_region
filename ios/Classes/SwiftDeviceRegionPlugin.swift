import Flutter
import UIKit
import CoreTelephony
import SystemConfiguration
import Foundation

public class SwiftDeviceRegionPlugin: NSObject, FlutterPlugin {
    public static func register(with registrar: FlutterPluginRegistrar) {
        let channel = FlutterMethodChannel(name: "device_region", binaryMessenger: registrar.messenger())
        let instance = SwiftDeviceRegionPlugin()
        registrar.addMethodCallDelegate(instance, channel: channel)
    }
    
    public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        if(call.method == "getSIMCountryCode"){
            if #available(iOS 12.0, *) {
                let networkProviders = CTTelephonyNetworkInfo().serviceSubscriberCellularProviders
                let countryCode = networkProviders?.first?.value.isoCountryCode ?? nil
                
                result(countryCode)
            } else {
                result(nil)
            }
        } else if(call.method == "getAccessTechnology") {
                guard let reachability = SCNetworkReachabilityCreateWithName(kCFAllocatorDefault, "www.google.com") else {
                    result("NO INTERNET")
                    return
                }

                var flags = SCNetworkReachabilityFlags()
                SCNetworkReachabilityGetFlags(reachability, &flags)

                let isReachable = flags.contains(.reachable)
                let isWWAN = flags.contains(.isWWAN)

                if #available(iOS 14.1, *) {
                   if isReachable {
                           if isWWAN {
                               let networkInfo = CTTelephonyNetworkInfo()
                               let carrierType = networkInfo.serviceCurrentRadioAccessTechnology

                               guard let carrierTypeName = carrierType?.first?.value else {
                                   result("UNKNOWN")
                                   return
                               }

                               switch carrierTypeName {
                                   case CTRadioAccessTechnologyGPRS, CTRadioAccessTechnologyEdge, CTRadioAccessTechnologyCDMA1x:
                                       result("2G")
                                       return
                                   case CTRadioAccessTechnologyLTE:
                                       result("4G")
                                       return
                                   default:
                                       result("3G")
                                       return
                               }
                           } else {
                               result("WIFI")
                               return
                           }
                       } else {
                           result("NO INTERNET")
                           return
                       }
                } else {
                    result(nil)
                }
        }
        else {
            result(FlutterMethodNotImplemented)
        }
    }
}
