//
//  GADMAdapterMobFox.m
//  DemoApp
//
//  Created by Shimi Sheetrit on 6/22/16.
//  Copyright © 2016 Matomy Media Group Ltd. All rights reserved.
//

#import "GADMAdapterMobFox.h"

@interface GADMAdapterMobFox()

//@property (nonatomic, strong) MFEventsHandler *eventsHandler;
@property (nonatomic, strong) MobFoxTagAd* banner;
@property (nonatomic, strong) MobFoxTagInterstitialAd* interstitial;
@property (nonatomic, weak) id <GADMAdNetworkConnector> connector;


@end

@implementation GADMAdapterMobFox

#pragma mark GADMAdNetworkAdapter Delegate

+ (NSString *)adapterVersion {
    
    return @"1.2";
}

+ (Class<GADAdNetworkExtras>)networkExtrasClass {
    
    return nil;
}

- (id)initWithGADMAdNetworkConnector:(id<GADMAdNetworkConnector>)c {
    if ((self = [super init])) {
        _connector = c;
        //_eventsHandler = [[MFEventsHandler alloc] init];
    }
    return self;
}

- (void)getBannerWithSize:(GADAdSize)adSize {
    
    
    //[_eventsHandler resetAdEventBlocker];
   
    NSLog(@"MobFox >> GADMAdapterMobFox >> Ad Request");

    NSString *invh = [[self.connector credentials] objectForKey:@"pubid"];
    
    if (GADAdSizeEqualToSize(adSize, kGADAdSizeSmartBannerPortrait) || GADAdSizeEqualToSize(adSize, kGADAdSizeSmartBannerLandscape)){
        
        CGRect screenRect = [[UIScreen mainScreen] bounds];
        CGFloat screenWidth = screenRect.size.width;
        CGFloat bannerHeight;
        
        if (GADAdSizeEqualToSize(adSize, kGADAdSizeSmartBannerPortrait)) {
            bannerHeight = [UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPad ? 90.0 : 50.0;

        } else {
            bannerHeight = [UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPad ? 90.0 : 32.0;
            
        }
        
        //NSLog(@"screen width: %f   banner height: %f", screenWidth, bannerHeight);
        
        self.banner = [[MobFoxTagAd alloc] init:invh withFrame:CGRectMake(0, 0, screenWidth, bannerHeight)];
        self.banner.delegate = self;
        [self.banner loadAd];
        
        //[MFReport log:@"admob" withInventoryHash:invh andWithMessage:@"request" requestID:self.banner.requestID];
        
        return;
        
    }
    
    
    self.banner = [[MobFoxTagAd alloc] init:invh withFrame:CGRectMake(0, 0, adSize.size.width, adSize.size.height)];
    self.banner.delegate = self;
    [self.banner loadAd];
    
//    [MFReport log:@"admob" withInventoryHash:invh andWithMessage:@"request" requestID:self.banner.requestID];
    

}

- (void)getInterstitial {
    
    NSLog(@"MobFox >> GADMAdapterMobFox >> Got Interstitial Ad Request");
    
    NSString *invh = [[self.connector credentials] objectForKey:@"pubid"];
    self.interstitial = [[MobFoxTagInterstitialAd alloc] init:invh];
    self.interstitial.delegate = self;
    [self.interstitial loadAd];
    
  //  [MFReport log:@"admob" withInventoryHash:invh andWithMessage:@"request" requestID:self.interstitial.requestID];
        
    
}

- (void)presentInterstitialFromRootViewController:
(UIViewController *)rootViewController {
    
    NSLog(@"MobFox >> GADMAdapterMobFox >> Got Display Request");
    
    if(self.interstitial.ready) {
        self.interstitial.rootViewController = rootViewController;
        [self.interstitial show];
    }
}

- (void)stopBeingDelegate {

}

- (BOOL)isBannerAnimationOK:(GADMBannerAnimationType)animType {
    return YES;
}


#pragma mark MobFox Tag Ad Delegate

- (void)MobFoxTagAdDidLoad:(MobFoxTagAd *)banner {
    NSLog(@"MobFox >> GADMAdapterMobFox >> Ad Loaded");
    [self.connector adapter:self didReceiveAdView:banner];
}

- (void)MobFoxTagAdDidFailToReceiveAdWithError:(NSError *)error {
    NSLog(@"MobFox >> GADMAdapterMobFox >> Ad Loaded Failed: %@", error);
    [self.connector adapter:self didFailAd:error];
}

- (void)MobFoxTagAdClicked {
   [self.connector adapterDidGetAdClick:self];
   [self.connector adapterWillLeaveApplication:self];
}

- (void)MobFoxTagAdClosed {
}

- (void)MobFoxTagAdFinished {
}


#pragma mark MobFox Interstitial Ad Delegate

- (void)MobFoxTagInterstitialAdDidLoad:(MobFoxTagInterstitialAd *)interstitial{
    
    NSLog(@"admob >>> MobFoxTagInterstitialAdDidLoad:");
    
    [self.connector adapterDidReceiveInterstitial:self];
        
   // [MFReport log:@"admob" withInventoryHash:interstitial.invh andWithMessage:@"impression" requestID:interstitial.requestID];
}

- (void)MobFoxTagInterstitialAdDidFailToReceiveAdWithError:(NSError *)error{
    [self.connector adapter:self didFailAd:error];
}

- (void)MobFoxTagInterstitialAdWillShow:(MobFoxTagInterstitialAd *)interstitial{
    
    [self.connector adapterWillPresentInterstitial:self];
}

- (void)MobFoxTagInterstitialAdDidShow:(MobFoxTagInterstitialAd *)interstitial {
    
}

//called when ad is closed/skipped
- (void)MobFoxTagInterstitialAdClosed{
    [self.connector adapterDidDismissInterstitial:self];
}

//called when ad is clicked
- (void)MobFoxTagInterstitialAdClicked {
    
    [self.connector adapterDidGetAdClick:self];
    [self.connector adapterWillLeaveApplication:self];
    
}

//called when if the ad is a video ad and it has finished playing
- (void)MobFoxTagInterstitialAdFinished{
}

- (void) dealloc{
    //self.eventsHandler          = nil;
    self.banner.delegate        = nil;
    self.banner                 = nil;
    self.interstitial.delegate  = nil;
    self.interstitial           = nil;
}

@end
