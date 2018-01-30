//
//  MFTestAdapterBase.h
//  DemoApp
//
//  Created by Shimi Sheetrit on 12/20/16.
//  Copyright © 2016 Matomy Media Group Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#ifdef  DemoAppDynamicTarget
#import <MobFoxSDKCoreDynamic/MobFoxSDKCoreDynamic.h>
#else
#import <MobFoxSDKCore/MobFoxSDKCore.h>
#endif


#ifndef MFTestAdapterBase_h
#define MFTestAdapterBase_h


@class MFTestAdapterBase;

@protocol MFTestAdapterBaseDelegate <NSObject>

// banner
- (void)MFTestAdapterBaseAdDidLoad:(UIView *)ad;
- (void)MFTestAdapterBaseAdDidFailToReceiveAdWithError:(NSError *)error;

// Interstital
- (void)MFTestAdapterInterstitialAdapterBaseAdDidLoad:(UIView *)ad;
- (void)MFTestAdapterInterstitialAdapterBaseAdDidFailToReceiveAdWithError:(NSError *)error;

// native
- (void)MFTestAdapterNativeAdapterBaseAdDidLoad:(MobFoxNativeData *)adData;
- (void)MFTestAdapterNativeAdapterBaseAdDidFailToReceiveAdWithError:(NSError *)error;

@optional

- (void)MFTestAdapterBaseAdClosed;

- (void)MFTestAdapterBaseAdClicked;

- (void)MFTestAdapterBaseAdFinished;

@end


@interface MFTestAdapterBase : NSObject

- (void)requestAdWithSize:(CGSize)size networkID:(NSString*)nid customEventInfo:(NSDictionary *)info;
- (void)requestInterstitialAdWithSize:(CGSize)size networkID:(NSString*)nid customEventInfo:(NSDictionary *)info;
- (void)requestNativeAdWithSize:(CGSize)size networkID:(NSString*)nid customEventInfo:(NSDictionary *)info;


@property (nonatomic, weak) id<MFTestAdapterBaseDelegate> delegate;

@end

#endif /* MFTestAdapterBase_h */
