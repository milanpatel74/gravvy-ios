//
//  GRVCameraViewController.m
//  Gravvy
//
//  Created by Nnoduka Eruchalu on 5/19/15.
//  Copyright (c) 2015 Nnoduka Eruchalu. All rights reserved.
//

#import "GRVCameraViewController.h"
#import "GRVCameraSlideUpView.h"
#import "GRVCameraSlideDownView.h"
#import "GRVConstants.h"
#import "SCRecorder.h"
#import "SCRecordSessionSegment.h"
#import "GRVRecorderManager.h"

/**
 * Countdown container view border radius
 */
static const CGFloat kCountdownContainerCornerRadius = 5.0f;

@interface GRVCameraViewController () <SCRecorderDelegate>

#pragma mark - Properties

#pragma mark Outlets
@property (weak, nonatomic) IBOutlet UIView *previewView;
@property (weak, nonatomic) IBOutlet UIView *separatorView;
@property (weak, nonatomic) IBOutlet UIView *actionsView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *minimumProgressIndicatorWidthLayoutConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *progressIndicatorWidthLayoutConstraint;

@property (weak, nonatomic) IBOutlet UIView *countdownBackgroundView;
@property (weak, nonatomic) IBOutlet UILabel *countdownLabel;
@property (weak, nonatomic) IBOutlet UIButton *flashButton;
@property (weak, nonatomic) IBOutlet UIButton *retakeButton;
@property (weak, nonatomic) IBOutlet UIButton *shootButton;

@property (strong, nonatomic) GRVCameraSlideUpView *slideUpView;
@property (strong, nonatomic) GRVCameraSlideDownView *slideDownView;
@property (strong, nonatomic) UIBarButtonItem *closeButton;
@property (strong, nonatomic) UIBarButtonItem *doneButton;

#pragma mark Public
// Readonly properties should be readwrite internally
@property (strong, nonatomic, readwrite) UIImage *previewImage;
@property (strong, nonatomic, readwrite) SCRecordSession *recordSession;

#pragma mark Private
/**
 * The duration of the recording, in seconds.
 */
@property (nonatomic) NSTimeInterval recordingDuration;

/**
 * Recorder
 */
@property (strong, nonatomic) SCRecorder *recorder;

/**
 * Communicate with the session and other session objects on this queue.
 */
@property (nonatomic) dispatch_queue_t sessionQueue;

@end


@implementation GRVCameraViewController

#pragma mark - Properties
- (void)setRecordingDuration:(NSTimeInterval)recordingDuration
{
    _recordingDuration = MIN(recordingDuration, kGRVClipMaximumDuration);;
    
    NSUInteger recordingTimeLeft = kGRVClipMaximumDuration - (NSUInteger)recordingDuration;
    self.countdownLabel.text = [NSString stringWithFormat:@"%lu", (unsigned long)recordingTimeLeft];
    
    self.progressIndicatorWidthLayoutConstraint.constant = self.view.frame.size.width *_recordingDuration/kGRVClipMaximumDuration;
    
    // Can only proceed to next page if recording duration has exceeded the
    // minimum
    self.doneButton.enabled = _recordingDuration >= kGRVClipMinimumDuration;
    
    if (recordingDuration == 0.0f) {
        self.retakeButton.hidden = YES;
    }
}

#pragma mark - Class Methods
+ (UINib *)nib
{
    return [UINib nibWithNibName:NSStringFromClass([GRVCameraViewController class])
                          bundle:[NSBundle mainBundle]];
}


#pragma mark - View Lifecycle
- (void)viewDidLoad
{
    // Load all subviews and setup outlets before calling superclass' viewDidLoad
    [[[self class] nib] instantiateWithOwner:self options:nil];
    [super viewDidLoad];
    
    // Style navigation bar so this looks respectable
    UINavigationBar *navigationBar = self.navigationController.navigationBar;
    navigationBar.barTintColor = kGRVCameraViewNavigationBarColor;
    
    // Set navigation bar items, close and done buttons
    self.closeButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemStop target:self action:@selector(cancel)];
    self.navigationItem.leftBarButtonItem = self.closeButton;
    
    self.doneButton = [[UIBarButtonItem alloc] initWithTitle:@"NEXT" style:UIBarButtonItemStylePlain target:self action:@selector(done:)];
    self.navigationItem.rightBarButtonItem = self.doneButton;
    
    // Configure countdown background view border radius
    self.countdownBackgroundView.layer.cornerRadius = kCountdownContainerCornerRadius;
    self.countdownBackgroundView.clipsToBounds = YES;
    
    // Configure sliding views that are used to reveal the preview view
    NSBundle *bundle = [NSBundle bundleForClass:[self class]];
    
    NSArray *slideUpNibViews = [bundle loadNibNamed:NSStringFromClass([GRVCameraSlideUpView class])
                                              owner:nil
                                            options:nil];
    self.slideUpView = [slideUpNibViews firstObject];
    
    NSArray *slideDownNibViews = [bundle loadNibNamed:NSStringFromClass([GRVCameraSlideDownView class])
                                              owner:nil
                                            options:nil];
    self.slideDownView = [slideDownNibViews firstObject];
    
    self.previewView.backgroundColor = [UIColor clearColor];
    
    // Set marker for minimum recording duration
    self.minimumProgressIndicatorWidthLayoutConstraint.constant = self.view.frame.size.width * kGRVClipMinimumDuration/kGRVClipMaximumDuration;
    
    // Initialize recording duration to update outlets
    self.recordingDuration = 0.0f;
    
    // In general it is not safe to mutate an AVCaptureSession or any of its
    // inputs, outputs, or connections from multiple threads at the same time.
    // Why not do all of this on the main queue?
    // -[AVCaptureSession startRunning] is a blocking call which can take a long
    // time. We dispatch session setup to the sessionQueue so that the main
    // queue isn't blocked (which keeps the UI responsive).
    dispatch_queue_t sessionQueue = dispatch_queue_create("GRVCamera session queue", DISPATCH_QUEUE_SERIAL);
    self.sessionQueue = sessionQueue;
    
    [self setupRecorder];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];

    // Prepare to animate the reveal of the capture view by showing the
    // separator of the sliding views
    self.separatorView.hidden = NO;
    
    // Hide action buttons and disable buttons not in action view till we are
    // done revealing the capture view
    self.actionsView.hidden = YES;
    self.shootButton.enabled = NO;
    self.retakeButton.enabled = NO;
    
    // Prepare record session
    [self prepareSession];
    
    // Could call -[setupVCOnAppear] here but that would make the reveal preview
    // animation appear as an odd flicker. So simply start running the recorder
    // here and reveal Camera Preview when the view indeed appears
    // Start running record session
    [self startRunningRecorder];
    
    // Register observers
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(appDidEnterBackground)
                                                 name:UIApplicationDidEnterBackgroundNotification
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(appWillEnterForeground)
                                                 name:UIApplicationWillEnterForegroundNotification
                                               object:nil];
    // register observers
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(mediaServicesWereReset:)
                                                 name:AVAudioSessionMediaServicesWereResetNotification
                                               object:nil];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [self revealCameraPreview];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [self cleanupVCOnDisappear];
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    
    // remove observers
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:UIApplicationDidEnterBackgroundNotification
                                                  object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:UIApplicationWillEnterForegroundNotification
                                                  object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:AVAudioSessionMediaServicesWereResetNotification
                                                  object:nil];
}


#pragma mark - View Layout
- (void)viewDidLayoutSubviews
{
    [super viewDidLayoutSubviews];
    [self.recorder previewViewFrameChanged];
}


#pragma mark - Instance Methods
#pragma mark Abstract
- (void)processCompletedSession:(SCRecordSession *)recordSession
               withPreviewImage:(UIImage *)previewImage
{
    // Abstract
}

#pragma mark Private
/**
 * Setup recorder
 */
- (void)setupRecorder
{
    self.recorder = [GRVRecorderManager recorderWithDelegate:self
                                              andPreviewView:self.previewView];
}

/**
 * Start running the already setup recorder @property
 */
- (void)startRunningRecorder
{
    dispatch_async(self.sessionQueue, ^{
        [self.recorder startRunning];
    });
}

/**
 * Prepare recording session if this hasn't already been done
 */
- (void)prepareSession
{
    if (!self.recorder.session) {
        self.recordSession = [SCRecordSession recordSession];
        self.recordSession.fileType = AVFileTypeMPEG4;
        
        self.recorder.session = self.recordSession;
        
        // Clear preview image now as it will be setup with the first buffer in
        // the newrecord session
        self.previewImage = nil;
    }
    
    [self updateRecordingDuration];
}

/**
 * Recording is done, process and possibly upload this session
 */
- (void)processSession:(SCRecordSession *)recordSession
{
    self.recordSession = recordSession;
    // Ensure there's a preview image
    if (!self.previewImage) {
        SCRecordSessionSegment *firstSegment = [recordSession.segments firstObject];
        self.previewImage = firstSegment.thumbnail;
    }
    
    [self processCompletedSession:recordSession
                 withPreviewImage:self.previewImage];
}


/**
 * Update recording duration from the recording's session
 */
- (void)updateRecordingDuration
{
    if (self.recorder.session) {
        self.recordingDuration = CMTimeGetSeconds(self.recorder.session.duration);
    } else {
        self.recordingDuration = 0;
    }
}

#pragma mark Appearance/Disappearance Setup
/**
 * VC's view is appearing. Reveal capture view and start the recorder.
 */
- (void)setupVCOnAppear
{
    [self startRunningRecorder];
    [self revealCameraPreview];
}

/**
 * Reveal camera preview view
 */
- (void)revealCameraPreview
{
    // Remove separator view as we start revealing capture view
    self.separatorView.hidden = YES;
    
    // Reveal capture view
    [GRVCameraSlideView hideSlideUpView:self.slideUpView
                          slideDownView:self.slideDownView
                                 atView:self.previewView
                             completion:^{
                                 // show action buttons and enable other buttons
                                 self.actionsView.hidden = NO;
                                 self.shootButton.enabled = YES;
                                 self.retakeButton.enabled = YES;
                                 
                                 // Show retake button if there's already a
                                 // recording to edit
                                 self.retakeButton.hidden = self.recordingDuration <= 0.0f;
                             }];
}

/**
 * VC's view is disappearing. Cover capture view and stop the recorder
 */
- (void)cleanupVCOnDisappear
{
    dispatch_async(self.sessionQueue, ^{
        [self.recorder stopRunning];
    });
    
    
    // Cover capture view
    [GRVCameraSlideView showSlideUpView:self.slideUpView slideDownView:self.slideDownView atView:self.previewView completion:^{
        // Show separator view as we finish covering capture view
        self.separatorView.hidden = NO;
        
        // Hide action buttons and disable other buttons
        self.actionsView.hidden = YES;
        self.shootButton.enabled = NO;
        self.retakeButton.enabled = NO;
    }];
}


#pragma mark - Target/Action Methods
- (IBAction)flipCamera:(UIButton *)sender
{
    [self.recorder switchCaptureDevices];
    
    // Flash goes off when camera device is switched
    //self.recorder.flashMode = SCFlashModeOff;
    //[self.flashButton setImage:[UIImage imageNamed:@"flashOff"] forState:UIControlStateNormal];
}

- (IBAction)toggleFlash:(UIButton *)sender
{
    // Don't bother if the capture device doesn't have flash
    if (!self.recorder.deviceHasFlash) {
        return;
    }
    
    NSString *flashImage = nil;
    switch (self.recorder.flashMode) {
        case SCFlashModeOff:
            flashImage = @"flashOn";
            self.recorder.flashMode = SCFlashModeLight;
            break;
        case SCFlashModeLight:
            flashImage = @"flashOff";
            self.recorder.flashMode = SCFlashModeOff;
            break;
        default:
            break;
    }
    [self.flashButton setImage:[UIImage imageNamed:flashImage] forState:UIControlStateNormal];
}

/**
 * Started holding down shoot button
 */
- (IBAction)startRecording:(UIButton *)sender
{
    // Begin appending video/audio buffers to the session
    [self.recorder record];
}

/**
 * Let go of shoot button
 */
- (IBAction)pauseRecording:(UIButton *)sender
{
    // Stop appending video/audio buffers to the session
    [self.recorder pause];
    
    // Can only retake recording if recording duration is > 0
    self.retakeButton.hidden = self.recordingDuration <= 0.0f;
}

/**
 * Retake button tapped
 */
- (IBAction)retakeRecording:(UIButton *)sender
{
    SCRecordSession *recordSession = self.recorder.session;
    if (recordSession) {
        self.recorder.session = nil;
        [recordSession cancelSession:nil];
    }
    
    [self prepareSession];
    
    // Hide retake button
    self.retakeButton.hidden = YES;
}


- (IBAction)cancel
{
    // Stop the capture session in the background so that we don't get
    // a weird hang as the view is dismissed
    // To ensure this works properly, deallocate the recorder @property now
    // so that the cleanupVCOnDisappear method works without a hitch
    SCRecorder *recorder = self.recorder;
    self.recorder = nil;
    
    [self.presentingViewController dismissViewControllerAnimated:YES completion:^{
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_LOW, 0), ^{
            dispatch_async(dispatch_get_main_queue(), ^{
                [recorder stopRunning];
            });
        });
    }];
}

- (IBAction)done:(UIBarButtonItem *)sender
{
    [self.recorder pause:^{
        [self processSession:self.recorder.session];
    }];
}


#pragma mark - SCRecorderDelegate
- (void)recorder:(SCRecorder *)recorder didInitializeAudioInSession:(SCRecordSession *)recordSession error:(NSError *)error {
    if (error) {
        NSLog(@"Failed to initialize audio in record session: %@", error.localizedDescription);
    } else {
        NSLog(@"Initialized audio in record session");
    }
}

- (void)recorder:(SCRecorder *)recorder didInitializeVideoInSession:(SCRecordSession *)recordSession error:(NSError *)error {
    if (error) {
        NSLog(@"Failed to initialize video in record session: %@", error.localizedDescription);
    } else {
        NSLog(@"Initialized video in record session");
    }
}

- (void)recorder:(SCRecorder *)recorder didBeginSegmentInSession:(SCRecordSession *)recordSession error:(NSError *)error {
    NSLog(@"Began record segment: %@", error);
}

- (void)recorder:(SCRecorder *)recorder didCompleteSegment:(SCRecordSessionSegment *)segment inSession:(SCRecordSession *)recordSession error:(NSError *)error {
    NSLog(@"Completed record segment at %@: %@ (frameRate: %f)", segment.url, error, segment.frameRate);
}

- (void)recorder:(SCRecorder *)recorder didAppendVideoSampleBufferInSession:(SCRecordSession *)session
{
    [self updateRecordingDuration];
    if (!self.previewImage) {
        self.previewImage = [recorder snapshotOfLastVideoBuffer];
    }
}

- (void)recorder:(SCRecorder *)recorder didCompleteSession:(SCRecordSession *)recordSession
{
    NSLog(@"didCompleteSession:");
    [self processSession:recordSession];
}


#pragma mark - Notification Observer Methods
/**
 * App entering background, so stop the player
 */
- (void)appDidEnterBackground
{
    [self cleanupVCOnDisappear];
}

/**
 * App entering foreground, so setup player
 */
- (void)appWillEnterForeground
{
    [self setupVCOnAppear];
}

/**
 * Media services were reset so reinitialize player
 */
- (void)mediaServicesWereReset:(NSNotification *)aNotification
{
    // Setup recorder
    [self setupRecorder];
    // Prepare record session
    [self prepareSession];
    // Finally present camera view
    [self setupVCOnAppear];
}


@end
