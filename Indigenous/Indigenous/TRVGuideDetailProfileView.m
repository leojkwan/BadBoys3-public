//
//  TRVGuideDetailProfileView.m
//  Indigenous
//
//  Created by Leo Kwan on 8/2/15.
//  Copyright (c) 2015 Bad Boys 3. All rights reserved.
//

#import "TRVGuideDetailProfileView.h"
#import <Masonry.h>

@interface TRVGuideDetailProfileView ()
@property (strong, nonatomic) IBOutlet UIView *guideDetailedProfileView;


@end

@implementation TRVGuideDetailProfileView


-(id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if(self) {
        [self commonInit];
    }
    
    return self;
}

-(instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if(self) {
        [self commonInit];
    }
    
    return self;
}

-(void)commonInit
{
    [[NSBundle mainBundle] loadNibNamed:NSStringFromClass(self.class)
                                  owner:self
                                options:nil];
    
    [self addSubview:self.guideDetailedProfileView];
    
    
    // set constraints for imageView to superview
    
    [self.guideDetailedProfileView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(@0);
    }];
    
}

@end
