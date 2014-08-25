//
//  AppDelegate.m
//  Voter
//
//  Created by Martijn on 24/08/14.
//  Copyright (c) 2014 Martijn. All rights reserved.
//

#import "AppDelegate.h"

@interface AppDelegate ()
@property (nonatomic) UIButton *upVote;
@property (nonatomic) UIButton *downVote;
@property (nonatomic) CLBeaconRegion *beaconRegion;
@property (nonatomic) CLLocationManager *locationManager;
@property (nonatomic) NSInteger upvotes;
@property (nonatomic) NSInteger downvotes;

@property (nonatomic) UILabel *votesLabel;

@property (nonatomic) CLBeaconRegion *emitterRegion;
@property (nonatomic) CBPeripheralManager *peripheralManager;
@property (nonatomic) NSInteger minorToAdvertise;
@end

@implementation AppDelegate

- (void)peripheralManagerDidUpdateState:(CBPeripheralManager *)peripheralManager
{
    if(peripheralManager.state == CBPeripheralManagerStatePoweredOn) {
        // Now we want to emit the correct minor
        NSLog(@"Power on.");
        
        if(self.minorToAdvertise != -1) {
            NSLog(@"Advertise %ld", (long)self.minorToAdvertise);
            
            NSDictionary *peripheralDataDictionary = [self.emitterRegion peripheralDataWithMeasuredPower:nil];
            [self.peripheralManager startAdvertising:peripheralDataDictionary];
            
            self.minorToAdvertise = -1;
            
            [NSTimer scheduledTimerWithTimeInterval:5 target:self selector:@selector(_stopPeripheralManager) userInfo:self repeats:NO];
        }
    }
}

- (void)_stopPeripheralManager {
    if(self.peripheralManager) {
        NSLog(@"Stop advertising");
        
        [self.peripheralManager stopAdvertising];
        self.peripheralManager = nil;
    }
}

- (void)_createBeaconWithMinor:(NSUInteger)minor {
    [self _stopPeripheralManager];
    
    // uuid: E2C56DB5-DFFB-48D2-B060-D0F5A71096E1
    // major is random #
    // minor: 1 is upvote, 0 is downvote
    
    NSLog(@"Create beacon %ld", (long)minor);
    
    self.emitterRegion = [[CLBeaconRegion alloc] initWithProximityUUID:[[NSUUID alloc] initWithUUIDString:@"E2C56DB5-DFFB-48D2-B060-D0F5A71096E1"] major:rand() minor:minor identifier:@"Emitter Region"];
    
    NSDictionary *peripheralDataDictionary = [self.emitterRegion peripheralDataWithMeasuredPower:@100];
    if(peripheralDataDictionary) {
        self.minorToAdvertise = minor;
        self.peripheralManager = [[CBPeripheralManager alloc] initWithDelegate:self queue:dispatch_get_main_queue()];
        //[self.peripheralManager startAdvertising:peripheralDataDictionary];
        
        //[NSTimer scheduledTimerWithTimeInterval:5 target:self selector:@selector(_stopPeripheralManager) userInfo:self repeats:NO];
    }
    else {
        NSLog(@"Could not create emitter.");
    }
}

- (void)_upVote {

    [self _createBeaconWithMinor:1];
    
}

- (void)_downVote {
    
    [self _createBeaconWithMinor:0];
    
}

- (void)locationManager:(CLLocationManager *)manager
        didRangeBeacons:(NSArray *)beacons
               inRegion:(CLBeaconRegion *)region {
    for (int index = 0; index < [beacons count]; index++) {
        CLBeacon *b = [beacons objectAtIndex:index];
        
        NSLog(@"%@ %@ %@", b.proximityUUID, b.major, b.minor);
        
        //if([[b.proximityUUID UUIDString] isEqualToString:@"E2C56DB5-DFFB-48D2-B060-D0F5A71096E0"]) {
            
            NSInteger upvotes = [b.major integerValue];
            NSInteger downvotes = [b.minor integerValue];
            
            self.upvotes = upvotes;
            self.downvotes = downvotes;
            
            self.votesLabel.text = [NSString stringWithFormat:@"Up %d down %d", self.upvotes, self.downvotes];
        //}
    }
}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    
    NSUUID *proximityUUID = [[NSUUID alloc] initWithUUIDString:@"E2C56DB5-DFFB-48D2-B060-D0F5A71096E0"];
    
    self.beaconRegion = [[CLBeaconRegion alloc] initWithProximityUUID:proximityUUID identifier:@""];
    self.locationManager = [[CLLocationManager alloc] init];
    self.locationManager.delegate = self;
    [self.locationManager startRangingBeaconsInRegion:self.beaconRegion];
    
    UIViewController *viewController = [[UIViewController alloc] init];
    
    UIImageView *backgroundView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"Background.png"]];
    [viewController.view addSubview:backgroundView];
    
    self.votesLabel = [[UILabel alloc] initWithFrame:CGRectMake(0.0f, 100.0f, 320.0f, 40.0f)];
    self.votesLabel.textColor = [UIColor whiteColor];
    self.votesLabel.backgroundColor = [UIColor clearColor];
    self.votesLabel.textAlignment = NSTextAlignmentCenter;
    [viewController.view addSubview:self.votesLabel];
    
    self.upVote = [[UIButton alloc] initWithFrame:CGRectMake(0.0f, 200.0f, 160.0f, 80.0f)];
    [self.upVote setTitle:@"Upvote!" forState:UIControlStateNormal];
    [self.upVote addTarget:self action:@selector(_upVote) forControlEvents:UIControlEventTouchUpInside];
    [viewController.view addSubview:self.upVote];
    
    self.downVote = [[UIButton alloc] initWithFrame:CGRectMake(160.0f, 200.0f, 160.0f, 80.0f)];
    [self.downVote setTitle:@"Downvote!" forState:UIControlStateNormal];
    [self.downVote addTarget:self action:@selector(_downVote) forControlEvents:UIControlEventTouchUpInside];
    [viewController.view addSubview:self.downVote];
    
    self.window.rootViewController = viewController;
    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

@end
