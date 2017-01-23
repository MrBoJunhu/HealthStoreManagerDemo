//
//  ViewController.m
//  HealthStoreTestDemo
//
//  Created by BillBo on 17/1/18.
//  Copyright © 2017年 BillBo. All rights reserved.
//

#import "ViewController.h"

@interface ViewController ()<UITableViewDelegate, UITableViewDataSource>

@property (weak, nonatomic) IBOutlet UITableView *myTBV;

@property (nonatomic, assign) NSInteger todaySteps;

@property (nonatomic, strong) HealthStoreManager *storeManager;

@end

@implementation ViewController

- (void)viewDidLoad {
   
    [super viewDidLoad];
    
    _myTBV.delegate = self;
    
    _myTBV.dataSource = self;
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(getTodayStepCount) name:UIApplicationWillEnterForegroundNotification object:nil];

}

- (void)viewWillAppear:(BOOL)animated{
    
    [super viewWillAppear:animated];
   
}

- (void)viewDidAppear:(BOOL)animated {
    
    [super viewDidAppear:animated];
    
    [self getTodayStepCount];

    
}

#pragma mark - 通知

- (void)getTodayStepCount {
 
    _storeManager  = [HealthStoreManager shareHealthStoreManager];
    
    [_storeManager getTodayStepsFromPhoneSetCurrentDevice:nil completionHandle:^(double HealthStepCount, NSError *error) {
        
        _todaySteps = (NSInteger)HealthStepCount;
        
        dispatch_async(dispatch_get_main_queue(), ^{
            
            [_myTBV reloadData];
            
        });
        
    }];
    
    
}



#pragma mark - tableview delegate  and datasource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    
    return 1;
    
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    return 4;
    
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static  NSString *cell_string = @"cell_1";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cell_string];
    
    if (!cell) {
        
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:cell_string];
        
    }

    cell.textLabel.text = [NSString stringWithFormat:@"%ld", _todaySteps];

    return cell;
    
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    return 60;
    
}


- (void)dealloc {
    
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIApplicationWillEnterForegroundNotification object:nil];
    
}

@end
