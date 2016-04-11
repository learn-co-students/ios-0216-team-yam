//
//  ZOLLoginViewController.m
//  HoneymoonApp
//
//  Created by Samuel Boyce on 3/31/16.
//  Copyright © 2016 Team Yam. All rights reserved.
//

#import "ZOLLoginViewController.h"

@interface ZOLLoginViewController ()

@property (nonatomic, assign) __block BOOL shouldLogin;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *activityIndicator;

@end

@implementation ZOLLoginViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)loginTapped:(id)sender
{
    NSLog(@"Login Tapped");
    
    dispatch_semaphore_t semaphore = dispatch_semaphore_create(0);
    
    [self.activityIndicator startAnimating];
    self.activityIndicator.hidden = NO;
    
    [[CKContainer defaultContainer] accountStatusWithCompletionHandler:^(CKAccountStatus accountStatus, NSError *error) {
        if (accountStatus == CKAccountStatusNoAccount)
        {
            self.shouldLogin = NO;
        }
        else
        {
            self.shouldLogin = YES;
        }
        dispatch_semaphore_signal(semaphore);
    }];
    
    dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER);
    
    if (!self.shouldLogin)
    {
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Sign in to iCloud"
                                                                       message:@"Sign in to your iCloud account to use this app. On the Home screen, launch Settings, tap iCloud, and enter your Apple ID. Turn iCloud Drive on. If you don't have an iCloud account, tap 'Create a new Apple ID'."
                                                                preferredStyle:UIAlertControllerStyleAlert];
        [alert addAction:[UIAlertAction actionWithTitle:@"Okay"
                                                  style:UIAlertActionStyleCancel
                                                handler:nil]];
        [self presentViewController:alert animated:YES completion:nil];
    }
    else
    {
        self.dataStore = [ZOLDataStore dataStore];
        
//        CKReference *referenceToUser = [[CKReference alloc]initWithRecordID:self.dataStore.user.userID action:CKReferenceActionDeleteSelf];
//        NSPredicate *userSearch = [NSPredicate predicateWithFormat:@"User == %@", referenceToUser];
//        CKQuery *findHoneymoon = [[CKQuery alloc]initWithRecordType:@"Honeymoon" predicate:userSearch];
//        CKQueryOperation *findHMOp = [[CKQueryOperation alloc]initWithQuery:findHoneymoon];
//        findHMOp.resultsLimit = 1;
//        
//        dispatch_semaphore_t loginSemaphore = dispatch_semaphore_create(0);
//        findHMOp.queryCompletionBlock = ^(CKQueryCursor *cursor, NSError *operationError){
//            
//            if (operationError)
//            {
//                NSLog(@"Obviously this is an error, but heres the description: %@, and code: %lu, and heck, heres the domain: %@", operationError.localizedDescription, operationError.code, operationError.domain);
//            }
//            
//            dispatch_semaphore_signal(loginSemaphore);
//        };
//        
//        __block CKRecord *userHoneyMoon;
//        findHMOp.recordFetchedBlock = ^(CKRecord *record){
//            userHoneyMoon = record;
//            self.dataStore.user.honeymoonID = record.recordID;
//        };
//        
//        [self.dataStore.database addOperation:findHMOp];
//        dispatch_semaphore_wait(loginSemaphore, DISPATCH_TIME_FOREVER);
//        
//        if (!userHoneyMoon)
//        {
//            [self createBlankHoneyMoon];
//        }
    }
    
    [self.activityIndicator stopAnimating];
}

#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
-(BOOL)shouldPerformSegueWithIdentifier:(NSString *)identifier sender:(id)sender
{
    NSLog(@"shouldPerformSegue");
    
    return self.shouldLogin;
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}

//    CKReference *referenceToUser = [[CKReference alloc]initWithRecordID:self.dataStore.user.userID action:CKReferenceActionDeleteSelf];
//    NSPredicate *userSearch = [NSPredicate predicateWithFormat:@"User == %@", referenceToUser];
//    CKQuery *findHoneymoon = [[CKQuery alloc]initWithRecordType:@"Honeymoon" predicate:userSearch];
//    CKQueryOperation *findHMOp = [[CKQueryOperation alloc]initWithQuery:findHoneymoon];
//    findHMOp.resultsLimit = 1;
//
//    dispatch_semaphore_t loginSemaphore = dispatch_semaphore_create(0);
//    findHMOp.queryCompletionBlock = ^(CKQueryCursor *cursor, NSError *operationError){
//
//        if (operationError)
//        {
//            NSLog(@"Obviously this is an error, but heres the description: %@, and code: %lu, and heck heres the domain: %@", operationError.localizedDescription, operationError.code, operationError.domain);
//        }
//
//        dispatch_semaphore_signal(loginSemaphore);
//    };
//
//    __block CKRecord *userHoneyMoon;
//    findHMOp.recordFetchedBlock = ^(CKRecord *record){
//        userHoneyMoon = record;
//        self.dataStore.user.honeymoonID = record.recordID;
//    };
//
//    [self.dataStore.database addOperation:findHMOp];
//    dispatch_semaphore_wait(loginSemaphore, DISPATCH_TIME_FOREVER);
//
//    if (!userHoneyMoon)
//    {
//        [self createBlankHoneyMoon];
//    }



//
//    dispatch_semaphore_t semaphore = dispatch_semaphore_create(0);
//
//    [self.activityIndicator startAnimating];
//    self.activityIndicator.hidden = NO;
//
//    if ([identifier isEqualToString:@"LoggedIn"])
//    {
//        [[CKContainer defaultContainer] accountStatusWithCompletionHandler:^(CKAccountStatus accountStatus, NSError *error) {
//        if (accountStatus == CKAccountStatusNoAccount)
//        {
//            self.shouldLogin = NO;
//        }
//        else
//        {
//            self.shouldLogin = YES;
//        }
//        dispatch_semaphore_signal(semaphore);
//        }];
//    }
//
//    dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER);
//
//    [self.activityIndicator stopAnimating];
//
//    if (!self.shouldLogin)
//    {
//        UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Sign in to iCloud"
//                                                                       message:@"Sign in to your iCloud account to use this app. On the Home screen, launch Settings, tap iCloud, and enter your Apple ID. Turn iCloud Drive on. If you don't have an iCloud account, tap 'Create a new Apple ID'."
//                                                                preferredStyle:UIAlertControllerStyleAlert];
//        [alert addAction:[UIAlertAction actionWithTitle:@"Okay"
//                                                  style:UIAlertActionStyleCancel
//                                                handler:nil]];
//        [self presentViewController:alert animated:YES completion:nil];
//    }
//

@end
