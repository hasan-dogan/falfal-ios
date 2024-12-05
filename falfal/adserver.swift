import SwiftUI
import GoogleMobileAds

class AdManager: NSObject, ObservableObject, GADFullScreenContentDelegate {
    @Published var isAdReady = false // ObservableObject ile uyumlu
    var interstitialAd: GADInterstitialAd?
    var adDidFinishHandler: (() -> Void)?
    var interstitialAdLoaded: Bool = false
	var adIsLoading: Bool = false

    func loadInterstitialAd(){
        GADMobileAds.sharedInstance().requestConfiguration.testDeviceIdentifiers = [ "17924b107454c796ada14461e26b256b" ]
            GADInterstitialAd.load(withAdUnitID: "ca-app-pub-1359373012454584/1160621193", request: GADRequest()) { [weak self] add, error in
                guard let self = self else {return}
                if let error = error{
                    print("🔴: \(error.localizedDescription)")
                    self.interstitialAdLoaded = false
                    return
                }
                print("🟢: Loading succeeded")
                self.interstitialAdLoaded = true
                self.interstitialAd = add
                self.interstitialAd?.fullScreenContentDelegate = self
            }
        }
        
        // Display InterstitialAd
    func displayInterstitialAd(){
            guard let root = UIApplication.shared.windows.first?.rootViewController else {
                return
            }
            if let add = interstitialAd{
                add.present(fromRootViewController: root)
                self.interstitialAdLoaded = false
            }else{
                print("🔵: Ad wasn't ready")
                self.interstitialAdLoaded = false
                self.loadInterstitialAd()
            }
        return;
        }
	
	func loadInterstitialAdForHome(){
		GADMobileAds.sharedInstance().requestConfiguration.testDeviceIdentifiers = [ "17924b107454c796ada14461e26b256b" ]
			GADInterstitialAd.load(withAdUnitID: "ca-app-pub-1359373012454584/1160621193", request: GADRequest()) { [weak self] add, error in
				guard let self = self else {return}
				if let error = error{
					print("🔴: \(error.localizedDescription)")
					self.interstitialAdLoaded = false
					return
				}
				print("🟢: Loading succeeded")
				self.interstitialAdLoaded = true
				self.interstitialAd = add
				self.interstitialAd?.fullScreenContentDelegate = self
			}
		}
		
		// Display InterstitialAd
	func displayInterstitialAdForHome(){
			guard let root = UIApplication.shared.windows.first?.rootViewController else {
				return
			}
			if let add = interstitialAd{
				add.present(fromRootViewController: root)
				self.interstitialAdLoaded = false
			}else{
				print("🔵: Ad wasn't ready")
				self.interstitialAdLoaded = false
				self.loadInterstitialAd()
			}
		return;
		}
        
        // Failure notification
        func ad(_ ad: GADFullScreenPresentingAd, didFailToPresentFullScreenContentWithError error: Error) {
            print("🟡: Failed to display interstitial ad")
            self.loadInterstitialAd()
        }
        
        // Indicate notification
        func adWillPresentFullScreenContent(_ ad: GADFullScreenPresentingAd) {
            print("🤩: Displayed an interstitial ad")
			
            self.interstitialAdLoaded = false
			self.adIsLoading = true

        }
        
        // Close notification
        func adDidDismissFullScreenContent(_ ad: GADFullScreenPresentingAd) {
        }
}
