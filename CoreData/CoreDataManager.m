//
//  CoreDataManager.m
//  CoreData
//
//  Created by zhaochao on 17/1/9.
//  Copyright © 2017年 zhaochao. All rights reserved.
//

#import "CoreDataManager.h"

@interface CoreDataManager ()

@property (nonatomic, strong) NSManagedObjectModel *managedObjectModel;

@end

@implementation CoreDataManager

+ (CoreDataManager *)manager {
    static CoreDataManager *_m = nil;
    if (_m == nil) {
        _m = [[CoreDataManager alloc] init];
    }
    return _m;
}

- (void)initObjectContext {
    //1、创建托管对象，并使用CoreData.momd路径作为初始化参数
    NSURL *modelUrl = [[NSBundle mainBundle] URLForResource:@"CoreData" withExtension:@"momd"];
    NSManagedObjectModel *model = [[NSManagedObjectModel alloc] initWithContentsOfURL:modelUrl];
    //2、创建持久化储存调度器
    NSPersistentStoreCoordinator *psc = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:model];
    //3、创建并关联SQLite数据库文件，如果存在则不会重复创建
    NSString *dataPath = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES).lastObject;
    dataPath = [dataPath stringByAppendingPathComponent:@"CoreData.sqlite"];
    NSLog(@"\n dataPath = %@ \n",dataPath);
    NSError *error = nil;
    //设置版本迁移方案
    NSDictionary *options = @{NSMigratePersistentStoresAutomaticallyOption : @YES,
                              NSInferMappingModelAutomaticallyOption : @YES};
    //创建持久化存储协调器，并将迁移方案的字典当做参数传入(注：这个地方的URL必须用fileURL，否则会报错)
    [psc addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:[NSURL fileURLWithPath:dataPath] options:options error:&error];
    if (error) {
        NSLog(@"创建SQLite数据库失败!");
    }
    //4、创建上下文对象，并设置为私有并发队列类型
    self.context = [[NSManagedObjectContext alloc] initWithConcurrencyType:NSPrivateQueueConcurrencyType];
    self.context.persistentStoreCoordinator = psc;
}

- (id)createObjectOfEntity:(NSString *)name {
    return [NSEntityDescription insertNewObjectForEntityForName:name inManagedObjectContext:self.context];
}

- (id)insertDataToEntity:(NSString *)name withParameter:(NSDictionary *)dict {
    //创建托管对象，并指定托管对象对象所属的实体名
    NSManagedObject *mo = [NSEntityDescription insertNewObjectForEntityForName:name inManagedObjectContext:self.context];
    if (dict) {
        for (NSString *key in dict.allKeys) {
            if (dict[key] == [NSNull null]) {
                continue;
            }
            [mo setValue:dict[key] forKey:key];
        }
        //通过上下文保存对象，并在保存之前判断是否有更改
        if (self.context.hasChanges) {
            NSError *error = nil;
            [self.context save:&error];
            if (error) {
                NSLog(@"保存数据失败 %@",error.localizedDescription);
            }
        }
    }
    return mo;
}

- (NSArray *)selectDataToEntity:(NSString *)name withPredicate:(NSPredicate *)predicate {
    //建立数据库的请求对象,并关联哪个实体名
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:name];
    [request setPredicate:predicate];
    
    NSError *error = nil;
    NSArray *list = [self.context executeFetchRequest:request error:&error];
    if (error) {
        NSLog(@"查询信息失败");
    }
    return list;
}

- (void)deleteObject:(NSObject *)object {
    [self.context deleteObject:(NSManagedObject *)object];
    if (self.context.hasChanges) {
        NSError *error = nil;
        [self.context save:&error];
        if (error) {
            NSLog(@"删除失败");
        } else {
            NSLog(@"删除成功");
        }
    }
}

- (void)updateObject {
    if ([self.context hasChanges]) {
        NSError *error = nil;
        [self.context save:&error];
        if (error) {
            NSLog(@"更新失败");
        } else {
            NSLog(@"更新成功");
        }
    }
}

@end
