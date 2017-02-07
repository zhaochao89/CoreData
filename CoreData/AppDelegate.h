//
//  AppDelegate.h
//  CoreData
//
//  Created by zhaochao on 17/1/9.
//  Copyright © 2017年 zhaochao. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreData/CoreData.h>

@interface AppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;

@property (readonly, strong) NSPersistentContainer *persistentContainer;

- (void)saveContext;


@end

