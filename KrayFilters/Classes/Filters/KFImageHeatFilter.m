//
//  KFImageHeatFilter.m
//  KrayFilters
//
//  Created by Mark Glagola on 5/26/13.
//  Copyright (c) 2013 Mark Glagola. All rights reserved.
//

#import "KFImageHeatFilter.h"

@implementation KFImageHeatFilter

- (id) init {
    return [self initWithFragmentShaderFromFile:@"KFImageHeatFilter"];
}

@end
