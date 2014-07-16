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
    
    self.btnCurr.enabled = NO;
    
    // Default value;
    tfName.text     = @"com.bebensiganteng.beacon";
    tfUUID.text     = [NSString stringWithFormat:@"D57092AC-DFAA-446C-8EF3-C81AA22815B5"];
    tfLat.text      = @"34.679876";
    tfLong.text     = @"135.498181";
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
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
    
}

- (void)dealloc
{
    [clManager removeObserver:self forKeyPath:@"beaconDistance"];
    [clManager removeObserver:self forKeyPath:@"sTimeStamp"];
    [clManager removeObserver:self forKeyPath:@"sAccuracy"];
    [clManager removeObserver:self forKeyPath:@"sRSSI"];
    [clManager removeObserver:self forKeyPath:@"sMajor"];
    [clManager removeObserver:self forKeyPath:@"sMinor"];
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{

    if (object == clManager) {
        
        if([keyPath isEqualToString:@"beaconDistance"])
        {
            NSString *newValue = (NSString *)[change objectForKey:NSKeyValueChangeNewKey];
            
            labelLocStatus.text = newValue;
        }
        
        // check if beacon scanning still running
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
    }
}

- (IBAction)btnAdd:(id)sender {
    
    BOOL check = YES;
    
    NSString *sName     = tfName.text;
    NSString *sUUID     = tfUUID.text;
    NSString *sLat      = tfLat.text;
    NSString *sLong     = tfLong.text;
    
    NSInteger numberOfMatches = [uuidRegex numberOfMatchesInString:sUUID
                                options:kNilOptions
                                range:NSMakeRange(0, sUUID.length)];
    
    
    NSLog(@"btnAdd %ld", (long)numberOfMatches);
    
    if ([sName isEqual: @"Name"] || sName.length == 0) {
        tfName.textColor = [UIColor redColor];
        check = NO;
    }
    
    if ([sUUID isEqual: @"UUID"] || sUUID.length == 0) {
        tfUUID.textColor = [UIColor redColor];
        check = NO;
    }

    if ([sLat isEqual: @"Latitude"] || sUUID.length == 0) {
        tfLat.textColor = [UIColor redColor];
        check = NO;
    }
    
    if ([sLong isEqual: @"Longitude"] || sUUID.length == 0) {
        tfLong.textColor = [UIColor redColor];
        check = NO;
    }
    
    if (!check) return;
    
    if (numberOfMatches > 0)
    {
        NSUUID *uuid = [[NSUUID alloc] initWithUUIDString:sUUID];

        clManager = [CoreLocationManager sharedLocationManager];
        [clManager registerBeaconRegionWithUUID:uuid identifier:sName];
        
        CLLocationDegrees latitude  = [tfLat.text doubleValue];
        CLLocationDegrees longitude = [tfLong.text doubleValue];
        
        clManager.beaconPosition = CLLocationCoordinate2DMake(latitude, longitude);
        
        // maybe is better to use delegate
        [self initObserver];

        self.btnAdd.enabled     = NO;
        self.btnCurr.enabled    = YES;
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

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:<#@"reuseIdentifier"#> forIndexPath:indexPath];
    
    // Configure the cell...
    
    return cell;
}
*/

/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    } else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath
{
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/


#pragma mark - Navigation

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    MapViewController *mapView = segue.destinationViewController;
    
    if ([mapView isKindOfClass:[MapViewController class]]) {
        [clManager stopAll];
        [clManager startUpdatingLocation];
    }

}

@end
