
#import <Foundation/Foundation.h>

typedef void(^CompletionHandle)(BOOL success, NSError *error);

typedef void(^ResultCompletionHandle)(double HealthStepCount, NSError *error);

@interface HealthStoreManager : NSObject

+(HealthStoreManager *)shareHealthStoreManager;


/**
 获取健康 步数（所有数据源步数之和）

 @param completion 
 */
-(void)getStepCount:(ResultCompletionHandle)completion;

/**
 获取手机健康 直接显示的步数 (可以忽略第三方设备的切换)
 
 @param currentDevice currentDevice description  指定设备优先级，为nil忽略第三方设备
 @param completion completion description
 */
- (void)getTodayStepsFromPhoneSetCurrentDevice:(NSString *)currentDevice completionHandle:(ResultCompletionHandle)completion;

@end
