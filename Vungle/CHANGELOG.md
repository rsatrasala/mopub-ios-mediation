## Changelog
  * 6.3.2.1
    * **Note**: This version is only compatible with the 5.5.0+ release of the MoPub SDK.
    * Add the `VungleAdapterConfiguration` class to: 
         * pre-initialize the Vungle SDK during MoPub SDK initialization process
         * store adapter and SDK versions for logging purpose
    * Streamline adapter logs via `MPLogAdEvent` to make debugging more efficient. For more details, check the [iOS Initialization guide](https://developers.mopub.com/docs/ios/initialization/) and [Writing Custom Events guide](https://developers.mopub.com/docs/ios/custom-events/).

  * 6.3.2.0
    * This version of the adapters has been certified with Vungle 6.3.2.

  * 6.2.0.2
    * Clean up remaining code pertaining to Vungle's placement IDs (`pids`) since it's no longer needed to initialize Vungle.

  * 6.2.0.1  
    * Update adapters to remove dependency on MPInstanceProvider
    * Update adapters to be compatible with MoPub iOS SDK framework

  * 6.2.0.0
    * This version of the adapters has been certified with Vungle 6.2.0.
    * General Data Protection Regulation (GDPR) update to support a way for publishers to determine GDPR applicability and to obtain/manage consent from users in European Economic Area, the United Kingdom, or Switzerland to serve personalize ads. Only applicable when integrated with MoPub version 5.0.0 and above

  * 5.4.0.1
    * This version of the adapters has been certified with Vungle 5.4.0.
    * Podspec version bumped in order to pin the network SDK version.

  * 5.4.0.0
    * This version of the adapters has been certified with Vungle 5.4.0.
    
  * 5.3.2.0
    * This version of the adapters has been certified with Vungle 5.3.2.

  * Initial Commit
  	* Adapters moved from [mopub-ios-sdk](https://github.com/mopub/mopub-ios-sdk) to [mopub-ios-mediation](https://github.com/mopub/mopub-ios-mediation/)
