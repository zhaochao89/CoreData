//
//  CoreDataManager.h
//  CoreData
//
//  Created by zhaochao on 17/1/9.
//  Copyright © 2017年 zhaochao. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@interface CoreDataManager : NSObject

@property (nonatomic, strong) NSManagedObjectContext *context;

+ (CoreDataManager *)manager;

- (void)initObjectContext;

- (id)createObjectOfEntity:(NSString *)name;

- (id)insertDataToEntity:(NSString *)name withParameter:(NSDictionary *)dict;

- (NSArray *)selectDataToEntity:(NSString *)name withPredicate:(NSPredicate *)predicate;

- (void)deleteObject:(NSObject *)object;

- (void)updateObject;

@end
