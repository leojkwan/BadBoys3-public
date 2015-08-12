//
//  TRVAddNewStopToItineraryVC.m
//  Indigenous
//
//  Created by Amitai Blickstein on 7/29/15.
//  Copyright (c) 2015 Bad Boys 3. All rights reserved.
//

#import "TRVAddToursVC.h"
#import "TRVPickerMapViewController.h"
#import "TestMapWithSearchVC.h"
#import "TRVTour.h"
#import "TRVItinerary.h"
#import "TRVTourStop.h"
#import <Parse.h>
#import <MapKit/MapKit.h>
#import <RMSaveButton.h>
#import "TRVUserDataStore.h"
#import <CZPicker.h>
#import <SSFlatDatePicker.h>
#import <DateTools.h>

#define DBLG NSLog(@"%@ reporting!", NSStringFromSelector(_cmd));


@interface TRVAddToursVC () <TRVPickerMapDelegate, MKMapViewDelegate, UITextFieldDelegate, UITableViewDelegate, UITableViewDataSource>

@property (nonatomic, strong) TRVUserDataStore          *sharedDataStore;

@property (nonatomic, strong) TRVTour                   *tour;
@property (weak, nonatomic) IBOutlet UITextField        *addTourNameTxF;
@property (nonatomic, strong) TRVUser                   *user;
@property (nonatomic, strong) TRVBio                    *bio;
@property (nonatomic, strong) TRVTourCategory           *tourCategory;
@property (weak, nonatomic) IBOutlet UISegmentedControl *tourCategorySegControl;
@property (nonatomic, strong) TRVItinerary              *itinerary;
@property (nonatomic, strong) NSMutableArray            *listOfStops;
@property (weak, nonatomic) IBOutlet UITableView        *itineraryTableView;
@property (weak, nonatomic) IBOutlet UITextField        *dateTxF;
@property (weak, nonatomic) IBOutlet UIDatePicker       *datePicker;
@property (nonatomic, strong) NSDate                    *tourDate;
@property (weak, nonatomic) IBOutlet UIButton *confirmDateSelectionButton;
- (IBAction)confirmDateSelectionButtonTapped:(id)sender;

@property (weak, nonatomic) IBOutlet UILabel            *currentUserLabel;
@property (weak, nonatomic) IBOutlet UILabel            *tourCategoryLabel;
@property (weak, nonatomic) IBOutlet UILabel            *tourNameLabel;
@property (weak, nonatomic) IBOutlet UIImageView        *tourImage;






    //- (IBAction)chooseCategoryButtonTapped:(id)sender;

    //@property (nonatomic, weak) IBOutlet RMSaveButton *saveTourButton;
    //@property (weak, nonatomic) IBOutlet UILabel *saveButtonLabel;

    //@property (weak, nonatomic) IBOutlet SSFlatDatePicker *datePicker;
@end

@implementation TRVAddToursVC


- (void)viewDidLoad {
    [super viewDidLoad];
    
        //Setup protocols, initialize singletons, etc.
    self.itineraryTableView.delegate   = self;
    self.itineraryTableView.dataSource = self;
    self.dateTxF.delegate              = self;
    
//    [self.datePicker            addTarget:self
//                                   action:@selector(changeTourDate)
//                         forControlEvents:UIControlEventValueChanged];
    
    [self.tourCategorySegControl addTarget:self
                                    action:@selector(changeTourCategory)
                          forControlEvents:UIControlEventValueChanged];
    
    
    self.sharedDataStore               = [TRVUserDataStore sharedUserInfoDataStore];
    TRVBio *userBio                    = self.sharedDataStore.loggedInUser.userBio;
    self.currentUserLabel.text         = [NSString stringWithFormat:@"Hi, %@!", userBio.firstName];

    
        //    self.saveButtonLabel.hidden = YES;
    
        //Wire this up to the save functionality
//    self.saveTourButton.startHandler      = ^void() {DBLG};
//    self.saveTourButton.interruptHandler  = ^void() {DBLG};
//    self.saveTourButton.completionHandler = ^void() {DBLG};
}

#pragma mark - UITextfield Delegate

-(BOOL)textFieldShouldBeginEditing:(UITextField *)textField {
    if ([textField isEqual:self.dateTxF]) {
        self.itineraryTableView.hidden = YES;
        self.datePicker.hidden = NO;
        self.confirmDateSelectionButton.hidden = NO;
        self.confirmDateSelectionButton.enabled = YES;
        [self.datePicker becomeFirstResponder];
        return NO;
    } else {
        return YES;
    }
}

-(void)textFieldDidBeginEditing:(UITextField *)textField {

}

-(BOOL)textFieldShouldReturn:(UITextField *)textField {
    if ([textField isEqual:self.addTourNameTxF]) {
        self.tourNameLabel.text = textField.text;
        self.itinerary.nameOfTour = textField.text;
        textField.text = @"";
        [textField resignFirstResponder];
    }
    return YES;
}

#pragma mark - Category Control helper

-(void)changeTourCategory {
    NSUInteger idx = self.tourCategorySegControl.selectedSegmentIndex;
    NSString *chosenCategory = [self.tourCategorySegControl titleForSegmentAtIndex:idx];
    self.tourCategory.categoryName = chosenCategory;
    self.tourCategoryLabel.text = chosenCategory;
}


#pragma mark - DatePicker helper

//-(void)changeTourDate {
//    
//}

- (IBAction)confirmDateSelectionButtonTapped:(id)sender {
    DBLG
    NSLog(@"tourdate is set for: %@", self.datePicker.date);
    self.tourDate = self.datePicker.date;
    
    NSDateFormatter *dateFormatter = [NSDateFormatter new];
    dateFormatter.dateStyle = NSDateFormatterShortStyle;
    NSString *formattedDateString = [dateFormatter stringFromDate:self.datePicker.date];
    
    self.dateTxF.text = formattedDateString;
}


#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"toMapSegueID"]) {
    TRVPickerMapViewController *destinationVC = segue.destinationViewController;
        destinationVC.delegate = self;
    } else if ([segue.identifier isEqualToString:@"toAppleMapSegueID"]) {
        TestMapWithSearchVC *destinationVC = segue.destinationViewController;
        destinationVC.delegate = self;
    }
    
    
    
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}

//- (void)initializeNewTourConstruct {
//    PFObject *itineraryUnderConstruction = [PFObject objectWithClassName:@"TourUnderConstruction"];
//        //TODO:[Amitai] store the growing itinerary in a PFObject to the local datastore
//}

/**
 *  Make sure that a PFObject[@"TourUnderConstruction"][@"ItineraryUnderConstruction"] exists, and save it to @"AddTourPins"...
 */
- (void)userSelectedTourStopLocation:(CLLocation*)location
{
    DBLG
    BOOL didBadBoys3SolveThePFObjectBug = YES;
    if (didBadBoys3SolveThePFObjectBug) {
    
        PFQuery *tourQuery = [PFQuery queryWithClassName:@"ItineraryUnderConstruction"];
                            [tourQuery whereKeyExists:@"Itinerary"];
                            [tourQuery fromPinWithName:@"AddTourVC_Pins"];
        TRVItinerary * itineraryUnderConstruction_TRV;
        PFObject     * itineraryUnderConstruction_PF;
        NSError *queryError = nil;
        NSArray *itineraryObjects = [tourQuery findObjects:&queryError];
        NSLog(@"NSArray <PFObjects> itineraryObjects: %@", [itineraryObjects description]);
        if (queryError) { //If PFObjectWithClassName: @"ItineraryUnderConstruction" does not exist...
                //...then set our itinerary pointers to new objects....
            itineraryUnderConstruction_PF = [PFObject objectWithClassName:@"ItineraryUnderConstruction"];
            itineraryUnderConstruction_TRV = [TRVItinerary new];
            [itineraryUnderConstruction_PF addObject:itineraryUnderConstruction_TRV forKey:@"Itinerary"];
        } else {
                //...if an itinerary object(s) already exist, then our pointers should let us build on them.
            itineraryUnderConstruction_PF = [tourQuery getFirstObject];
            itineraryUnderConstruction_TRV = (TRVItinerary*)itineraryUnderConstruction_PF[@"Itinerary"];
        }
            //Either way, we now have a/our TRVItinerary...
        TRVTourStop *newStop = [[TRVTourStop alloc] initWithCoordinates:location.coordinate];
        [itineraryUnderConstruction_TRV.tourStops addObject:newStop];
        itineraryUnderConstruction_PF[@"Itinerary"] = itineraryUnderConstruction_TRV;
        NSLog(@"The itinerary under construction now has %lu tour stops", itineraryUnderConstruction_TRV.tourStops.count);
        [itineraryUnderConstruction_PF pinWithName:@"AddTourVC_Pins"];
    } else {
        DBLG
        NSLog(@"Need to solve the bug (Invalid write to JSON(TVRItinerary))\nOh, and CLLocation is %@:", [location description]);
    }
}

    //!!!
- (IBAction)saveTourButton1:(id)sender {
        //Save Tour as TRVTourObject to Parse:TRVUser
}

- (IBAction)chooseCategoryButtonTapped:(id)sender {
    CZPickerView *categoryPicker = [[CZPickerView alloc] initWithHeaderTitle:@"Tour Category"
                                                           cancelButtonTitle:@"Still Can't Decide"
                                                          confirmButtonTitle:@"Yup, that's it!"];
    categoryPicker.delegate = self;
    categoryPicker.dataSource = self;
    categoryPicker.needFooterView = YES;
    [categoryPicker show];
}

#pragma mark - CZPickerViewDataSource

-(NSInteger)numberOfRowsInPickerView:(CZPickerView *)pickerView {
    return 4;
}

-(NSAttributedString *)czpickerView:(CZPickerView *)pickerView attributedTitleForRow:(NSInteger)row {
    NSArray *categoryTitles = @[@"See", @"Play", @"Eat", @"Drink"];
    return categoryTitles[row];
}

//#pragma mark - CZPickerViewDelegate
//
//-(void)czpickerView:(CZPickerView *)pickerView didConfirmWithItemAtRow:(NSInteger)row {
//    DBLG
//
//    /**
//     *  FIXME: Get Tim/Joe's help on the syntax...
//     */
//    NSArray *categoryTitles = @[@"See", @"Play", @"Eat", @"Drink"];
//    NSString *chosenCategory = categoryTitles[row];
//
//    NSMethodSignature *categoryInitSignature = [TRVTourCategory instanceMethodSignatureForSelector:@selector(initWithName:)];
//    NSInvocation *createChosenCategoryObject = [NSInvocation invocationWithMethodSignature:categoryInitSignature];
//    createChosenCategoryObject.target = self.tourCategory;
//    createChosenCategoryObject.selector = @selector(initWithName:);
//    [createChosenCategoryObject setArgument:&chosenCategory atIndex:2];
//    NSUInteger length = [[createChosenCategoryObject methodSignature] methodReturnLength];
//    buffer = (void *)malloc(length);
//    
//    [createChosenCategoryObject invoke];
//    createChosenCategoryObject getReturnValue:<#(void *)#>
//    self.tourCategory = //whatever the returnObject is.
//    self.tourCategory = [[TRVTourCategory alloc] initWithName:categoryTitles[row]];
//    self.tourCategoryLabel.text = self.tourCategory.categoryName;
//}

-(void)czpickerViewDidClickCancelButton:(CZPickerView *)pickerView {
    [pickerView resignFirstResponder];
}

#pragma mark - Parse functionality

    //FIXME Make it "createParseTourandsave"
-(void)createParseDummyTour {
    
    PFUser *currentUser = [PFUser currentUser];
    PFObject *theTour = [PFObject objectWithClassName:@"Tour"];
    [theTour setObject:currentUser forKey:@"guideForThisTour"];
    
    PFObject *theItinerary = [PFObject objectWithClassName:@"Itinerary"];
    theTour[@"categoryForThisTour"] = @"Drink";
    theTour[@"tourDeparture"] = [NSDate dateWithTimeIntervalSinceNow:1000];
        //    //  theTour[@"tourAverageRating"] = CGFLOAT;
        //
        //
    PFObject *theStop = [PFObject objectWithClassName:@"TourStop"];
    theTour[@"itineraryForThisTour"] = theItinerary;
    theItinerary[@"nameOfTour"] = @"Some name of tour";
    
    UIImage *tourImage = [UIImage imageNamed:@"madrid.jpg"];
    
    
        // converts tour image to 1/5 quality
    NSData *imageData = UIImageJPEGRepresentation(tourImage, .2f);
    PFFile *PFImage = [PFFile fileWithName:theItinerary[@"nameOfTour"] data:imageData];
    
    theItinerary[@"tourImage"] = PFImage;
    
        //    theItinerary[@"tourImage"] = tourImage;
        //
        ////    // theItinerary[@"attractions"] = ARRAY OF ATTRACTIONS;
        //
    theStop[@"operatorCost"] = @0;
    theStop[@"incidentalCost"] = @0;
    theStop[@"lat"] = @10;
    theStop[@"lng"] = @10;
    theStop[@"coordinatePoint"] = [PFGeoPoint geoPointWithLatitude:10.0 longitude:10.0];
    theStop[@"nameOfPlace"] = @"The Flatiron School";
    theStop[@"descriptionOfEvent"] = @"We will be running through the six with our woes.  You know how that goes.";
    theStop[@"addressOfEvent"] = @"123 Nobody St.";
    
        //MAKE SURE THAT THIS IS A PFFILE.   LOOK AT ABOVE CODE WHICH TAKES NSDATA AND CONVERTS TO PFFILE.
    theStop[@"image"] = PFImage;
    
    NSArray *tourStopsArray = @[theStop, theStop, theStop, theStop];
    theItinerary[@"tourStops"] = tourStopsArray;
    theItinerary[@"numberOfStops"] = @(tourStopsArray.count);
    
    
        ////    //  theStop[@"tourStopLocation"] = pfgeopoint;
        ////
        ////    //    PFObject *theMarker = [PFObject objectWithClassName:@"GMSMarker"];
        ////    //    theMarker[@"position"] = PFGEOPOINT;
        ////    //    theMarker[@"snippet"] = NSSTring;
        ////    //    theMarker[@"icon"] = UIImage;
        ////    //    theMarker[@"groundAnchor"] = cgpoint;
        ////    //    theMarker[@"infoWindowAnchor"] = cgpoint;
        ////    //
        ////    //    theStop[@"tourStopMarker"] = theMarker;
        ////    //
        ////
    
    [theTour saveInBackgroundWithBlock:^(BOOL success, NSError *error){
        NSLog(@"THE TOUR ID IS: %@", theTour.objectId);
        
        
        [currentUser addObject:theTour forKey:@"myTrips"];
        [currentUser saveInBackgroundWithBlock:^(BOOL success, NSError *error){
            if (error){
                NSLog(@"Cant save to array because: %@", error);
            } else {
                NSLog(@"Successfully added stuff to array.");
            }
        }];
        
        
    }];
    
}

@end
