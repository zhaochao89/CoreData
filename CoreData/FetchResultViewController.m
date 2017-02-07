//
//  FetchResultViewController.m
//  CoreData
//
//  Created by zhaochao on 2017/1/23.
//  Copyright © 2017年 zhaochao. All rights reserved.
//

#import "FetchResultViewController.h"
#import <CoreData/NSFetchedResultsController.h>
#import "Employee+CoreDataClass.h"
#import "CoreDataManager.h"

@interface FetchResultViewController () <UITableViewDataSource, UITableViewDelegate, NSFetchedResultsControllerDelegate>

@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) NSFetchedResultsController *fetchedResultController;

@end

@implementation FetchResultViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.title = @"结果页";
    
    self.view.backgroundColor = [UIColor whiteColor];
    [self setupNavi];
    [self setupView];
}

- (void)setupNavi {
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(addEmployee)];
}

- (void)addEmployee {
    [self insertData];
}
static int count = 5;
- (void)insertData {
    count ++;
    NSDictionary *dict = @{
                           @"name" : [NSString stringWithFormat:@"张三_%d",count],
                           @"sessionName" : @"创达",
                           @"height" : @(arc4random_uniform(170)),
                           @"brithday" : [NSDate date]
                           };
    
    [[CoreDataManager manager] insertDataToEntity:NSStringFromClass([Employee class]) withParameter:dict];
}

- (void)setupView {
    self.tableView = [[UITableView alloc] initWithFrame:self.view.bounds];
    self.tableView.dataSource = self;
    self.tableView.delegate = self;
    [self.view addSubview:self.tableView];
    
    NSFetchRequest *fetchRequest = [NSFetchRequest fetchRequestWithEntityName:NSStringFromClass([Employee class])];
    //fetchRequest需要一个sortDescriptors，不然会报错
    NSSortDescriptor *heightSort = [NSSortDescriptor sortDescriptorWithKey:@"height" ascending:YES];
    fetchRequest.sortDescriptors = @[heightSort];
    // 创建NSFetchedResultsController控制器实例，并绑定MOC
    self.fetchedResultController = [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest managedObjectContext:[CoreDataManager manager].context sectionNameKeyPath:@"sessionName" cacheName:nil];
    self.fetchedResultController.delegate = self;
    NSError *error = nil;
    // 执行获取请求，执行后FRC会从持久化存储区加载数据，其他地方可以通过FRC获取数据
    [self.fetchedResultController performFetch:&error];
    if (error) {
        NSLog(@"fetchedResultController performFetch error %@",error);
    }
    [self.tableView reloadData];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark -UITableViewDataSource
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return self.fetchedResultController.sections.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.fetchedResultController.sections[section].numberOfObjects;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cellID"];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:@"cellID"];
    }
    Employee *e = [self.fetchedResultController objectAtIndexPath:indexPath];
    cell.textLabel.text = e.name;
    cell.detailTextLabel.text = [NSString stringWithFormat:@"%f",e.height];
    return cell;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    return self.fetchedResultController.sections[section].name;
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    return YES;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        Employee *e = [self.fetchedResultController objectAtIndexPath:indexPath];
        [[CoreDataManager manager] deleteObject:e];
    }
}

#pragma mark -NSFetchedResultsControllerDelegate
- (void)controller:(NSFetchedResultsController *)controller didChangeObject:(id)anObject atIndexPath:(NSIndexPath *)indexPath forChangeType:(NSFetchedResultsChangeType)type newIndexPath:(NSIndexPath *)newIndexPath {
    switch (type) {
        case NSFetchedResultsChangeInsert:
            if (self.fetchedResultController.sections.count == 0) {
                [self.tableView insertSections:[NSIndexSet indexSetWithIndex:indexPath.section] withRowAnimation:UITableViewRowAnimationAutomatic];
            }
            [self.tableView insertRowsAtIndexPaths:@[newIndexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
            break;
        case NSFetchedResultsChangeDelete:
            if ([self.fetchedResultController.sections indexOfObject:anObject]) {
                [self.tableView deleteSections:[NSIndexSet indexSetWithIndex:indexPath.section] withRowAnimation:UITableViewRowAnimationAutomatic];
            }
            [self.tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
            break;
        case NSFetchedResultsChangeMove:
            [self.tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
            [self.tableView insertRowsAtIndexPaths:@[newIndexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
            break;
        case NSFetchedResultsChangeUpdate: {
            UITableViewCell *cell = [self.tableView cellForRowAtIndexPath:indexPath];
            Employee *emp = [self.fetchedResultController objectAtIndexPath:indexPath];
            cell.textLabel.text = emp.name;
            cell.detailTextLabel.text = [NSString stringWithFormat:@"%f",emp.height];
        }
            break;
    }
}

- (void)controllerWillChangeContent:(NSFetchedResultsController *)controller {
    [self.tableView beginUpdates];
}

- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller {
    [self.tableView endUpdates];
}


/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
