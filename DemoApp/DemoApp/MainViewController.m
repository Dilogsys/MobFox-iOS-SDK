//
//  ViewController.m
//  DemoApp
//
//  Created by Shimi Sheetrit on 2/1/16.
//  Copyright © 2016 Matomy Media Group Ltd. All rights reserved.
//

#import "MainViewController.h"
#import "CollectionViewCell.h"
#import "SettingsViewController.h"
#import "NativeAdViewController.h"
#import "MPMobFoxNativeAdRenderer.h"
#import "MoPubNativeAdapterMobFox.h"


#define ADS_TYPE_NUM 4
#define AD_REFRESH 0


#define MOBFOX_HASH_BANNER @"9c09794cc85e7c9f9205e7a26f03234c" //@"fe96717d9875b9da4339ea5367eff1ec" // @"9c09794cc85e7c9f9205e7a26f03234c"
#define MOBFOX_HASH_INTER @"267d72ac3f77a3f447b32cf7ebf20673"  // @"145849979b4c7a12916c7f06d25b75e3"
#define MOBFOX_HASH_NATIVE @"4c3ea57788c5858881dc42cfafe8c0ab" //@"9c09794cc85e7c9f9205e7a26f03234c" // @"4c3ea57788c5858881dc42cfafe8c0ab"
#define MOBFOX_HASH_VIDEO @"651586294dac23e245f26789c4043aa9"


#define MOPUB_HASH_NATIVE @"ac0f139a2d9544fface76d06e27bc02a"

@interface MainViewController ()

@property (strong, nonatomic) MobFoxAd *mobfoxAd;
@property (strong, nonatomic) MobFoxInterstitialAd *mobfoxInterAd;
@property (strong, nonatomic) MobFoxNativeAd* mobfoxNativeAd;
@property (strong, nonatomic) MobFoxAd *mobfoxVideoAd;
@property (strong, nonatomic) NSURL *clickURL;
@property (strong, nonatomic) NSString *cellID;

@property (weak, nonatomic) IBOutlet UICollectionView *collectionView;
@property (weak, nonatomic) IBOutlet UIView *nativeAdView;
@property (weak, nonatomic) IBOutlet UIView *innerNativeAdView;

@property (weak, nonatomic) IBOutlet UIImageView *nativeAdIcon;
@property (weak, nonatomic) IBOutlet UILabel *nativeAdTitle;
@property (weak, nonatomic) IBOutlet UILabel *nativeAdDescription;

@property (nonatomic) CGRect adVideoRect;



@end

@implementation MainViewController



- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    NSString * plistPath = [[NSBundle mainBundle] pathForResource:@"response.json" ofType:nil];
    NSLog(@"plistPath %@", plistPath);
    
    self.cellID = @"cellID";
    self.nativeAdView.hidden = YES;
    
    UITapGestureRecognizer *recognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleGesture:)];
    [self.innerNativeAdView addGestureRecognizer:recognizer];
    
    // Oreintation dependent in iOS 8 and later.
    float screenWidth = [UIScreen mainScreen].bounds.size.width;
    float screenHeight = [UIScreen mainScreen].bounds.size.height;
    float bannerWidth = [UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPad ? 728.0 : 320.0;
    float bannerHeight = [UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPad ? 90.0 : 50.0;
    float videoWidth = [UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPad ? 500.0 : 300.0;
    float videoHeight = [UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPad ? 450.0 : 250.0;

    
    /*** Banner ***/
    CGRect adRect = CGRectMake((screenWidth-bannerWidth)/2, screenHeight-bannerHeight, bannerWidth, bannerHeight);
    self.mobfoxAd = [[MobFoxAd alloc] init:MOBFOX_HASH_BANNER withFrame:adRect];
    self.mobfoxAd.delegate = self;
    self.mobfoxAd.refresh = [NSNumber numberWithInt:AD_REFRESH];
    //self.mobfoxAd.type = @"video";
    //self.mobfoxAd.v_dur_min = [NSNumber numberWithInt:10];
    //self.mobfoxAd.v_dur_max = [NSNumber numberWithInt:2000];
    [self.view addSubview:self.mobfoxAd];
    
    /*** Interstitial ***/
    self.mobfoxInterAd = [[MobFoxInterstitialAd alloc] init:MOBFOX_HASH_INTER withRootViewController:self];
    //self.mobfoxInterAd.ad.type = @"video";
    self.mobfoxInterAd.delegate = self;
    
    /*** Native ***/
    self.mobfoxNativeAd = [[MobFoxNativeAd alloc] init:MOBFOX_HASH_NATIVE];
    self.mobfoxNativeAd.delegate = self;
    
    /*** Video ***/
    float videoTopMargin = [UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPad ? 200.0 : 80.0;
    self.adVideoRect = CGRectMake((screenWidth - videoWidth)/2, self.collectionView.frame.size.height + videoTopMargin, videoWidth, videoHeight);
    [self initVideoAd];
    
    //
    /*
    MPStaticNativeAdRendererSettings *settings = [[MPStaticNativeAdRendererSettings alloc] init];
    settings.renderingViewClass = [MoPubNativeAdView class];
    settings.viewSizeHandler = ^(CGFloat maximumWidth) {
        return CGSizeMake(maximumWidth, 77.0f);
    };
    
    MPNativeAdRendererConfiguration *config = [MPMobFoxNativeAdRenderer rendererConfigurationWithRendererSettings:settings];
    MPNativeAdRequest *adRequest = [MPNativeAdRequest requestWithAdUnitIdentifier:MOPUB_HASH_NATIVE rendererConfigurations:@[config]];
    MPNativeAdRequestTargeting *targeting = [MPNativeAdRequestTargeting targeting];
    
    targeting.desiredAssets = [NSSet setWithObjects:kAdTitleKey, kAdTextKey, kAdCTATextKey, kAdIconImageKey, kAdMainImageKey, kAdStarRatingKey, nil]; //The constants correspond to the 6 elements of MoPub native ads
    
    [adRequest startWithCompletionHandler:^(MPNativeAdRequest *request, MPNativeAd *response, NSError *error) {
        if (error) {
            // Handle error.
        } else {
            
            NSLog(@"request: %@", request);
            NSLog(@"response.properties: %@", response.properties);
            
            //self.nativeAd = response;
            //self.nativeAd.delegate = self;
            //UIView *nativeAdView = [response retrieveAdViewWithError:nil];
            //nativeAdView.frame = self.yourNativeAdViewContainer.bounds;
            //[self.yourNativeAdViewContainer addSubview:nativeAdView];
            
        }
    }];
     */
    
    /*
    UICollectionViewFlowLayout* flowLayout = [[UICollectionViewFlowLayout alloc]init];
    flowLayout.itemSize = CGSizeMake(100, 100);
    [flowLayout setScrollDirection:UICollectionViewScrollDirectionHorizontal];
    self.collectionView_new = [[UICollectionView alloc] initWithFrame:self.view.frame collectionViewLayout:flowLayout];
    
    //[self.collectionView registerClass:[CollectionCell class] forCellWithReuseIdentifier:@"cell"];
    
    self.placer = [MPCollectionViewAdPlacer placerWithCollectionView:self.collectionView_new
                                                      viewController:self
                                              rendererConfigurations:@[config]];
    self.placer.delegate = self;
    [self.placer loadAdsForAdUnitID:@"ac0f139a2d9544fface76d06e27bc02a"];
     */
    
    //
    

    
    // TEST: native ad adapter
      /*
    MobFoxNativeAd *nativeAd = [[MobFoxNativeAd alloc] init:MOBFOX_HASH_NATIVE];
    NSLog(@"nativeAd: %@", nativeAd);
  
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        MobFoxNativeAd *nativeAd = [[MobFoxNativeAd alloc] init:MOBFOX_HASH_NATIVE];
        NSLog(@"nativeAd: %@", nativeAd);

    });
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
    
        MoPubNativeAdapterMobFox *nativeAdAdapter = [[MoPubNativeAdapterMobFox alloc] init];
        nativeAdAdapter.delegate = self;
        [nativeAdAdapter requestAdWithCustomEventInfo:nil];
        
    }); */
    
    // AdMob.
    
    // banner.
    /*
    self.gadBannerView = [[GADBannerView alloc] initWithFrame:CGRectMake(0,430,320,50)];
     NSLog(@"AdMob >>> init banner");
    //self.bannerView.frame = CGRectMake(0.0,0.0,size.width,size.height);
    
    self.gadBannerView.adUnitID = @"ca-app-pub-6224828323195096/5240875564";
    self.gadBannerView.rootViewController = self;
    [self.view addSubview: self.gadBannerView];
    GADRequest *request = [[GADRequest alloc] init];
    //request.testDevices = @[ @"221e6c438e8184e0556942ea14bb214b" ];
    [self.gadBannerView loadRequest:request];
    
    // interstitial
    self.gadInterstitial = [[GADInterstitial alloc] initWithAdUnitID:@"ca-app-pub-6224828323195096/7876284361"];
    GADRequest *request_interstitial = [GADRequest request];
    // Requests test ads on test devices.
    //request.testDevice @[@"2077ef9a63d2b398840261c8221a0c9b"];
    [self.gadInterstitial loadRequest:request_interstitial];
    */
    
    /*
    // DFP request.
    self.dfpBannerView = [[DFPBannerView alloc] initWithFrame:CGRectMake(0,330,320,50)];
    self.dfpBannerView.adUnitID = @"ca-app-pub-6224828323195096/5240875564";
    self.dfpBannerView.rootViewController = self;
    [self.dfpBannerView loadRequest:[DFPRequest request]];
    [self.view addSubview: self.dfpBannerView];
    
    self.dfpInterstitial = [[DFPInterstitial alloc] initWithAdUnitID:@"ca-app-pub-6224828323195096/7876284361"];
    DFPRequest *request_inter = [DFPRequest request];
    // Requests test ads on test devices.
    //request.testDevice @[@"2077ef9a63d2b398840261c8221a0c9b"];
    [self.dfpInterstitial loadRequest:request_inter];
     */
    
    

    
}

- (UIViewController *)viewControllerForPresentingModalView {
    
    return self;
}

- (void)viewWillDisappear:(BOOL)animated {
    
    NSLog(@"viewWillDisappear");
    
    [super viewWillDisappear:animated];
    [self removeVideoAd];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark Collection View Data Source

- (NSInteger)numberOfSectionsInCollectionView: (UICollectionView *)collectionView {
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)view numberOfItemsInSection:(NSInteger)section {
    return ADS_TYPE_NUM;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)cv cellForItemAtIndexPath:(NSIndexPath *)indexPath;
{

    CollectionViewCell *cell = [cv dequeueReusableCellWithReuseIdentifier:self.cellID forIndexPath:indexPath];
    cell.title.text = [self adTitle:indexPath];
    cell.image.image = [self adImage:indexPath];
    
    if (cell.selected) {
        cell.backgroundColor = [UIColor lightGrayColor];
    } else {
        cell.backgroundColor = [UIColor whiteColor]; // Default color
    }
    
    return cell;
}

#pragma mark Collection View Delegate

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    
    /*
    if ([self.dfpInterstitial isReady]) {
        [self.dfpInterstitial presentFromRootViewController:self];
    }
    
    return ;
     */
    
    UICollectionViewCell* cell = [collectionView  cellForItemAtIndexPath:indexPath];
    cell.backgroundColor = [UIColor lightGrayColor];
    
    
    switch (indexPath.item) {
        case 0:
            [self hideAds:indexPath];
            [self removeVideoAd];
            self.mobfoxAd.invh = self.invh.length > 0 ? self.invh: MOBFOX_HASH_BANNER;
            [self resumeAdRefresh];
            break;
            
        case 1:
            
            [self hideAds:indexPath];
            [self pauseAdRefresh];
            [self removeVideoAd];
            self.mobfoxInterAd.ad.invh = self.invh.length > 0 ? self.invh: MOBFOX_HASH_INTER;
            [self.mobfoxInterAd loadAd];
            break;
            
        case 2:
            [self hideAds:indexPath];
            [self pauseAdRefresh];
            [self removeVideoAd];
            self.mobfoxNativeAd.invh = self.invh.length > 0 ? self.invh: MOBFOX_HASH_NATIVE;
            [self.mobfoxNativeAd loadAd];
            //[self presentViewController];
            
            break;
            
        case 3:
            
            [self hideAds:indexPath];
            [self pauseAdRefresh];
            [self removeVideoAd];
            [self initVideoAd];
            self.mobfoxVideoAd.invh = self.invh.length > 0 ? self.invh: MOBFOX_HASH_VIDEO;
            [self.mobfoxVideoAd loadAd];
            break;
            
        default:
            break;
    }
    
}

- (void)collectionView:(UICollectionView *)collectionView didDeselectItemAtIndexPath:(NSIndexPath *)indexPath{
    UICollectionViewCell* cell = [collectionView  cellForItemAtIndexPath:indexPath];
    cell.backgroundColor = [UIColor whiteColor];
}



#pragma mark MobFox Ad Delegate

//called when ad is displayed
- (void)MobFoxAdDidLoad:(MobFoxAd *)banner {
    
    NSLog(@"MobFoxAdDidLoad:");
}

//called when an ad cannot be displayed
- (void)MobFoxAdDidFailToReceiveAdWithError:(NSError *)error {
    
    NSLog(@"MobFoxAdDidFailToReceiveAdWithError: %@", [error description]);
}

//called when ad is closed/skipped
- (void)MobFoxAdClosed {
    NSLog(@"MobFoxAdClosed:");

}

//called when ad is clicked
- (void)MobFoxAdClicked {
    NSLog(@"MobFoxAdClicked:");

}

#pragma mark MobFox Interstitial Ad Delegate

//best to show after delegate informs an ad was loaded
- (void)MobFoxInterstitialAdDidLoad:(MobFoxInterstitialAd *)interstitial {
    
    NSLog(@"MobFoxInterstitialAdDidLoad:");
    
    if(self.mobfoxInterAd.ready){
        [self.mobfoxInterAd show];
    }

}

- (void)MobFoxInterstitialAdDidFailToReceiveAdWithError:(NSError *)error {
    
    NSLog(@"MobFoxInterstitialAdDidFailToReceiveAdWithError: %@", [error description]);
    
}

- (void)MobFoxInterstitialAdClosed {
    
    NSLog(@"MobFoxInterstitialAdClosed");
    
}

- (void)MobFoxInterstitialAdClicked {
    
    NSLog(@"MobFoxInterstitialAdClicked");
    
}

- (void)MobFoxInterstitialAdFinished {
    
    NSLog(@"MobFoxInterstitialAdFinished");
    
}

#pragma mark MobFox Native Ad Delegate

//called when ad response is returned
- (void)MobFoxNativeAdDidLoad:(MobFoxNativeAd *)ad withAdData:(MobFoxNativeData *)adData {
    
    self.nativeAdIcon.image = [UIImage imageWithData:[NSData dataWithContentsOfURL:adData.icon.url]];
    self.nativeAdTitle.text = adData.assetHeadline;
    self.nativeAdDescription.text = adData.assetDescription;
    self.clickURL = [adData.clickURL absoluteURL];
    
    //adData.callToActionText
    NSLog(@"adData.assetHeadline: %@", adData.assetHeadline);
    NSLog(@"adData.assetDescription: %@", adData.assetDescription);
    NSLog(@"adData.callToActionText: %@", adData.callToActionText);
    
    for (MobFoxNativeTracker *tracker in adData.trackersArray) {
        
        NSLog(@"tracker: %@", tracker);
        NSLog(@"tracker.url: %@", tracker.url);

        if ([tracker.url absoluteString].length > 0)
        {
            
            // Fire tracking pixel
            UIWebView* wv = [[UIWebView alloc] initWithFrame:CGRectZero];
            NSString* userAgent = [wv stringByEvaluatingJavaScriptFromString:@"navigator.userAgent"];
            NSLog(@"userAgent: %@", userAgent);
            NSURLSessionConfiguration* conf = [NSURLSessionConfiguration defaultSessionConfiguration];
            conf.HTTPAdditionalHeaders = @{ @"User-Agent" : userAgent };
            NSURLSession* session = [NSURLSession sessionWithConfiguration:conf];
            NSURLSessionDataTask* task = [session dataTaskWithURL:tracker.url completionHandler:
                                          ^(NSData *data,NSURLResponse *response, NSError *error){
                                          
                                              if(error) NSLog(@"err %@",[error description]);

                                          }];
            [task resume];
            
        }
        
    }
    
}

//called when ad response cannot be returned
- (void)MobFoxNativeAdDidFailToReceiveAdWithError:(NSError *)error {
    
    NSLog(@"MobFoxNativeAdDidFailToReceiveAdWithError: %@", [error description]);
    
}

#pragma mark Private Methods

- (void)hideAds:(NSIndexPath *)indexPath {
    
    switch (indexPath.item) {
        case 0:
            self.mobfoxAd.hidden= NO;
            self.mobfoxInterAd.ad.hidden = YES;
            self.nativeAdView.hidden = YES;
            self.mobfoxVideoAd.hidden = YES;
            
            break;
            
        case 1:
            self.mobfoxAd.hidden= YES;
            self.mobfoxInterAd.ad.hidden = NO;
            self.nativeAdView.hidden = YES;
            self.mobfoxVideoAd.hidden = YES;
            
            break;
            
        case 2:
            self.mobfoxAd.hidden= YES;
            self.mobfoxInterAd.ad.hidden = YES;
            self.nativeAdView.hidden = NO;
            self.mobfoxVideoAd.hidden = YES;
            
            break;
            
        case 3:
            self.mobfoxAd.hidden= YES;
            self.mobfoxInterAd.ad.hidden = YES;
            self.nativeAdView.hidden = YES;
            self.mobfoxVideoAd.hidden = NO;
            
            break;
            
        default:
            break;
    }
    
}

- (NSString *)adTitle:(NSIndexPath *)indexPath {
    
    switch (indexPath.item) {
        case 0:
            return @"Banner";
            break;
        case 1:
            return @"Interstitial";
            break;
        case 2:
            return @"Native";
            break;
        case 3:
            return @"Video";
            break;
            
        default:
            return @"";
            break;
    }
}

- (UIImage *)adImage:(NSIndexPath *)indexPath {
    
    switch (indexPath.item) {
        case 0:
            return [UIImage imageNamed:@"test_banner.png"];
            break;
        case 1:
            return [UIImage imageNamed:@"test_interstitial.png"];
            break;
        case 2:
            return [UIImage imageNamed:@"test_native.png"];
            break;
        case 3:
            return [UIImage imageNamed:@"test_video.png"];
            break;
            
        default:
            return nil;
            break;
    }
}

- (void)handleGesture:(UIGestureRecognizer *)gestureRecognizer {
    
    [[UIApplication sharedApplication] openURL:self.clickURL];
    
}

- (void)initVideoAd {
    
    if (self.mobfoxVideoAd == nil) {
        
        self.mobfoxVideoAd = [[MobFoxAd alloc] init:MOBFOX_HASH_VIDEO withFrame:self.adVideoRect];
        self.mobfoxVideoAd.delegate = self;
        self.mobfoxVideoAd.type = @"video";
        
        [self.view addSubview:self.mobfoxVideoAd];
    }
    
}

- (void)pauseAdRefresh {
    
    if (AD_REFRESH > 0) {
        
        self.mobfoxAd.refresh = [NSNumber numberWithInt:0];
        [self.mobfoxAd loadAd];
        [self.mobfoxAd removeFromSuperview];
    }
}

- (void)resumeAdRefresh {
    
    if (AD_REFRESH > 0) {
        
        [self.view addSubview:self.mobfoxAd];
        self.mobfoxAd.refresh = [NSNumber numberWithInt:AD_REFRESH];
        [self.mobfoxAd loadAd];
        
    } else {
        
        self.mobfoxAd.refresh = [NSNumber numberWithInt:AD_REFRESH];
        [self.mobfoxAd loadAd];
    }
}

- (void)removeVideoAd {
    
    [self.mobfoxVideoAd stopPlayback];
    self.mobfoxVideoAd = nil;
    
}

- (void)presentViewController {
    
    NativeAdViewController *nativeVC = [[NativeAdViewController alloc] init];
    [self presentViewController:nativeVC animated:YES completion:nil];
    
}

-(void)nativeAdWillPresentModalForCollectionViewAdPlacer:(MPCollectionViewAdPlacer *)placer{
    NSLog(@">> first");
}


-(void)nativeAdDidDismissModalForCollectionViewAdPlacer:(MPCollectionViewAdPlacer *)placer{
    NSLog(@">> second");
}


-(void)nativeAdWillLeaveApplicationFromCollectionViewAdPlacer:(MPCollectionViewAdPlacer *)placer{
    NSLog(@">> third");
}

@end



