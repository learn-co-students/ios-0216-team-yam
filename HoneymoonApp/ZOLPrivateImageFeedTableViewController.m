//
//  ZOLPrivateImageFeedTableViewController.m
//  HoneymoonApp
//
//  Created by Samuel Boyce on 4/12/16.
//  Copyright © 2016 Team Yam. All rights reserved.
//

#import "ZOLPrivateImageFeedTableViewController.h"
#import "ZOLImage.h"
#import "ZOLPrivateTableViewCell.h"

@interface ZOLPrivateImageFeedTableViewController ()

@property (strong, nonatomic) IBOutlet UIBarButtonItem *publishButton;

@end


@implementation ZOLPrivateImageFeedTableViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.publishButton.enabled = NO;
    self.dataStore = [ZOLDataStore dataStore];
    self.localImageArray = self.dataStore.user.userHoneymoon.honeymoonImages;
    
    [self populateImages];
}

- (IBAction)backButtonTapped:(UIBarButtonItem *)sender
{
    [self.navigationController.presentingViewController dismissViewControllerAnimated:NO completion:nil];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

-(void)populateImages
{
    CKReference *referenceToHoneymoon = [[CKReference alloc]initWithRecordID:self.dataStore.user.userHoneymoon.honeymoonID action:CKReferenceActionDeleteSelf];
    NSPredicate *userHoneymoonPredicate = [NSPredicate predicateWithFormat:@"%K == %@", @"Honeymoon", referenceToHoneymoon];
    CKQuery *honeymoonImageQuery = [[CKQuery alloc] initWithRecordType:@"Image" predicate:userHoneymoonPredicate];
    NSArray *relevantKeys = @[@"Picture", @"Honeymoon"];
    
    __weak typeof(self) tmpself = self;
    [self.dataStore.client queryRecordsWithQuery:honeymoonImageQuery orCursor:nil fromDatabase:self.dataStore.client.database forKeys:relevantKeys withQoS:NSQualityOfServiceUserInitiated everyRecord:^(CKRecord *record)
    {
        //Put the image we get into the relevant cell
        for (ZOLImage *image in tmpself.localImageArray)
        {
            if ([image.imageRecordID.recordName isEqualToString:record.recordID.recordName])
            {
                UIImage *retrievedImage = [tmpself.dataStore.client retrieveUIImageFromAsset:record[@"Picture"]];
                image.picture = retrievedImage;
                NSUInteger rowOfImage = [tmpself.localImageArray indexOfObject:image];
                NSIndexPath *indexPathForImage = [NSIndexPath indexPathForRow:rowOfImage inSection:0];
                
                [[NSOperationQueue mainQueue] addOperationWithBlock:^{
                    [tmpself.tableView reloadRowsAtIndexPaths:@[indexPathForImage] withRowAnimation:UITableViewRowAnimationNone];
                }];
            }
        }
    }
                                 completionBlock:^(CKQueryCursor *cursor, NSError *error)
    {
        if (error)
        {
            NSLog(@"Error loading user's images: %@", error.localizedDescription);
            NSTimer *retryTimer = [NSTimer scheduledTimerWithTimeInterval:2 target:self selector:@selector(populateImages) userInfo:nil repeats:NO];
//            [retryTimer fire];
            NSRunLoop *currentLoop = [NSRunLoop currentRunLoop];
            [currentLoop addTimer:retryTimer forMode:NSDefaultRunLoopMode];
            [currentLoop run];
        }
        else
        {
            NSLog(@"Image query done");
            [[NSOperationQueue mainQueue] addOperationWithBlock:^
            {
                self.publishButton.enabled = YES;
            }];
        }
    }];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.localImageArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    ZOLPrivateTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"privateDetailCell" forIndexPath:indexPath];
    
    ZOLImage *thisImage = self.localImageArray[indexPath.row];
    
    cell.privateCellImage.image = thisImage.picture;
    cell.privateCellLabel.text = thisImage.caption;
    
    return cell;
}

- (IBAction)privatePullToRefresh:(UIRefreshControl *)sender
{
    [self.tableView reloadData];
    [sender endRefreshing];
}

@end
