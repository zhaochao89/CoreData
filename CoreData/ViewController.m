//
//  ViewController.m
//  CoreData
//
//  Created by zhaochao on 17/1/9.
//  Copyright © 2017年 zhaochao. All rights reserved.
//

#import "ViewController.h"
#import "HttpManager.h"
#import "CoreDataManager.h"
#import "Department+CoreDataClass.h"
#import "Employee+CoreDataClass.h"
#import "FetchResultViewController.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    self.title = @"首页";
    
    [[CoreDataManager manager] initObjectContext];
    
//    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"(height < %f) AND (name = %@)",170.f,@"张三_2"];
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"height < 170"];
    
    
    NSArray *list = [[CoreDataManager manager] selectDataToEntity:NSStringFromClass([Employee class]) withPredicate:predicate];
    for (Employee *object in list) {
        NSLog(@"%@",object.name);
    }
    list = [list filteredArrayUsingPredicate:predicate];
    for (Employee *object in list) {
        NSLog(@"\n %@",object.name);
    }
    
    
}

static int count = 0;
- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
//    [self insertData];
    FetchResultViewController *fetchResultVC = [[FetchResultViewController alloc] init];
    [self.navigationController pushViewController:fetchResultVC animated:YES];
}

//异步请求
- (void)asycFetchRequest {
    NSFetchRequest *fetchRequest = [NSFetchRequest fetchRequestWithEntityName:NSStringFromClass([Employee class])];
    NSAsynchronousFetchRequest *asyncRequest = [[NSAsynchronousFetchRequest alloc] initWithFetchRequest:fetchRequest completionBlock:^(NSAsynchronousFetchResult * _Nonnull result) {
        NSArray *arr = result.finalResult;
        for (Employee *e in arr) {
            NSLog(@"name %@ height %f sessionName %@",e.name,e.height,e.sessionName);
        }
    }];
    NSError *error = nil;
    [[CoreDataManager manager].context executeRequest:asyncRequest error:&error];
    if (error) {
        NSLog(@"asycFetch error %@",error);
    }
}

- (void)batchDelete {
    NSFetchRequest *fetchRequest = [NSFetchRequest fetchRequestWithEntityName:NSStringFromClass([Employee class])];
    NSBatchDeleteRequest *deleteRequest = [[NSBatchDeleteRequest alloc] initWithFetchRequest:fetchRequest];
    deleteRequest.resultType = NSBatchDeleteResultTypeCount;
    NSError *error = nil;
    NSBatchDeleteResult *result = [[CoreDataManager manager].context executeRequest:deleteRequest error:&error];
    NSLog(@"batch delete count %d",[result.result intValue]);
    if (error) {
        NSLog(@"batch delete error %@",error);
    }
    // 更新MOC中的托管对象，使MOC和本地持久化区数据同步
    [[CoreDataManager manager].context refreshAllObjects];
}

- (void)batchUpdate {
    NSBatchUpdateRequest *request = [NSBatchUpdateRequest batchUpdateRequestWithEntityName:NSStringFromClass([Employee class])];
    //指定返回类型
    request.resultType = NSUpdatedObjectsCountResultType;
    //更新数据（字典格式）
    request.propertiesToUpdate = @{@"height" : @180,@"sessionName" : @"灵达"};
    //指定过滤条件，可用不指定
//    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"sessionName = %@",@"灵达"];
//    request.predicate = predicate;
    NSError *error = nil;
    NSBatchUpdateResult *result = [[CoreDataManager manager].context executeRequest:request error:&error];
    NSLog(@"update count is %d",[result.result intValue]);
    if (error) {
        NSLog(@"batch update error %@",error);
    }
    // 更新MOC中的托管对象，使MOC和本地持久化区数据同步
    [[CoreDataManager manager].context refreshAllObjects];
}

- (void)updateData {
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"sessionName = %@",@"灵达"];
    NSArray *list = [[CoreDataManager manager] selectDataToEntity:NSStringFromClass([Employee class]) withPredicate:predicate];
    [list enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        Employee *employee = (Employee *)obj;
        employee.height = 180.f;
    }];
    [[CoreDataManager manager] updateObject];
}

- (void)deleteData {
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"name = %@",@"张三"];
    NSArray *list = [[CoreDataManager manager] selectDataToEntity:NSStringFromClass([Employee class]) withPredicate:predicate];
    [list enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        [[CoreDataManager manager] deleteObject:obj];
    }];
}

- (void)insertData {
    count ++;
    NSDictionary *dict = @{
                           @"name" : [NSString stringWithFormat:@"张三_%d",count],
                           @"sessionName" : @"灵达",
                           @"height" : @170,
                           @"brithday" : [NSDate date]
                           };
    
    [[CoreDataManager manager] insertDataToEntity:NSStringFromClass([Employee class]) withParameter:dict];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
