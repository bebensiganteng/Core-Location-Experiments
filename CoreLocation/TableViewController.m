//
//  TableViewController.m
//  CoreLocation
//
//  Created by Rahmat Hidayat on 2014/07/14.
//  Copyright (c) 2014年 Rahmat Hidayat. All rights reserved.
//

#import "TableViewController.h"
#import "MapViewController.h"

@interface TableViewController ()

@end

@implementation TableViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self initTextField];
    
    self.btnAdd.adjustsImageWhenHighlighted     = NO;
    self.btnAdd.adjustsImageWhenDisabled        = NO;

    self.btnCurr.adjustsImageWhenHighlighted    = NO;
    self.btnCurr.adjustsImageWhenDisabled       = NO;
    
    clManager           = [CoreLocationManager sharedLocationManager];
    clManager.delegate  = self;
    
}

#pragma mark - Observer

- (void)initObserver
{
    [clManager addObserver:self forKeyPath:@"beaconDistance" options:(NSKeyValueObservingOptionNew | NSKeyValueObservingOptionInitial) context:NULL];
    [clManager addObserver:self forKeyPath:@"sTimeStamp" options:(NSKeyValueObservingOptionNew | NSKeyValueObservingOptionInitial) context:NULL];
    [clManager addObserver:self forKeyPath:@"sAccuracy" options:(NSKeyValueObservingOptionNew | NSKeyValueObservingOptionInitial) context:NULL];
    [clManager addObserver:self forKeyPath:@"sRSSI" options:(NSKeyValueObservingOptionNew | NSKeyValueObservingOptionInitial) context:NULL];
    [clManager addObserver:self forKeyPath:@"sMajor" options:(NSKeyValueObservingOptionNew | NSKeyValueObservingOptionInitial) context:NULL];
    [clManager addObserver:self forKeyPath:@"sMinor" options:(NSKeyValueObservingOptionNew | NSKeyValueObservingOptionInitial) context:NULL];
    [clManager addObserver:self forKeyPath:@"sState" options:(NSKeyValueObservingOptionNew | NSKeyValueObservingOptionInitial) context:NULL];
    
}

- (void)dealloc
{
    [clManager removeObserver:self forKeyPath:@"beaconDistance"];
    [clManager removeObserver:self forKeyPath:@"sTimeStamp"];
    [clManager removeObserver:self forKeyPath:@"sAccuracy"];
    [clManager removeObserver:self forKeyPath:@"sRSSI"];
    [clManager removeObserver:self forKeyPath:@"sMajor"];
    [clManager removeObserver:self forKeyPath:@"sMinor"];
    [clManager removeObserver:self forKeyPath:@"sState"];
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{

    if (object == clManager) {
        
        if([keyPath isEqualToString:@"beaconDistance"])
        {
            NSString *newValue = (NSString *)[change objectForKey:NSKeyValueChangeNewKey];
            
            labelLocStatus.text = newValue;
        }
        
        // check whether the beacon is still running
        if([keyPath isEqualToString:@"sTimeStamp"])
        {
            NSString *newValue = (NSString *)[change objectForKey:NSKeyValueChangeNewKey];
            
            labelTimeStamp.text = newValue;
        }
        
        if([keyPath isEqualToString:@"sAccuracy"])
        {
            NSString *newValue = (NSString *)[change objectForKey:NSKeyValueChangeNewKey];
            
            labelAccuracy.text = newValue;
        }
        
        if([keyPath isEqualToString:@"sRSSI"])
        {
            NSString *newValue = (NSString *)[change objectForKey:NSKeyValueChangeNewKey];
            
            labelRSSI.text = newValue;
        }
        
        if([keyPath isEqualToString:@"sMajor"])
        {
            NSString *newValue = (NSString *)[change objectForKey:NSKeyValueChangeNewKey];
            
            labelMajor.text = newValue;
        }
        
        if([keyPath isEqualToString:@"sMinor"])
        {
            NSString *newValue = (NSString *)[change objectForKey:NSKeyValueChangeNewKey];
            
            labelMinor.text = newValue;
        }
        
        if([keyPath isEqualToString:@"sState"])
        {
            NSString *newValue = (NSString *)[change objectForKey:NSKeyValueChangeNewKey];
            
            labelState.text = newValue;
        }
    }
}

- (IBAction)btnAdd:(id)sender {
    
    // TODO: this is not elegant
    static BOOL isStarted = NO;
    
    UIButton *button = (UIButton *)sender;
    
    // stops everything
    if ([button.currentTitle isEqualToString:@"Stop"]) {
        [button setTitle:@"Start" forState:UIControlStateNormal];
        [clManager stopCoreLocation];
        return;
    }
    
    BOOL check = YES;
    
    NSString *sName     = tfName.text;
    NSString *sUUID     = tfUUID.text;
    
    // check textField
    check = [self checkTextField:tfName inputUsers:@"Name"];
    check = [self checkTextField:tfUUID inputUsers:@"UUID"];
    check = [self checkTextField:tfLat inputUsers:@"Latitude"];
    check = [self checkTextField:tfLong inputUsers:@"Longitude"];
    check = [self checkTextField:tfRadius inputUsers:@"Radius"];
    
    NSInteger numberOfMatches = [uuidRegex numberOfMatchesInString:sUUID
                                                           options:kNilOptions
                                                            range:NSMakeRange(0, sUUID.length)];
    
    if (numberOfMatches > 0 && check)
    {

        if (!isStarted) {
            
            [clManager setupLocationManager];
            
            // TODO: maybe is better to use delegate
            [self initObserver];
            
            isStarted = YES;
            
        }

        CLLocationDistance dist     = [tfRadius.text doubleValue];
        
        //26.189948,-7.558594
        CLLocationDegrees latitude  = [tfLat.text doubleValue];
        CLLocationDegrees longitude = [tfLong.text doubleValue];
        CLLocationCoordinate2D pos  = CLLocationCoordinate2DMake(latitude, longitude);
        
        NSUUID *uuid = [[NSUUID alloc] initWithUUIDString:sUUID];

        [clManager registerBeaconRegionWithUUID:uuid identifier:sName];
        [clManager registerGeoFence:pos locationDistance:dist];
        
        if ([clManager startCoreLocation]) {
            [button setTitle:@"Stop" forState:UIControlStateNormal];
        }
        
        
    }
}

#pragma mark - Text Input

- (void) initTextField
{
    // Name TF
    [tfName addTarget:self action:@selector(tfDidBegin:) forControlEvents:UIControlEventEditingDidBegin];
    
    [tfName addTarget:self action:@selector(tfNameDidEnd:) forControlEvents:UIControlEventEditingDidEnd];
    
    // UUID TF
    [tfUUID addTarget:self action:@selector(tfDidBegin:) forControlEvents:UIControlEventEditingDidBegin];
    
    [tfUUID addTarget:self action:@selector(tfUUIDDidEnd:) forControlEvents:UIControlEventEditingDidEnd];

    // Lat
    [tfLat addTarget:self action:@selector(tfDidBegin:) forControlEvents:UIControlEventEditingDidBegin];
    
    [tfLat addTarget:self action:@selector(tfLatEnd:) forControlEvents:UIControlEventEditingDidEnd];
    
    // Long
    [tfLong addTarget:self action:@selector(tfDidBegin:) forControlEvents:UIControlEventEditingDidBegin];

    [tfLong addTarget:self action:@selector(tfLongEnd:) forControlEvents:UIControlEventEditingDidEnd];
    
    NSString *uuidPatternString = @"^[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}$";
    
    uuidRegex = [NSRegularExpression regularExpressionWithPattern:uuidPatternString
                                                               options:NSRegularExpressionCaseInsensitive
                                                                 error:nil];
    
    
    // Default value;
    tfName.text     = @"com.bebensiganteng.beacon";
    tfUUID.text     = [NSString stringWithFormat:@"D57092AC-DFAA-446C-8EF3-C81AA22815B5"];
    
    // test
    //34.626165 135.521694
    tfLat.text      = @"34.626165";
    tfLong.text     = @"135.521694";
    tfRadius.text   = @"20";
}

- (void)tfDidBegin:(UITextField *)textField
{
    textField.textColor = [UIColor blackColor];
    textField.text = @"";
}

- (void)tfNameDidEnd:(UITextField *)textField
{
    if (textField.text.length < 1) {
        textField.text = @"Name";
    }
}

- (void)tfUUIDDidEnd:(UITextField *)textField
{
    if (textField.text.length < 1) {
        textField.text = @"UUID";
    }
}

- (void)tfLatEnd:(UITextField *)textField
{
    if (textField.text.length < 1) {
        textField.text = @"Latitude";
    }
}

- (void)tfLongEnd:(UITextField *)textField
{
    if (textField.text.length < 1) {
        textField.text = @"Longitude";
    }
}


#pragma mark - Utils

-(void) showMessage:(NSString *) message
{
    UIAlertView *alertView = [[UIAlertView alloc]
                              initWithTitle:@"iBeacon"
                              message:message
                              delegate:self
                              cancelButtonTitle:@"Close"
                              otherButtonTitles:Nil, nil];
    
    alertView.alertViewStyle = UIAlertViewStyleDefault;
    
    [alertView show];
    
}

- (BOOL) checkTextField:(UITextField *)tf inputUsers:(NSString *)sInput
{
    if ([tf.text isEqual: sInput] || tf.text.length == 0) {
        
        tf.textColor = [UIColor redColor];

        return NO;
    }
    
    return YES;
}

#pragma mark - CoreLocation Delegates

- (void)locationError: (NSString*)msg {
    
    [self.btnAdd setTitle:@"Start" forState:UIControlStateNormal];
    [self showMessage:msg];

}

#pragma mark - Navigation

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    MapViewController *mapView = segue.destinationViewController;
    
    if ([mapView isKindOfClass:[MapViewController class]]) {
        /// do something here
    }

}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
