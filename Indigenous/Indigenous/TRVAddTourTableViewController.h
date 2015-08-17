//
//  TRVAddTourTableViewController.h
//  Indigenous
//
//  Created by Amitai Blickstein on 8/15/15.
//  Copyright (c) 2015 Bad Boys 3. All rights reserved.
//

#import <CZPicker.h>
#import <UIKit/UIKit.h>
#import "TRVTour_PF.h"

@interface TRVAddTourTableViewController : UITableViewController <CZPickerViewDataSource, CZPickerViewDelegate>

@property (strong, nonatomic) TRVTour_PF *tourData;
@property (strong, nonatomic) NSArray *tourDataSubtitlesArray;
@property (strong, nonatomic) NSArray *tourDataDefaultTitlesArray;
@property (strong, nonatomic) NSMutableArray *tourDataWithUserInputTitlesArray;
@property (strong, nonatomic) NSArray *tourCategories;

@end
