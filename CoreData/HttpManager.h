//
//  HttpManager.h
//  CoreData
//
//  Created by zhaochao on 17/1/9.
//  Copyright © 2017年 zhaochao. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface HttpManager : NSObject

+ (void)getDataWithUrl:(NSString *)url SuccessBlock:(void(^)(id obj))success failureBlock:(void(^)(NSError *error))failure;


@end
