//
//  HealthStoreManager.m
//  LaiApp_OC
//
//  Created by BillBo on 17/1/12.
//  Copyright © 2017年 Softtek. All rights reserved.
//

#import "HealthStoreManager.h"

@interface HealthStoreManager()

@property (nonatomic, strong) HKHealthStore * healthStore;


@end

@implementation HealthStoreManager

+(HealthStoreManager *)shareHealthStoreManager {
    
    static HealthStoreManager *manager = nil;
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        
        manager = [[self alloc] init];
        
    });
    
    return manager;
    
}


- (void)authorizeHealthKit:(CompletionHandle)completionHandle {

    if (IOS_systemVersion >= 8.0) {
        
        //当前设备有计步功能
        if ([HKHealthStore isHealthDataAvailable]) {
            
            DebugLog(@"可以访问健康");
            //允许读取健康权限
            
            if (self.healthStore == nil) {
                
                self.healthStore = [[HKHealthStore alloc] init];
                
            }
            
            NSSet *dataTypeSet = [self healthStoreDataType];
            
            [self.healthStore requestAuthorizationToShareTypes:nil readTypes:dataTypeSet completion:^(BOOL success, NSError * _Nullable error) {
                
                completionHandle(success, error);
                
            }];
            
        }else{
            
            DebugLog(@"无法访问健康权限");
            
            NSError *error;
            
            completionHandle(NO,error);
            
        }
        
    }else{
        
#pragma mark - 当前设备没有计步功能
        [self showErrorViewSupportStep:NO];
        
    }
    
}



/**
 需要获取健康的权限类型

 @return 权限集合
 */
-(NSSet *)healthStoreDataType{
    
    HKQuantityType *stepCountType = [HKQuantityType quantityTypeForIdentifier:HKQuantityTypeIdentifierStepCount];
    
    
    return [NSSet setWithObjects:stepCountType, nil];
    
}


- (void)getStepCount:(ResultCompletionHandle)completion {
    
    @weakify(self);
    
    [self authorizeHealthKit:^(BOOL success, NSError *error) {
       
        if (success) {
            
            HKQuantityType *stepQuantityType = [HKQuantityType quantityTypeForIdentifier:HKQuantityTypeIdentifierStepCount];
            
            NSSortDescriptor *sortDescriptor = [NSSortDescriptor sortDescriptorWithKey:HKSampleSortIdentifierEndDate ascending:NO];
            
            HKSampleQuery *samleQuery = [[HKSampleQuery alloc] initWithSampleType:stepQuantityType predicate:[self predicateForSamplesToday] limit:HKObjectQueryNoLimit sortDescriptors:@[sortDescriptor] resultsHandler:^(HKSampleQuery * _Nonnull query, NSArray<__kindof HKSample *> * _Nullable results, NSError * _Nullable error) {
                
                if (error) {
                    
                    completion(NO, error);
                    
                }else{
                    
                    NSInteger totalSteps = 0;
                    
                    for (HKQuantitySample *smaple in results) {
                        
                        HKQuantity *quantity = smaple.quantity;
                        
                        HKUnit *countUnit  = [HKUnit countUnit];
                        
                        double usersHeight = [quantity doubleValueForUnit:countUnit];
                        
                        DebugLog(@"分段步数 ： usersHeight : %f \n", usersHeight);
                        
                        totalSteps += usersHeight;
                        
                    }
                    
                    completion(totalSteps, error);
                    
                }
                
            }];
            
            [weakself.healthStore executeQuery:samleQuery];
            
        }
        
    }];
    
   
    
}


- (NSPredicate *)predicateForSamplesToday {

    NSCalendar *calendar = [NSCalendar currentCalendar];
    
    NSDate *now = [NSDate date];
    
    NSDateComponents *components = [calendar components:NSCalendarUnitYear|NSCalendarUnitMonth|NSCalendarUnitDay fromDate:now];
    
    [components setHour:0];
    
    [components setMinute:0];
    
    [components setSecond: 0];
    
    NSDate *startDate = [calendar dateFromComponents:components];
    
    NSDate *endDate = [calendar dateByAddingUnit:NSCalendarUnitDay value:1 toDate:startDate options:0];
    
    NSPredicate *predicate = [HKQuery predicateForSamplesWithStartDate:startDate endDate:endDate options:HKQueryOptionNone];
    
    return predicate;

}


#pragma mark - today steps

- (void)getTodayStepsFromPhoneSetCurrentDevice:(NSString *)currentDevice completionHandle:(ResultCompletionHandle)completion {
    
    @weakify(self);
    
    [self authorizeHealthKit:^(BOOL success, NSError *error) {
        
        if (success) {
            
            HKQuantityType *quantityType = [HKQuantityType quantityTypeForIdentifier:HKQuantityTypeIdentifierStepCount];
            
            NSDateComponents *dateComponents = [[NSDateComponents alloc] init];
            
            dateComponents.day = 1;
            
            HKStatisticsCollectionQuery *collectionQuery = [[HKStatisticsCollectionQuery alloc] initWithQuantityType:quantityType quantitySamplePredicate:[self predicateForSamplesToday] options: HKStatisticsOptionCumulativeSum | HKStatisticsOptionSeparateBySource anchorDate:[NSDate date] intervalComponents:dateComponents];
            
            collectionQuery.initialResultsHandler = ^(HKStatisticsCollectionQuery *query, HKStatisticsCollection * __nullable result, NSError * __nullable error) {
                
                DebugLog(@" %@", [result class]);
                
                DebugLog(@"%lu", result.statistics.count);
                
                if (result.statistics.count > 0) {
                    
                }else{
                    
                    [weakself showErrorViewSupportStep:YES];
                    
                    return ;
                }
                
                
                for (HKStatistics *statistic in result.statistics) {
                    
                    if (currentDevice != nil) {
                        
#pragma mark - 防作弊 指定计步设备
                        
                        for (HKSource *source in statistic.sources) {
                            
                            if ([source.name isEqualToString:currentDevice]) {
                                
                                HKQuantity *quantity = [statistic sumQuantityForSource:source];
                                
                                HKUnit *unit = [HKUnit countUnit];
                                
                                double todatyStepCount = [quantity doubleValueForUnit:unit];
                                
                                DebugLog(@"%@ -- %f",source.name, todatyStepCount);
                                
                                completion(todatyStepCount, nil);
                                
                            }else{
                                
                                HKQuantity *quantity = [statistic sumQuantityForSource:source];
                                
                                HKUnit *unit = [HKUnit countUnit];
                                
                                double todatyStepCount = [quantity doubleValueForUnit:unit];
                                
                                DebugLog(@"其他设备  %@ -- %f",source.name,todatyStepCount);
                                
                            }
                            
                        }
                        
                    }else{
                        
#pragma mark - 忽略作弊
                        
                        HKUnit *unit = [HKUnit countUnit];
                        
                        double todatyStepCount = [statistic.sumQuantity doubleValueForUnit:unit];
                        
                        completion(todatyStepCount, nil);
                        
                        DebugLog(@"❤❤❤❤❤❤❤❤❤  %d  ❤❤❤❤❤❤❤❤❤", (int)todatyStepCount);
                        
                    }
                    
                }
            };
            
            [_healthStore executeQuery:collectionQuery];
            
        }else{
            
            [weakself showErrorViewSupportStep:NO];
            
        }
        
    }];
    
    
}


#pragma mark -  权限提示

- (void)showErrorViewSupportStep:(BOOL)supportBool {
    
    NSString *remindMessage ;
    
    if (supportBool) {
        
        remindMessage = @"请在「设置」>「隐私」>「健康」中,确保「莱聚+」的步数功能已开启或者「健康」中的今日步数已更新，否则将无法读取步数";
        
    }else{
        
        remindMessage = @"Duang~ 您手机型号不支持记步, 莱聚+无法提供计步数据哦...";
        
    }
    
    UIAlertController *alertC = [UIAlertController alertControllerWithTitle:@"温馨提示" message:remindMessage preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction *action = [UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:nil];
    
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:nil];
    
    [alertC addAction:cancelAction];
    
    [alertC addAction:action];
    
    [[UIApplication sharedApplication].keyWindow.rootViewController presentViewController:alertC animated:YES completion:nil];
    
}



@end
