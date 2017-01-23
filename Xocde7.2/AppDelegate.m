//
//  AppDelegate.m
//  Xocde7.2
//
//  Created by Ernie Liu on 17/1/16.
//  Copyright © 2017年 Ernie Liu. All rights reserved.
//

#import "AppDelegate.h"
#import "MainViewController.h"
#import "NextViewController.h"
@interface AppDelegate ()

@property(nonatomic,strong) BMKMapManager   *mapManager;
@property(nonatomic,strong)CLLocationManager *locationManager ;
@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // 1.创建窗口
    self.window = [[UIWindow alloc] init];
    self.window.frame = [UIScreen mainScreen].bounds;
    
   NextViewController *vc = [[NextViewController alloc]init];
    UINavigationController *nv = [[UINavigationController alloc]initWithRootViewController:vc];
    self.window.rootViewController = nv;
    // 3.显示窗口
    [self.window makeKeyAndVisible];
    
    _mapManager=[[BMKMapManager alloc]  init];
    
    BOOL ret=[_mapManager start: @"C8yGGoDS08IN7QqcbzRwinjc6NPGOGEy" generalDelegate:nil];
    if(!ret){
        NSLog(@"Baidu Map Manager Start failed!");
        
        //init baidu navigation
    }
    if ([CLLocationManager locationServicesEnabled])
    {
        NSLog( @"Starting CLLocationManager" );
    }
    else
    {
        NSLog( @"Cannot Starting CLLocationManager" );
    }

    NSLog(@"ios系统为:%.2f",[[UIDevice currentDevice].systemVersion floatValue]);
    //系统定位功能
    if([[UIDevice currentDevice].systemVersion floatValue]>=8.0)
    {
    //初始化定位管理器
    self.locationManager = [[CLLocationManager alloc]init];
    //设置代理
    self.locationManager.delegate = self;
    //定位精准度
   // self.locationManager.desiredAccuracy = kCLLocationAccuracyBest;
         _locationManager.distanceFilter = kCLDistanceFilterNone;
    //横向移动多少距离后更新位置信息
    self.locationManager.distanceFilter = 10;
  [_locationManager requestAlwaysAuthorization];
   [_locationManager requestWhenInUseAuthorization];
        if ([self.locationManager respondsToSelector:@selector(requestAlwaysAuthorization)]) {
            [self.locationManager requestAlwaysAuthorization];
        }
    [self.locationManager startUpdatingLocation];
  }
     return YES;
}
#pragma - location manager

-(void)locationManager:(CLLocationManager *)manager didUpdateToLocation:(CLLocation *)newLocation fromLocation:(CLLocation *)oldLocation
{
    NSDictionary* testdic = BMKConvertBaiduCoorFrom(newLocation.coordinate,BMK_COORDTYPE_COMMON);
    //转换GPS坐标至百度坐标(加密后的坐标)
    testdic = BMKConvertBaiduCoorFrom(newLocation.coordinate,BMK_COORDTYPE_GPS);
    CLLocationCoordinate2D loc = newLocation.coordinate;
    //解密加密后的坐标字典
   // CLLocationCoordinate2D loc = BMKCoorDictionaryDecode(testdic);//转换后的百度坐标
    //纬度为
    float lat = loc.latitude;
    float log = loc.longitude;
    [UD setValue:[NSString stringWithFormat:@"%f",lat] forKey:@"baidu_current_lat"];
    [UD setValue:[NSString stringWithFormat:@"%f",log] forKey:@"baidu_current_long"];
   
    // 获取当前所在的地址
    //初始化地理信息编码类（CLGeocoder类相当于一个地址簿，保存了庞大的地址数据）
    CLGeocoder *geocoder = [[CLGeocoder alloc] init];
    //反地理编码
    [geocoder reverseGeocodeLocation:newLocation completionHandler:^(NSArray *array, NSError *error){
        //数组中包含了编译出的地标
        if (array.count > 0){
            //获取到编译出的地标（CLPlacemark是一个地标类，封装了经纬度，国家，城市等地址信息）
            CLPlacemark *placemark = [array objectAtIndex:0];
            //当前地址
//            self.labelAdress.text = placemark.name;
            NSLog(@"placemark.name = %@",placemark.name);
            //获取当前城市城市
            NSString *city = placemark.locality;
            if (!city) {
                //四大直辖市的城市信息无法通过locality获得，只能通过获取省份的方法来获得（如果city为空，则可知为直辖市）
                city = placemark.administrativeArea;
            }
            NSLog(@"city666 = %@", city);
            [UD setValue:city forKey:@"currentCity"];
          //  NSLog(@"addressDictionary = %@",placemark.addressDictionary);
            //地址字典：(该字典属性打包了所有获取到的有效的地理信息)打出字典中的每个元素查看
            /*
             FormattedAddressLines = (中国浙江省杭州市西湖区留下街道)
             Name = 中国浙江省杭州市西湖区留下街道
             City = 杭州市
             Country = 中国
             State = 浙江省
             SubLocality = 西湖区
             CountryCode = CN
             */
            /*
            NSLog(@"name = %@",placemark.name);
            //定位到的详细地址：name = 中国浙江省杭州市西湖区留下街道
            NSLog(@"thoroughfare = %@",placemark.thoroughfare);
            //街道地址：thoroughfare = (null)
            NSLog(@"subThoroughfare = %@",placemark.subThoroughfare);
            //其他街道级地标的信息：subThoroughfare = (null)
            NSLog(@"locality = %@",placemark.locality);
            //城市名（对于直辖市，用administrativeArea）：locality = 杭州市
            NSLog(@"subLocality = %@",placemark.subLocality);
            //其他城市级地标的信息：subLocality = 西湖区
            NSLog(@"administrativeArea = %@",placemark.administrativeArea);
            //行政区域：administrativeArea = 浙江省
            NSLog(@"subAdministrativeArea = %@",placemark.subAdministrativeArea);
            //其他行政区域坐标：subAdministrativeArea = (null)
            NSLog(@"postalCode = %@",placemark.postalCode);
            //邮编：postalCode = (null)
            NSLog(@"ISOcountryCode = %@",placemark.ISOcountryCode);
            //国家名缩写：ISOcountryCode = CN
            NSLog(@"country = %@",placemark.country);
            //国家：country = 中国
            NSLog(@"inlandWater = %@",placemark.inlandWater);
            //定位到的内陆水源名称：inlandWater = (null)
            NSLog(@"ocean = %@",placemark.ocean);
            //定位到的海洋：ocean = (null)
            NSLog(@"areasOfInterest = %@",placemark.areasOfInterest);
            //大的地标建筑：areasOfInterest = (null)
            */
        }
        
        else if (error == nil && [array count] == 0)
        {
            NSLog(@"No results were returned.");
        }
        else if (error != nil)
        {
            NSLog(@"An error occurred = %@", error);
        }
    }];
     [UD synchronize];
}
//定位失败时的回调
- (void)locationManager:(CLLocationManager *)manager
       didFailWithError:(NSError *)error{
    NSString *errMsg = nil;
    if ([error code] == kCLErrorDenied) {
        errMsg = @"访问被拒绝";
    }
    if ([error code] == kCLErrorLocationUnknown) {
        errMsg = @"获取位置信息失败";
    }
    UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"定位" message:errMsg delegate:nil cancelButtonTitle:@"确定" otherButtonTitles: nil];
    [alert show];
}
- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    // Saves changes in the application's managed object context before the application terminates.
    [self saveContext];
}

#pragma mark - Core Data stack

@synthesize managedObjectContext = _managedObjectContext;
@synthesize managedObjectModel = _managedObjectModel;
@synthesize persistentStoreCoordinator = _persistentStoreCoordinator;

- (NSURL *)applicationDocumentsDirectory {
    // The directory the application uses to store the Core Data store file. This code uses a directory named "-17lng.com.Xocde7_2" in the application's documents directory.
    return [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject];
}

- (NSManagedObjectModel *)managedObjectModel {
    // The managed object model for the application. It is a fatal error for the application not to be able to find and load its model.
    if (_managedObjectModel != nil) {
        return _managedObjectModel;
    }
    NSURL *modelURL = [[NSBundle mainBundle] URLForResource:@"Xocde7_2" withExtension:@"momd"];
    _managedObjectModel = [[NSManagedObjectModel alloc] initWithContentsOfURL:modelURL];
    return _managedObjectModel;
}

- (NSPersistentStoreCoordinator *)persistentStoreCoordinator {
    // The persistent store coordinator for the application. This implementation creates and returns a coordinator, having added the store for the application to it.
    if (_persistentStoreCoordinator != nil) {
        return _persistentStoreCoordinator;
    }
    
    // Create the coordinator and store
    
    _persistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:[self managedObjectModel]];
    NSURL *storeURL = [[self applicationDocumentsDirectory] URLByAppendingPathComponent:@"Xocde7_2.sqlite"];
    NSError *error = nil;
    NSString *failureReason = @"There was an error creating or loading the application's saved data.";
    if (![_persistentStoreCoordinator addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:storeURL options:nil error:&error]) {
        // Report any error we got.
        NSMutableDictionary *dict = [NSMutableDictionary dictionary];
        dict[NSLocalizedDescriptionKey] = @"Failed to initialize the application's saved data";
        dict[NSLocalizedFailureReasonErrorKey] = failureReason;
        dict[NSUnderlyingErrorKey] = error;
        error = [NSError errorWithDomain:@"YOUR_ERROR_DOMAIN" code:9999 userInfo:dict];
        // Replace this with code to handle the error appropriately.
        // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
        abort();
    }
    
    return _persistentStoreCoordinator;
}


- (NSManagedObjectContext *)managedObjectContext {
    // Returns the managed object context for the application (which is already bound to the persistent store coordinator for the application.)
    if (_managedObjectContext != nil) {
        return _managedObjectContext;
    }
    
    NSPersistentStoreCoordinator *coordinator = [self persistentStoreCoordinator];
    if (!coordinator) {
        return nil;
    }
    _managedObjectContext = [[NSManagedObjectContext alloc] initWithConcurrencyType:NSMainQueueConcurrencyType];
    [_managedObjectContext setPersistentStoreCoordinator:coordinator];
    return _managedObjectContext;
}

#pragma mark - Core Data Saving support

- (void)saveContext {
    NSManagedObjectContext *managedObjectContext = self.managedObjectContext;
    if (managedObjectContext != nil) {
        NSError *error = nil;
        if ([managedObjectContext hasChanges] && ![managedObjectContext save:&error]) {
            // Replace this implementation with code to handle the error appropriately.
            // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
            NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
            abort();
        }
    }
}

@end
