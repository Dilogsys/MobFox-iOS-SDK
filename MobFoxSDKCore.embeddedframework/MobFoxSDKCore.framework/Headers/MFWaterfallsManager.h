//
//  WaterfallsManager.h
//  MobFoxSDKCore
//
//  Created by Shimi Sheetrit on 6/6/16.
//  Copyright © 2016 Itamar Nabriski. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface MFWaterfallsManager : NSObject <NSURLSessionDataDelegate, NSURLSessionDelegate>


+ (instancetype)sharedInstance;
- (BOOL)isCacheContainsWaterfallDataForInventoryHash:(NSString *)inventoryHash;
- (void)waterfallsWithInventoryHash:(NSString *)inventoryHash completion:(void(^)(NSData *data))completion;
- (void)reloadData:(NSString*)inventoryHash completion:(void(^)(NSData *data))completion;


@end
