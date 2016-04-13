//
//  ScrollViewController.m
//  ScrollViewTester
//
//  Created by Jennifer A Sipila on 4/6/16.
//  Copyright © 2016 Jennifer A Sipila. All rights reserved.
//

#import "ZOLScrollViewController.h"
#import "ZOLRatingViewController.h"

@interface ZOLScrollViewController () <UIScrollViewDelegate>

@property(strong, nonatomic) NSMutableArray *imagesArray;
@property (strong, nonatomic) IBOutlet UIScrollView *scrollView;
@property (strong, nonatomic) IBOutlet UIStackView *stackViewOutlet;
@property (strong, nonatomic) IBOutlet NSLayoutConstraint *widthConstraint;
@property (strong, nonatomic) UIImage *selectedImage;

//Set up arrows to show additional content

@property (strong, nonatomic) UIButton *rightArrow;
@property (strong, nonatomic) UIButton *leftArrow;

@end

@implementation ZOLScrollViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.imagesArray = [[NSMutableArray alloc]init];
    self.dataStore = [ZOLDataStore dataStore];
    
    for (ZOLImage *zolImage in self.dataStore.user.userHoneymoon.honeymoonImages)
    {
        UIImage *imageToAdd = zolImage.picture;
        [self.imagesArray addObject:imageToAdd];
    }
    
    self.selectedImage = self.imagesArray[0];
    
    for (UIImage *image in self.imagesArray)
    {
        UIImageView *view = [[UIImageView alloc] initWithImage:image];
        view.userInteractionEnabled = YES;
        UITapGestureRecognizer *viewTap = [[UITapGestureRecognizer alloc]
                                           initWithTarget:self action:@selector(handleTap:)];
        [view addGestureRecognizer:viewTap];
        view.contentMode = UIViewContentModeScaleAspectFill;
        view.clipsToBounds = YES;
        [self.stackViewOutlet addArrangedSubview:view];
    }
    
    self.stackViewOutlet.axis = UILayoutConstraintAxisHorizontal;
    self.stackViewOutlet.distribution = UIStackViewDistributionFillEqually;
    self.stackViewOutlet.alignment = UIStackViewAlignmentFill;
    self.stackViewOutlet.spacing = 0;
    
    self.widthConstraint.constant = self.view.frame.size.width * self.imagesArray.count;
    self.scrollView.contentSize = CGSizeMake(self.widthConstraint.constant, self.view.frame.size.height);
    NSLog(@"%lf", self.widthConstraint.constant);

   self.scrollView.delegate = self;
    
    // Set up arrows to indicate more content

    self.rightArrow = [UIButton buttonWithType:UIButtonTypeCustom];
    self.leftArrow = [UIButton buttonWithType:UIButtonTypeCustom];
    
    //Set images to buttons & rendering mode to template.
    UIImage *rightArrowButtonImage = [[UIImage imageNamed:@"RightArrow.png"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
    UIImage *leftArrowButtonImage = [[UIImage imageNamed:@"LeftArrow.png"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
    
    [self.rightArrow setBackgroundImage:rightArrowButtonImage forState:UIControlStateNormal];
    [self.leftArrow setBackgroundImage:leftArrowButtonImage forState:UIControlStateNormal];

    //Set color to arrows
    [self.leftArrow setTintColor:[UIColor whiteColor]];
    [self.rightArrow setTintColor:[UIColor whiteColor]];
    
    // Upon startup, we are furthest to the left
    self.rightArrow.hidden = NO;
    self.leftArrow.hidden = YES;

    // Add to the view controller
    [self.view addSubview:self.rightArrow];
    [self.view addSubview:self.leftArrow];

    // Constrain right arrow
    self.rightArrow.translatesAutoresizingMaskIntoConstraints = NO;
    [self.rightArrow.trailingAnchor constraintEqualToAnchor:self.view.trailingAnchor constant:-20.0].active = YES;
    [self.rightArrow.centerYAnchor constraintEqualToAnchor:self.view.centerYAnchor].active = YES;
    [self.rightArrow.heightAnchor constraintEqualToAnchor:self.view.heightAnchor multiplier:0.1].active = YES;
    self.rightArrow.contentMode = UIViewContentModeScaleAspectFit;
    self.rightArrow.clipsToBounds = YES;
    
    // Constrain left arrow
    self.leftArrow.translatesAutoresizingMaskIntoConstraints = NO;
    [self.leftArrow.leadingAnchor constraintEqualToAnchor:self.view.leadingAnchor constant:20.0].active = YES;
    [self.leftArrow.centerYAnchor constraintEqualToAnchor:self.view.centerYAnchor].active = YES;
    [self.leftArrow.heightAnchor constraintEqualToAnchor:self.view.heightAnchor multiplier:0.1].active = YES;
    self.leftArrow.contentMode = UIViewContentModeScaleAspectFit;
    self.leftArrow.clipsToBounds = YES;
    
    // Constrain aspect ratio
    UIImage *arrowImage = [UIImage imageNamed:@"LeftArrow.png"];
    CGFloat arrowAspectRatio = (arrowImage.size.width / arrowImage.size.height);
    NSLog(@"aspect ratio: %f",arrowAspectRatio);
    
    [self.rightArrow.widthAnchor constraintEqualToAnchor:self.rightArrow.heightAnchor multiplier:arrowAspectRatio].active = YES;
    
    [self.leftArrow.widthAnchor constraintEqualToAnchor:self.leftArrow.heightAnchor multiplier:arrowAspectRatio].active = YES;
    
    
    //Add IBActions programmatically for the buttons
    [self.rightArrow addTarget:self action:@selector(rightArrowButtonTappedWithselector:) forControlEvents:UIControlEventTouchUpInside];
    
    [self.leftArrow addTarget:self action:@selector(leftArrowButtonTappedWithselector:) forControlEvents:UIControlEventTouchUpInside];
    
}

-(IBAction)rightArrowButtonTappedWithselector:(id)sender
{
    //Calculate the offset distance for the right button to scroll when tapped
    
    NSUInteger pageNumber = self.scrollView.contentOffset.x /
    self.scrollView.bounds.size.width;
    
    NSUInteger *xOffset =
    
    CGPoint scrollDistance = CGPointMake((pageNumber * self.scrollView.frame.size.width), 0);
    
    [self.scrollView setContentOffset:scrollDistance animated:YES];
}

-(IBAction)leftArrowButtonTappedWithselector:(id)sender
{
    CGPoint scrollDistance = CGPointMake(-self.scrollView.frame.size.width, 0);
    
    [self.scrollView setContentOffset:scrollDistance animated:YES];
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    NSUInteger pagenumber = self.scrollView.contentOffset.x /
    self.scrollView.bounds.size.width;
    self.selectedImage = [self.imagesArray objectAtIndex:pagenumber];
    NSLog(@"Page number: %lu", pagenumber);
    NSLog(@"Image: %@", self.selectedImage);
    
    //Set up arrows to indicate more content
    // Are we at the far left of the scrollview?
    if (scrollView.contentOffset.x <
        scrollView.contentSize.width - scrollView.frame.size.width) {
        self.rightArrow.hidden = NO;
    } else {
        self.rightArrow.hidden = YES;
    }
    // Are we at the far right of the scrollview?
    if (scrollView.contentOffset.x > 0) {
        self.leftArrow.hidden = NO;
    }else {
        self.leftArrow.hidden = YES;
    }
}

- (void)handleTap:(UITapGestureRecognizer *)tapGestureRecognizer
{
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"Choose cover photo"
                                                                             message:@"Make this the cover photo?"
                                                                      preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"Cancel"
                                                           style:UIAlertActionStyleDefault
                                                         handler:^(UIAlertAction * _Nonnull action) {
                                                             [self dismissViewControllerAnimated:NO completion:nil];
                                                         }];
    
    UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"Ok"
                                                       style:UIAlertActionStyleDefault
                                                     handler:^(UIAlertAction * _Nonnull action) {
                                                         //Set the selected image to outside/data property here.
                                                         NSLog(@"Image: %@", self.selectedImage);
                                                         //Go to next publish option.
                                                         self.dataStore.user.userHoneymoon.coverPicture = self.selectedImage;
                                                         
    [self performSegueWithIdentifier:@"ratingSegue" sender:self];
                                                     }];
    [alertController addAction:cancelAction];
    [alertController addAction:okAction];
    [self presentViewController:alertController animated:YES completion:nil];
}

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"ratingSegue"]) {
        ZOLRatingViewController *ratingViewController = segue.destinationViewController;
        ratingViewController.coverImage = self.selectedImage;
    }
}

@end




