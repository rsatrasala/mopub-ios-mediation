//
//  FacebookBannerCustomEvent.m
//  MoPub
//
//  Copyright (c) 2014 MoPub. All rights reserved.
//

#import <FBAudienceNetwork/FBAudienceNetwork.h>
#import "FacebookBannerCustomEvent.h"

#if __has_include("MoPub.h")
    #import "MPLogging.h"
#endif

@interface FacebookBannerCustomEvent () <FBAdViewDelegate>

@property (nonatomic, strong) FBAdView *fbAdView;
@property (nonatomic, copy) NSString *fbPlacementId;

@end

@implementation FacebookBannerCustomEvent

- (BOOL)enableAutomaticImpressionAndClickTracking
{
    return NO;
}

- (void)requestAdWithSize:(CGSize)size customEventInfo:(NSDictionary *)info
{
    [self requestAdWithSize:size customEventInfo:info adMarkup:nil];
}

- (void)requestAdWithSize:(CGSize)size customEventInfo:(NSDictionary *)info adMarkup:(NSString *)adMarkup
{
    /**
     * Facebook Banner ads can accept arbitrary widths for given heights of 50 and 90. We convert these sizes
     * to Facebook's constants and set the fbAdView's size to the intended size ("size" passed to this method).
     */
    self.fbPlacementId = [info objectForKey:@"placement_id"];
    FBAdSize fbAdSize;
    if (size.height == kFBAdSizeHeight250Rectangle.size.height) {
        fbAdSize = kFBAdSizeHeight250Rectangle;
    } else if (size.height == kFBAdSizeHeight90Banner.size.height) {
        fbAdSize = kFBAdSizeHeight90Banner;
    } else if (size.height == kFBAdSizeHeight50Banner.size.height) {
        fbAdSize = kFBAdSizeHeight50Banner;
    } else {
        NSError *error = [NSError errorWithCode:MOPUBErrorAdapterFailedToLoadAd localizedDescription:@"Banner size does not match with Facebook's standard banner width or height"];
        MPLogAdEvent([MPLogEvent adLoadFailedForAdapter:NSStringFromClass(self.class) error:error], self.fbPlacementId);
        [self.delegate bannerCustomEvent:self didFailToLoadAdWithError:error];
        return;
    }
    
    if (self.fbPlacementId == nil) {
        NSError *error = [NSError errorWithCode:MOPUBErrorAdapterFailedToLoadAd localizedDescription:@"Invalid Facebook placement ID"];
        MPLogAdEvent([MPLogEvent adLoadFailedForAdapter:NSStringFromClass(self.class) error:error], nil);
        [self.delegate bannerCustomEvent:self didFailToLoadAdWithError:error];

        return;
    }

    self.fbAdView = [[FBAdView alloc] initWithPlacementID:self.fbPlacementId
                                                   adSize:fbAdSize
                                       rootViewController:[self.delegate viewControllerForPresentingModalView]];
    self.fbAdView.delegate = self;

    if (!self.fbAdView) {
        NSError *error = [NSError errorWithCode:MOPUBErrorAdapterFailedToLoadAd localizedDescription:@"Facebook failed to load an ad"];
        [self.delegate bannerCustomEvent:self didFailToLoadAdWithError:error];
        MPLogAdEvent([MPLogEvent adLoadFailedForAdapter:NSStringFromClass(self.class) error:error], self.fbPlacementId);
        return;
    }

    /*
     * Manually resize the frame of the FBAdView due to a bug in the Facebook SDK that sets the ad's width
     * to the width of the device instead of the width of the container it's placed in.
     * (Confirmed in email with a FB Solutions Engineer)
     */
    CGRect fbAdFrame = self.fbAdView.frame;
    fbAdFrame.size = size;
    self.fbAdView.frame = fbAdFrame;
    [FBAdSettings setMediationService:[NSString stringWithFormat:@"MOPUB_%@", MP_SDK_VERSION]];
    
    // Load the advanced bid payload.
    if (adMarkup != nil) {
        MPLogInfo(@"Loading Facebook banner ad markup for Advanced Bidding");
        [self.fbAdView loadAdWithBidPayload:adMarkup];

        MPLogAdEvent([MPLogEvent adLoadAttemptForAdapter:NSStringFromClass(self.class) dspCreativeId:nil dspName:nil], self.fbPlacementId);
    }
    // Request a banner ad.
    else {
        MPLogInfo(@"Loading Facebook banner ad");
        [self.fbAdView loadAd];

        MPLogAdEvent([MPLogEvent adLoadAttemptForAdapter:NSStringFromClass(self.class) dspCreativeId:nil dspName:nil], self.fbPlacementId);
    }
}

- (void)dealloc
{
    self.fbAdView.delegate = nil;
}

#pragma mark FBAdViewDelegate methods

- (void)adView:(FBAdView *)adView didFailWithError:(NSError *)error
{
    MPLogAdEvent([MPLogEvent adLoadFailedForAdapter:NSStringFromClass(self.class) error:error], nil);

    [self.delegate bannerCustomEvent:self didFailToLoadAdWithError:error];
}

- (void)adViewDidLoad:(FBAdView *)adView
{
    MPLogAdEvent([MPLogEvent adLoadSuccessForAdapter:NSStringFromClass(self.class)], self.fbPlacementId);
    MPLogAdEvent([MPLogEvent adShowAttemptForAdapter:NSStringFromClass(self.class)], self.fbPlacementId);
    MPLogAdEvent([MPLogEvent adShowSuccessForAdapter:NSStringFromClass(self.class)], self.fbPlacementId);

    [self.delegate bannerCustomEvent:self didLoadAd:adView];
}

- (void)adViewWillLogImpression:(FBAdView *)adView
{
    MPLogInfo(@"Facebook banner ad did log impression");
    [self.delegate trackImpression];
}

- (void)adViewDidClick:(FBAdView *)adView
{
    MPLogAdEvent([MPLogEvent adTappedForAdapter:NSStringFromClass(self.class)], self.fbPlacementId);

    [self.delegate trackClick];
    [self.delegate bannerCustomEventWillBeginAction:self];
}

- (void)adViewDidFinishHandlingClick:(FBAdView *)adView
{
    MPLogInfo(@"Facebook banner ad did finish handling click");
    [self.delegate bannerCustomEventDidFinishAction:self];
}

- (UIViewController *)viewControllerForPresentingModalView
{
    return [self.delegate viewControllerForPresentingModalView];
}

@end
