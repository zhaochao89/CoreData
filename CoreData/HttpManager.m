//
//  HttpManager.m
//  CoreData
//
//  Created by zhaochao on 17/1/9.
//  Copyright © 2017年 zhaochao. All rights reserved.
//sch_id

#define kBaseUrl @"http://m.wxsgo.com/API/App/"
#define kGetSchoolList @"Locate.ashx?callBack=GetSchool"
#define kGetHouse @"Locate.ashx?callBack=GetHouse"

#import "HttpManager.h"

@implementation HttpManager

+ (void)getDataWithUrl:(NSString *)url SuccessBlock:(void (^)(id))success failureBlock:(void (^)(NSError *))failure {
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@%@",kBaseUrl,url]]];
    
    NSURLSession *urlSession = [NSURLSession sharedSession];
    NSURLSessionDataTask *dataTask = [urlSession dataTaskWithRequest:request completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        if (error == nil) {
            NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:nil];
            if (success) {
                success(dict);
            }
        } else {
            if (failure) {
                failure(error);
            }
        }
    }];
    NSLog(@"%@ \n %@\n",dataTask.originalRequest.URL,[[NSString alloc] initWithData:dataTask.originalRequest.HTTPBody encoding:NSUTF8StringEncoding]);
    [dataTask resume];
}



@end
