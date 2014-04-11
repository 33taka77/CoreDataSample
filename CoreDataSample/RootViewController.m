//
//  RootViewController.m
//  CoreDataSample
//
//  Created by Aizawa Takashi on 2014/04/10.
//  Copyright (c) 2014年 Aizawa Takashi. All rights reserved.
//

#import "RootViewController.h"
#import "Event.h"

@interface RootViewController ()

@end

@implementation RootViewController

- (CLLocationManager *)LocationManager
{
    if (self.locationManager != nil) {
        return self.locationManager;
    }
    self.locationManager = [[CLLocationManager alloc] init];
    self.locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters;
    self.locationManager.delegate = self;
    return self.locationManager;
}

- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations
{
    self.addButton.enabled = YES;
}

- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error
{
    self.addButton.enabled = NO;
}

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    self.navigationItem.leftBarButtonItem = self.editButtonItem;
    self.title = @"Lacation";
    self.addButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(addEvent)];
    self.addButton.enabled = NO;
    self.navigationItem.rightBarButtonItem = self.addButton;
    
    [[self LocationManager] startUpdatingLocation];
    //self.eventsArray = [[NSMutableArray alloc] init];
    
    NSFetchRequest* request = [[NSFetchRequest alloc] init];
    NSEntityDescription* entity = [NSEntityDescription entityForName:@"Event" inManagedObjectContext:self.managedObjectContext];
    [request setEntity:entity];
    NSSortDescriptor* sortDesc = [[NSSortDescriptor alloc] initWithKey:@"creationDate" ascending:NO];
    NSArray* sortDescripters = [[NSArray alloc] initWithObjects:sortDesc, nil];
    [request setSortDescriptors:sortDescripters];
    NSError* error = nil;
    NSMutableArray* resultArray = [[self.managedObjectContext executeFetchRequest:request error:&error] mutableCopy];
    if( resultArray == nil ){
        NSLog(@"Fetch error: %@",error);
        return;
    }
    //[self.eventsArray setArray:resultArray];
    //[self setEventsArray:resultArray];
    self.eventsArray = resultArray;
}

- (void)addEvent
{
    CLLocation* location = [self.locationManager location];
    if( location != nil ){
        Event* event = (Event*)[NSEntityDescription insertNewObjectForEntityForName:@"Event" inManagedObjectContext:self.managedObjectContext];
        CLLocationCoordinate2D coodination = [location coordinate];
        event.latitude = [NSNumber numberWithDouble: coodination.latitude];
        event.longitude = [NSNumber numberWithDouble: coodination.longitude];
        event.creationDate = [NSDate date];
        NSError *error = nil;
        if (![self.managedObjectContext save:&error]) {
            // エラーを処理する。 }
            NSLog(@"data save error: %@",error);
            return;
        }
        [self.eventsArray insertObject:event atIndex:0];
        NSIndexPath* indexpath = [NSIndexPath indexPathForRow:0 inSection:0];
        [self.tableView insertRowsAtIndexPaths:[NSArray arrayWithObject:indexpath] withRowAnimation:UITableViewRowAnimationFade];
        [self.tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0] atScrollPosition:UITableViewScrollPositionTop animated:YES];
    }
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if( editingStyle == UITableViewCellEditingStyleDelete ){
        NSManagedObject* object = self.eventsArray[indexPath.row];
        [self.managedObjectContext deleteObject:object];
        [self.eventsArray removeObjectAtIndex:indexPath.row];
        [self.tableView deleteRowsAtIndexPaths:[NSArray arrayWithObjects:indexPath, nil] withRowAnimation:YES];
        NSError *error = nil;
        if (![self.managedObjectContext save:&error]) {
            // エラーを処理する。 }
            NSLog(@"data save error: %@",error);
            return;
        }
    }
}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

/*
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
#warning Potentially incomplete method implementation.
    // Return the number of sections.
    return 0;
}
*/

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
//#warning Incomplete method implementation.
    // Return the number of rows in the section.
    return self.eventsArray.count;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"StandardCell" forIndexPath:indexPath];
    
    // Configure the cell...
    static NSDateFormatter* dataFormatter = nil;
    if( dataFormatter == nil ){
        dataFormatter = [[NSDateFormatter alloc] init];
        [dataFormatter setTimeStyle:NSDateFormatterMediumStyle];
        [dataFormatter setDateStyle:NSDateFormatterMediumStyle];
    }
    static NSNumberFormatter* numberForatter = nil;
    if( numberForatter == nil ){
        numberForatter = [[NSNumberFormatter alloc] init];
        [numberForatter setNumberStyle:NSNumberFormatterDecimalStyle];
        [numberForatter setMaximumFractionDigits:3];
    }
    Event* event = self.eventsArray[indexPath.row];
    
    cell.textLabel.text = [dataFormatter stringFromDate:event.creationDate];
    NSString* string = [NSString stringWithFormat:@"%@, %@", [numberForatter stringFromNumber:event.latitude], [numberForatter stringFromNumber:event.longitude] ];
    cell.detailTextLabel.text = string;
    return cell;
}


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

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
