//
//  GRVConstants.m
//  Gravvy
//
//  Created by Nnoduka Eruchalu on 5/9/15.
//  Copyright (c) 2015 Nnoduka Eruchalu. All rights reserved.
//

#import "GRVConstants.h"

// -----------------------------------------------------------------------------
// Fonts
// -----------------------------------------------------------------------------
NSString *const kGRVThemeFontRegular    = @"HelveticaNeue-Light";
NSString *const kGRVThemeFontBold       = @"HelveticaNeue-Bold";

// -----------------------------------------------------------------------------
// Styling
// -----------------------------------------------------------------------------
const float kGRVButtonCornerRadius      = 5.0;

// -----------------------------------------------------------------------------
// App Configuration info.
// -----------------------------------------------------------------------------
#if DEBUG
const BOOL kGRVReachabilityRequired     = NO;
#else
const BOOL kGRVReachabilityRequired     = YES;
#endif


// -----------------------------------------------------------------------------
// Model Configuration info.
// -----------------------------------------------------------------------------
const NSUInteger kGRVCacheMemoryCapacity    = 2 * 1024 * 1024;      // 2mb
const NSUInteger kGRVCacheDiskCapacity      = 256 * 1024 * 1024;    // 256mb

// -----------------------------------------------------------------------------
// Video Configuration info.
// -----------------------------------------------------------------------------
const NSTimeInterval kGRVClipMaximumDuration = 6.0;
const NSTimeInterval kGRVClipMinimumDuration = 1.0;
const float kGRVVideoSizeWidth = 480.0;
const float kGRVVideoSizeHeight = 480.0;
const float kGRVVideoPhotoCompressionQuality = 0.4;


// -----------------------------------------------------------------------------
// PopTip Configuration info.
// -----------------------------------------------------------------------------
const NSTimeInterval kGRVPopTipMaximumDuration = 10.0;
const NSTimeInterval kGRVPopTipMinimumDuration = 5.0;


// -----------------------------------------------------------------------------
// Model Field Settings (Max Lengths)
// -----------------------------------------------------------------------------
const NSUInteger kGRVUserFullNameMaxLength  = 25;
const NSUInteger kGRVVideoTitleMaxLength    = 65;


// -----------------------------------------------------------------------------
// Model Field Constants
// -----------------------------------------------------------------------------
const NSInteger kGRVVideoOrderNew           = -2;
const NSInteger kGRVVideoOrderAddedClip     = -1;

// -----------------------------------------------------------------------------
// HTTP Connection info.
// -----------------------------------------------------------------------------
#if TARGET_IPHONE_SIMULATOR
// An IP address won't work on the simulator.
NSString *const kGRVHTTPBaseURL         = @"http://localhost:8000/api/v1/";

#else
    #if DEBUG
    NSString *const kGRVHTTPBaseURL     = @"http://192.168.1.3:8000/api/v1/";
    #else
    NSString *const kGRVHTTPBaseURL     = @"http://gravvy.nnoduka.com/api/v1/";
    #endif

#endif

NSString *const kGRVRESTListResultsKey  = @"results";


// -----------------------------------------------------------------------------
// REST API HTTP relative paths (observe no leading slash)
// -----------------------------------------------------------------------------
NSString *const kGRVRESTUsers                   = @"users/";
NSString *const kGRVRESTAccountActivateAccount  = @"account/activate/";
NSString *const kGRVRESTAccountObtainAuthToken  = @"account/auth/";
NSString *const kGRVRESTUser                    = @"user/";
NSString *const kGRVRESTPushRegister            = @"push/apns/";
NSString *const kGRVRESTFeedbacks               = @"feedbacks/";
NSString *const kGRVRESTUserActivities          = @"user/activities/";
NSString *const kGRVRESTUserVideos              = @"user/videos/";
NSString *const kGRVRESTUserRecentContacts      = @"user/recentcontacts/";
NSString *const kGRVRESTVideos                  = @"videos/";
NSString *const kGRVRESTVideoMembers            = @"users/";
NSString *const kGRVRESTVideoClips              = @"clips/";
NSString *const kGRVRESTVideoLikes              = @"likes/";
NSString *const kGRVRESTVideoPlay               = @"play/";
NSString *const kGRVRESTVideoLike               = @"like/";
NSString *const kGRVRESTVideoClearNotifications = @"clearnotifications/";

// -----------------------------------------------------------------------------
// REST API Object Keys
// -----------------------------------------------------------------------------
// Account object
NSString *const kGRVRESTAccountVerificationCodeKey  = @"verification_code";
NSString *const kGRVRESTAccountTokenKey             = @"token";

// User object
NSString *const kGRVRESTUserAvatarKey               = @"avatar";
NSString *const kGRVRESTUserAvatarThumbnailKey      = @"avatar_thumbnail";
NSString *const kGRVRESTUserFullNameKey             = @"full_name";
NSString *const kGRVRESTUserUpdatedAtKey            = @"updated_at";
NSString *const kGRVRESTUserPasswordKey             = @"password";
NSString *const kGRVRESTUserPhoneNumberKey          = @"phone_number";

// Push registration object
NSString *const kGRVRESTPushRegistrationIdKey       = @"registration_id";

// Feedback object
NSString *const kGRVRESTFeedbackBodyKey             = @"body";

// Video object
NSString *const kGRVRESTVideoClipsKey               = @"clips";
NSString *const kGRVRESTVideoCreatedAtKey           = @"created_at";
NSString *const kGRVRESTVideoHashKeyKey             = @"hash_key";
NSString *const kGRVRESTVideoLeadClipKey            = @"lead_clip";
NSString *const kGRVRESTVideoLikedKey               = @"liked";
NSString *const kGRVRESTVideoLikesCountKey          = @"likes_count";
NSString *const kGRVRESTVideoMembershipKey          = @"membership_status";
NSString *const kGRVRESTVideoOwnerKey               = @"owner";
NSString *const kGRVRESTVideoPhotoSmallThumbnailKey = @"photo_small_thumbnail";
NSString *const kGRVRESTVideoPhotoThumbnailKey      = @"photo_thumbnail";
NSString *const kGRVRESTVideoPlaysCountKey          = @"plays_count";
NSString *const kGRVRESTVideoScoreKey               = @"score";
NSString *const kGRVRESTVideoTitleKey               = @"title";
NSString *const kGRVRESTVideoUnseenClipsCountKey    = @"new_clips_count";
NSString *const kGRVRESTVideoUnseenLikesCountKey    = @"new_likes_count";
NSString *const kGRVRESTVideoUpdatedAtKey           = @"updated_at";
NSString *const kGRVRESTVideoUsersKey               = @"users";

// Clip object
NSString *const kGRVRESTClipDurationKey             = @"duration";
NSString *const kGRVRESTClipIdentifierKey           = @"id";
NSString *const kGRVRESTClipMp4Key                  = @"mp4";
NSString *const kGRVRESTClipOrderKey                = @"order";
NSString *const kGRVRESTClipOwnerKey                = @"owner";
NSString *const kGRVRESTClipPhotoKey                = @"photo";
NSString *const kGRVRESTClipPhotoThumbnailKey       = @"photo_thumbnail";
NSString *const kGRVRESTClipUpdatedAtKey            = @"updated_at";

// Video Member object
NSString *const kGRVRESTMemberCreatedAtKey          = @"created_at";
NSString *const kGRVRESTMemberIdentifierKey         = @"user.phone_number";
NSString *const kGRVRESTMemberStatusKey             = @"status";
NSString *const kGRVRESTMemberUpdatedAtKey          = @"updated_at";
NSString *const kGRVRESTMemberUserKey               = @"user";

// Activity object
NSString *const kGRVRESTActivityActorKey            = @"actor";
NSString *const kGRVRESTActivityCreatedAtKey        = @"created_at";
NSString *const kGRVRESTActivityIdentifierKey       = @"id";
NSString *const kGRVRESTActivityObjectKey           = @"object";
NSString *const kGRVRESTActivityTargetKey           = @"target";
NSString *const kGRVRESTActivityVerbKey             = @"verb";


// -----------------------------------------------------------------------------
// User Credentials
// -----------------------------------------------------------------------------
NSString *const kGRVLoginKeychainIdentifier     = @"GravvyLoginData";
NSString *const kGRVUnknownRegionCode           = @"ZZ";


// -----------------------------------------------------------------------------
// Application Settings
// -----------------------------------------------------------------------------
NSString *const kGRVSettingsSounds              = @"kGRVSettingsSounds";
NSString *const kGRVSettingsFullName            = @"kGRVSettingsFullName";
NSString *const kGRVSettingsVideoCreationTip    = @"kGRVSettingsVideoCreationTip";
NSString *const kGRVSettingsClipAdditionTip     = @"kGRVSettingsClipAdditionTip";
NSString *const kGRVSettingsVideoFastForwardTip = @"kGRVSettingsVideoFastForwardTip";


// -----------------------------------------------------------------------------
// Notifications
// -----------------------------------------------------------------------------
NSString *const kGRVMOCAvailableNotification        = @"kGRVMOCAvailableNotification";
NSString *const kGRVMOCDeletedNotification          = @"kGRVMOCDeletedNotification";
NSString *const kGRVHTTPAuthenticationNotification  = @"kGRVHTTPAuthenticationNotification";
NSString *const kGRVContactsRefreshedNotification   = @"kGRVContactsRefreshedNotification";


// EOF