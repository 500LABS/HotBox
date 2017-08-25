//
//  HotBoxPublisher.m
//  hotbox
//
//  Created by George Lim on 2017-08-08.
//  Copyright © 2017 George Lim. All rights reserved.
//

#import "HotBoxPublisher.h"
#import <React/RCTViewManager.h>

@interface RCT_EXTERN_MODULE(HotBoxPublisherSwift, RCTViewManager)
RCT_EXPORT_VIEW_PROPERTY(borderWidth, CGFloat)
//RCT_EXPORT_VIEW_PROPERTY(useAlpha, Bool)
@end
