//
//  OpenCVWrapper.h
//  PSS
//
//  Created by Curtis Cheung on 2018-10-24.
//  Copyright © 2018 CMPT275_G3. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
NS_ASSUME_NONNULL_BEGIN

@interface OpenCVWrapper : NSObject
+ (NSString *)openCVVersionString;
- (double) isImageBlurry:(UIImage *) image;

@end




NS_ASSUME_NONNULL_END
