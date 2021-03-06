//
//  ZOLMainTableViewController.m
//  HoneymoonApp
//
//  Created by Andreas Vestergaard on 05/04/16.
//  Copyright © 2016 Team Yam. All rights reserved.
//

#import "ZOLMainTableViewController.h"
#import "ZOLMainCell.h"
#import "ZOLSimulatedFeedData.h"
#import "ZOLDetailTableViewController.h"
#import "ZOLCameraViewController.h"

@interface ZOLMainTableViewController ()

@property (nonatomic, strong) NSMutableArray *imagesToPush;
@property (nonatomic, strong) NSMutableArray *detailQueryCursors;

@end

@implementation ZOLMainTableViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.dataStore = [ZOLDataStore dataStore];
    self.imagesToPush = [[NSMutableArray alloc]init];
    
    if (self.dataStore.mainFeed.count > 0)
    {
        [self fetchCoverPhotos];
    }
    else
    {
        [self handleMainFeedError];
    }
    
    [self.tableView reloadData];
}

- (UIStatusBarStyle)preferredStatusBarStyle
{
    return UIStatusBarStyleLightContent;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (self.dataStore.mainFeed.count == 0)
    {
        return 3;
    }
    else
    {
        return self.dataStore.mainFeed.count;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    ZOLMainCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cellMain" forIndexPath:indexPath];
    
    if (self.dataStore.mainFeed.count > 0)
    {
        ZOLHoneymoon *thisHoneymoon = self.dataStore.mainFeed[indexPath.row];
        
        cell.image.image = thisHoneymoon.coverPicture;
        cell.cellRating = thisHoneymoon.rating;
        cell.userLabel.text = thisHoneymoon.userName;
        [cell drawStarRating];
        cell.userInteractionEnabled = YES;

        NSDateFormatter *dateFormat = [[NSDateFormatter alloc]init];
        dateFormat.dateStyle = NSDateFormatterMediumStyle;
        NSString *dateString = [dateFormat stringFromDate:thisHoneymoon.createdDate];

        cell.dateLabel.text = dateString;
        cell.headlineLabel.text = thisHoneymoon.honeymoonDescription;
    }
    
    else
    {
        cell.userLabel.text = @"";
        cell.headlineLabel.text = @"Loading...";
        cell.dateLabel.text = @"";
        cell.cellRating = 0;
        [cell drawStarRating];
        cell.userInteractionEnabled = NO;
    }
    
    return cell;
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqual: @"feedSegue"])
    {
        UINavigationController *destinationVC = [segue destinationViewController];
        ZOLDetailTableViewController *tableVC = (ZOLDetailTableViewController*)destinationVC.topViewController;
        NSIndexPath *selectedIndexPath = [self.tableView indexPathForSelectedRow];
            
        ZOLHoneymoon *honeymoonSelected = self.dataStore.mainFeed[selectedIndexPath.row];
            
        tableVC.localImageArray = honeymoonSelected.honeymoonImages;
        tableVC.selectedHoneymoonID = honeymoonSelected.honeymoonID;
        tableVC.titleString = honeymoonSelected.honeymoonDescription;
        tableVC.parralaxHeaderImage = honeymoonSelected.coverPicture;
    }
}

- (void)handleMainFeedError
{
    [self.dataStore populateMainFeedWithCompletion:^(NSError *error)
    {
        if (error)
        {
            NSLog(@"Error refreshing main feed");
            NSTimer *retryTimer = [NSTimer scheduledTimerWithTimeInterval:2 target:self selector:@selector(handleMainFeedError) userInfo:nil repeats:NO];

            NSRunLoop *currentLoop = [NSRunLoop currentRunLoop];
            [currentLoop addTimer:retryTimer forMode:NSDefaultRunLoopMode];
            [currentLoop run];
        }
        else
        {
            [self fetchCoverPhotos];
        }
    }];
}

- (void)fetchCoverPhotos
{
    NSPredicate *imagePredicate = [NSPredicate predicateWithFormat:@"%K BEGINSWITH %@", @"Published", @"YES"];
    CKQuery *honeymoonImageQuery = [[CKQuery alloc] initWithRecordType:@"Honeymoon" predicate:imagePredicate];
    NSArray *relevantKeys = @[@"CoverPicture", @"Published"];
    
    __weak typeof(self) tmpself = self;
    [self.dataStore.client queryRecordsWithQuery:honeymoonImageQuery orCursor:nil fromDatabase:self.dataStore.client.database forKeys:relevantKeys withQoS:NSQualityOfServiceUserInteractive everyRecord:^(CKRecord *record)
    {
        //Put the image we get into the relevant cell
        for (ZOLHoneymoon *honeymoon in tmpself.dataStore.mainFeed)
        {
            if ([honeymoon.honeymoonID.recordName isEqualToString:record.recordID.recordName])
            {
                UIImage *retrievedImage = [tmpself.dataStore.client retrieveUIImageFromAsset:record[@"CoverPicture"]];
                honeymoon.coverPicture = retrievedImage;
                NSUInteger rowOfHoneymoon = [tmpself.dataStore.mainFeed indexOfObject:honeymoon];
                NSIndexPath *indexPathForHoneymoon = [NSIndexPath indexPathForRow:rowOfHoneymoon inSection:0];
                
                [[NSOperationQueue mainQueue] addOperationWithBlock:^
                {
                    [tmpself.tableView reloadRowsAtIndexPaths:@[indexPathForHoneymoon] withRowAnimation:UITableViewRowAnimationNone];
                }];
            }
        }
    }
                                 completionBlock:^(CKQueryCursor *cursor, NSError *error)
    {
        if (error)
        {
            NSLog(@"Error loading images for main feed: %@", error.localizedDescription);
            NSTimer *retryTimer = [NSTimer scheduledTimerWithTimeInterval:2 target:self selector:@selector(fetchCoverPhotos) userInfo:nil repeats:NO];
            NSRunLoop *currentLoop = [NSRunLoop currentRunLoop];
            [currentLoop addTimer:retryTimer forMode:NSDefaultRunLoopMode];
            [currentLoop run];
        }
        
        else
        {
            dispatch_sync(dispatch_get_main_queue(), ^
            {
                [self.tableView reloadData];
            });
        }
        NSLog(@"Honeymoon CoverImage query done");
    }];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

//Previous code:
/*
- (IBAction)mainFeedPullToRefresh:(UIRefreshControl *)sender {
    //Grab the next honeymoons in the main feed query
    if (self.dataStore.mainFeed.count == 0)
    {
        [self handleMainFeedError];
    }
    else
    {
        [self.dataStore.client queryRecordsWithQuery:nil orCursor:self.dataStore.mainFeedCursor fromDatabase:self.dataStore.client.database forKeys:nil withQoS:NSQualityOfServiceUserInitiated everyRecord:^(CKRecord *record) {
            ZOLHoneymoon *thisHoneymoon = [[ZOLHoneymoon alloc]init];

            CKAsset *coverPictureAsset = record[@"CoverPicture"];
            UIImage *coverPic = [self.dataStore.client retrieveUIImageFromAsset:coverPictureAsset];
            thisHoneymoon.coverPicture = coverPic;

            NSNumber *ratingVal = record[@"RatingStars"];
            thisHoneymoon.rating = [ratingVal floatValue];

            thisHoneymoon.honeymoonDescription = record[@"Description"];
            thisHoneymoon.honeymoonID = record.recordID;

            //Populate the honeymoon with basic info about its images
            CKReference *honeymoonRef = [[CKReference alloc]initWithRecordID:thisHoneymoon.honeymoonID action:CKReferenceActionDeleteSelf];
            NSPredicate *findImages = [NSPredicate predicateWithFormat:@"%K == %@", @"Honeymoon", honeymoonRef];
            CKQuery *findImagesQuery = [[CKQuery alloc]initWithRecordType:@"Image" predicate:findImages];
            NSArray *captionKey = @[@"Caption", @"Honeymoon"];

            [self.dataStore.client queryRecordsWithQuery:findImagesQuery orCursor:nil fromDatabase:self.dataStore.client.database forKeys:captionKey withQoS:NSQualityOfServiceUserInitiated everyRecord:^(CKRecord *record) {

                ZOLImage *thisImage = [[ZOLImage alloc]init];
                thisImage.caption = record[@"Caption"];
                thisImage.imageRecordID = record.recordID;

                [thisHoneymoon.honeymoonImages addObject:thisImage];
            } completionBlock:^(CKQueryCursor *cursor, NSError *error) {
                if (error)
                {
                    NSLog(@"Error finding images for a honeymoon: %@", error.localizedDescription);
                }
            }];

            //Add the honeymoon to the main feed
            [self.dataStore.mainFeed insertObject:thisHoneymoon atIndex:0];

        } completionBlock:^(CKQueryCursor *cursor, NSError *error) {
            if (error)
            {
                NSLog(@"Error reloading main feed data: %@", error.localizedDescription);
            }
            else
            {
                self.dataStore.mainFeedCursor = cursor;
            }

            [self.tableView reloadData];
            [[NSOperationQueue mainQueue]addOperationWithBlock:^{
                [sender endRefreshing];
            }];
        }];
    }
}
*/
@end
