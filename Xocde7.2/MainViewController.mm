//
//  MainViewController.m
//  Xocde7.2
//
//  Created by Ernie Liu on 17/1/16.
//  Copyright © 2017年 Ernie Liu. All rights reserved.
//

#import "MainViewController.h"
#import "UIImage+DLExtension.h"
#import "ThreePageController.h"
#import <Foundation/Foundation.h>
#import <ImageIO/ImageIO.h>
#define MYBUNDLE_NAME @ "mapapi.bundle"
#define MYBUNDLE_PATH [[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent: MYBUNDLE_NAME]
#define MYBUNDLE [NSBundle bundleWithPath: MYBUNDLE_PATH]

/**
 *  路线的标注
 */
@interface RouteAnnotation : BMKPointAnnotation
{
    int _type; ///<0:起点 1：终点 2：公交 3：地铁 4:驾乘 5:途经点
    int _degree;
}

@property (nonatomic) int type;
@property (nonatomic) int degree;
@end

@implementation RouteAnnotation

@synthesize type = _type;
@synthesize degree = _degree;
@end

@interface MainViewController ()
{
    
    BMKMapView *_mapView;
    BMKPointAnnotation *pointAnnotation;
    UIView *bigView;
    UIImageView *loadingImageView1 ;
    

}
@property (weak, nonatomic) IBOutlet UILabel *pointLab;
@property (weak, nonatomic) IBOutlet UIView *backView;
@property (weak, nonatomic) IBOutlet UILabel *locationLab;
@property (nonatomic) CGImage *CGImage;
@property (nonatomic) BMKRouteSearch *routeSearch_TIME_FIRST;//用时最短
@property (nonatomic) BMKRouteSearch *routeSearch_FEE_FIRST;//少走高速
@property(nonatomic,retain)BMKRouteSearch *routesearch;
@end

@implementation MainViewController
-(BMKGeoCodeSearch*)geocodesearch{
    if(!_geocodesearch){
        _geocodesearch=[[BMKGeoCodeSearch alloc]  init];
        _geocodesearch.delegate=self;
    }
    return _geocodesearch;
}
-(BMKLocationService*)locService{
    if(!_locService){
        _locService=[[BMKLocationService alloc]  init];
        _locService.delegate=self;
    }
    return _locService;
}
-(void)viewWillAppear:(BOOL)animated
{
    _mapView.delegate = self;
    [self createDelayLoad];
    //创建当前位置点
    pointAnnotation = [[BMKPointAnnotation alloc]init];
    pointAnnotation.title = @"当前位置";
    pointAnnotation.coordinate =  (CLLocationCoordinate2D){[[UD objectForKey:@"baidu_current_lat"] floatValue],[[UD objectForKey:@"baidu_current_long"] floatValue]};
    [_mapView addAnnotation:pointAnnotation];
    _routesearch = [[BMKRouteSearch alloc]init];
    _routesearch.delegate = self;
    //驾车路线
    [self showDriveSearch: BMK_DRIVING_TIME_FIRST];//用时最短 少走高速 BMK_DRIVING_FEE_FIRST
    [self updateAddress];
}

-(void)viewDidDisappear:(BOOL)animated
{
    _mapView.delegate = nil;
     _routesearch.delegate = nil;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"首页";
//    [self setRouteSearch_TIME_FIRST:[[BMKRouteSearch alloc] init]];
//    self.routeSearch_TIME_FIRST.delegate = self;
//    [self setRouteSearch_FEE_FIRST:[[BMKRouteSearch alloc] init]];
//    self.routeSearch_FEE_FIRST.delegate = self;
   //创建检索对象
    
    _mapView = [[BMKMapView alloc] initWithFrame:CGRectMake(0, self.backView.bounds.origin.y, Screen_Width, 420)];
    // _mapView.frame = self.mapBackView.bounds;
    [_mapView setMapType:BMKMapTypeStandard];
    [_mapView setZoomEnabled:YES];//设置地图是否允许 多点缩放
    _mapView.delegate = self;
    [_mapView setZoomLevel:10];//级别，3-19(13)
    _mapView.showMapScaleBar = YES;
    _mapView.centerCoordinate = (CLLocationCoordinate2D){[[UD objectForKey:@"baidu_current_lat"] floatValue],[[UD objectForKey:@"baidu_current_long"] floatValue]};
    [self.backView addSubview:_mapView];
    self.pointLab.text = [NSString stringWithFormat:@"%@ , %@",[UD objectForKey:@"baidu_current_lat"] ,[UD objectForKey:@"baidu_current_long"]];
  // self.locationLab.text = [UD objectForKey:@"currentCity"];
    //_mapView.overlooking = -45;
    
    NSLog(@"屏幕宽度:%.1f,m宽度:%.1f,gaodu:%.1f",Screen_Width,self.backView.bounds.size.width,self.view.bounds.size.height);
    
   
   
}
#pragma mark 自驾路线规划
-(void)showDriveSearch:(BMKDrivingPolicy) drivingPolicy  //第一步  创建驾车查询类
{
    //线路检索节点信息
    BMKPlanNode *start = [[BMKPlanNode alloc]init];
    start.pt =  CLLocationCoordinate2DMake(30.460995, 114.410877);//起点 武汉
    start.cityName = @"武汉";
    //终点
     BMKPlanNode *end = [[BMKPlanNode alloc]init];
    end.pt  = CLLocationCoordinate2DMake(23.8, 113.17);//广州
   // end.pt  = CLLocationCoordinate2DMake(30.3694, 113.4593);//终点 仙桃
    end.cityName = @"仙桃";
    BMKDrivingRoutePlanOption *drivingRouteSearchOption = [[BMKDrivingRoutePlanOption alloc] init];
    drivingRouteSearchOption.from = start;
    drivingRouteSearchOption.to = end;
     drivingRouteSearchOption.drivingPolicy=drivingPolicy;//路线选项
      drivingRouteSearchOption.drivingRequestTrafficType = BMK_DRIVING_REQUEST_TRAFFICE_TYPE_PATH_AND_TRAFFICE;//带路况
    BOOL flag = [_routesearch drivingSearch:drivingRouteSearchOption];//这个执行后 才会调用 代理方法
    if (flag) {
        NSLog(@"car检索成功");
    }
    else
    {
        NSLog(@"car检索失败");

    }
}
#pragma mark 返回驾乘搜索结果 －－第二步 执行驾乘的搜索结果及把点标注在地图上并连成一条线
- (void)onGetDrivingRouteResult:(BMKRouteSearch*)searcher result:(BMKDrivingRouteResult*)result errorCode:(BMKSearchErrorCode)error
{
    NSLog(@"+++%d",error);
    NSArray* array = [NSArray arrayWithArray:_mapView.annotations];
  // [_mapView removeAnnotations:array];
    //array = [NSArray arrayWithArray:_mapView.overlays];
   // [_mapView removeOverlays:array];
    if (error == BMK_SEARCH_NO_ERROR) {
        //表示一条驾车路线
        BMKDrivingRouteLine* plan = (BMKDrivingRouteLine*)[result.routes objectAtIndex:0];
        // 计算路线方案中的路段数目
        int size = (int)[plan.steps count];
        int planPointCounts = 0;
        for (int i = 0; i < size; i++) {
            //表示驾车路线中的一个路段
            BMKDrivingStep* transitStep = [plan.steps objectAtIndex:i];
            if(i==0){
                RouteAnnotation* item = [[RouteAnnotation alloc]init];
                item.coordinate = plan.starting.location;
                item.title = @"起点";
                item.type = 0;
                [_mapView addAnnotation:item]; // 添加起点标注 后调用mapView的代理方法
                
            }else if(i==size-1){
                RouteAnnotation* item = [[RouteAnnotation alloc]init];
                item.coordinate = plan.terminal.location;
                item.title = @"终点";
                item.type = 1;
                [_mapView addAnnotation:item]; // 添加终点标注
            }
            //添加annotation节点
            RouteAnnotation* item = [[RouteAnnotation alloc]init];
            item.coordinate = transitStep.entrace.location;
            item.title = transitStep.entraceInstruction;
            item.degree = transitStep.direction * 30;
            item.type = 4;
            [_mapView addAnnotation:item];
            
            //轨迹点总数累计
            planPointCounts += transitStep.pointsCount;
        }
        // 添加途经点
        if (plan.wayPoints) {
            for (BMKPlanNode* tempNode in plan.wayPoints) {
                RouteAnnotation* item = [[RouteAnnotation alloc]init];
                item.coordinate = tempNode.pt;
                item.type = 5;
                item.title = tempNode.name;
                NSLog(@"途经点:%@",item.title);
                [_mapView addAnnotation:item];
            }
        }
        //轨迹点
        BMKMapPoint * temppoints = new BMKMapPoint[planPointCounts];
        int i = 0;
        for (int j = 0; j < size; j++) {
            BMKDrivingStep* transitStep = [plan.steps objectAtIndex:j];
            int k=0;
            for(k=0;k<transitStep.pointsCount;k++) {
                temppoints[i].x = transitStep.points[k].x;
                temppoints[i].y = transitStep.points[k].y;
                i++;
            }
            
        }
        // 通过points构建BMKPolyline
        BMKPolyline* polyLine = [BMKPolyline polylineWithPoints:temppoints count:planPointCounts];
        [_mapView addOverlay:polyLine]; // 添加路线overlay 这个方法执行后 会调用 (代理方法5) 这个代理方法
        delete []temppoints;
        [self mapViewFitPolyLine:polyLine];
    }
    loadingImageView1.hidden = YES;
}
#pragma mark  根据polyline设置地图范围
- (void)mapViewFitPolyLine:(BMKPolyline *) polyLine {
    CGFloat ltX, ltY, rbX, rbY;
    
    if (polyLine.pointCount < 1) return;
    BMKMapPoint pt = polyLine.points[0];
    ltX = pt.x, ltY = pt.y;
    rbX = pt.x, rbY = pt.y;
    
    for (int i = 0; i < polyLine.pointCount; i++) {
        BMKMapPoint pt = polyLine.points[i];
        if (pt.x < ltX) {
            ltX = pt.x;
        }
        if (pt.x > rbX) {
            rbX = pt.x;
        }
        if (pt.y > ltY) {
            ltY = pt.y;
        }
        if (pt.y < rbY) {
            rbY = pt.y;
        }
    }
    BMKMapRect rect;
    rect.origin = BMKMapPointMake(ltX , ltY);
    rect.size = BMKMapSizeMake(rbX - ltX, rbY - ltY);
    [_mapView setVisibleMapRect:rect];
    _mapView.zoomLevel = _mapView.zoomLevel - 0.3;
}
#pragma mark 根据overlay生成对应的View (代理方法5)
-(BMKOverlayView *)mapView:(BMKMapView *)mapView viewForOverlay:(id<BMKOverlay>)overlay{
    if ([overlay isKindOfClass:[BMKPolyline class]]) {
        BMKPolylineView* polylineView = [[BMKPolylineView alloc] initWithOverlay:overlay];
        polylineView.fillColor = [[UIColor cyanColor] colorWithAlphaComponent:1];
        polylineView.strokeColor = [[UIColor greenColor] colorWithAlphaComponent:0.7];
        polylineView.lineWidth = 6.0;
        return polylineView;
    }
    return nil;
}
#pragma mark MapViewDelegate  -- 第三步  根据驾车搜索的结果把起点，终点 ，中节点添加在地图上
- (BMKAnnotationView *)mapView:(BMKMapView *)mapView viewForAnnotation:(id <BMKAnnotation>)annotation
{
    if([annotation.title isEqualToString:@"当前位置"])
    {
        NSString *AnnotationViewID = @"renameMark";
         BMKPinAnnotationView *annotationView = (BMKPinAnnotationView *)[mapView dequeueReusableAnnotationViewWithIdentifier:AnnotationViewID];
        if (annotationView == nil) {
            annotationView = [[BMKPinAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:AnnotationViewID];
        // 设置颜色
        annotationView.pinColor = BMKPinAnnotationColorGreen;
        // 从天上掉下效果
        annotationView.animatesDrop = YES;
        // 设置可拖拽
        annotationView.draggable = YES;
        }
        return annotationView;
    }
    
    if ([annotation isKindOfClass:[RouteAnnotation class]]) //第三步
    {
      return [self getRouteAnnotationView:mapView viewForAnnotation:(RouteAnnotation *)annotation];
    }
    return nil;
}
#pragma mark 获取路线的标注，显示到地图 －－第四步
- (BMKAnnotationView*)getRouteAnnotationView:(BMKMapView *)mapview viewForAnnotation:(RouteAnnotation*)routeAnnotation{
    
    BMKAnnotationView *view = nil;
    switch (routeAnnotation.type) {
        case 0:
        {
            view = [mapview dequeueReusableAnnotationViewWithIdentifier:@"start_node"];
            if (view == nil) {
                view = [[BMKAnnotationView alloc] initWithAnnotation:routeAnnotation reuseIdentifier:@"start_node"];
                view.image = [UIImage imageWithContentsOfFile:[self getMyBundlePath1:@"images/icon_nav_start"]];
                view.centerOffset = CGPointMake(0, -(view.frame.size.height * 0.5));
                view.canShowCallout = true;
            }
            view.annotation = routeAnnotation;
        }
            break;
        case 1:
        {
            view = [mapview dequeueReusableAnnotationViewWithIdentifier:@"end_node"];
            if (view == nil) {
                view = [[BMKAnnotationView alloc] initWithAnnotation:routeAnnotation reuseIdentifier:@"end_node"];
                view.image = [UIImage imageWithContentsOfFile:[self getMyBundlePath1:@"images/icon_nav_end"]];
                view.centerOffset = CGPointMake(0, -(view.frame.size.height * 0.5));
                view.canShowCallout = true;
            }
            view.annotation =routeAnnotation;
        }
            break;
        case 4:
        {
            view = [mapview dequeueReusableAnnotationViewWithIdentifier:@"route_node"];
            if (view == nil) {
                view = [[BMKAnnotationView alloc] initWithAnnotation:routeAnnotation reuseIdentifier:@"route_node"];
                view.canShowCallout = true;
            } else {
                [view setNeedsDisplay];
            }
            UIImage *image = [UIImage imageWithContentsOfFile:[self getMyBundlePath1:@"images/icon_direction"]];
            view.image = [image imageRotatedByDegrees:routeAnnotation.degree];
            view.annotation = routeAnnotation;
        }
            break;
        default:
            break;
    }
    return view;
}
//根据经纬度获取当前位置 -(百度地图)
-(void)updateAddress
{
    CLLocationCoordinate2D pt = (CLLocationCoordinate2D){0, 0};
    pt = (CLLocationCoordinate2D){[[UD objectForKey:@"baidu_current_lat"] floatValue],[[UD objectForKey:@"baidu_current_long"] floatValue]};
    BMKReverseGeoCodeOption *reverseGeocodeSearchOption = [[BMKReverseGeoCodeOption alloc]init]; //创建检索对象
    reverseGeocodeSearchOption.reverseGeoPoint = pt;
    BOOL flag1 = [self.geocodesearch reverseGeoCode:reverseGeocodeSearchOption];
    if(flag1)
    {
        NSLog(@"反geo检索发送成功");
    }
    else
    {
        NSLog(@"反geo检索发送失败");
    }
    
    
}
#pragma mark ReverseGeoCodeDelegate
-(void) onGetReverseGeoCodeResult:(BMKGeoCodeSearch *)searcher result:(BMKReverseGeoCodeResult *)result errorCode:(BMKSearchErrorCode)error
{
    if(error==0)
    {
        NSString *city = result.addressDetail.city;
        NSString *district = result.addressDetail.district;
        NSString * street = result.addressDetail.streetName;
        NSLog(@"111city==%@",city);
        self.
        self.locationLab.text = [NSString stringWithFormat:@"%@%@%@",city,district,street];
    }
}
//获取百度地图的起点和终点位置的图标
- (NSString*)getMyBundlePath1:(NSString *)filename
{
    
    NSBundle * libBundle = MYBUNDLE ;
    if ( libBundle && filename ){
        NSString * s=[[libBundle resourcePath ] stringByAppendingPathComponent:filename];
        return s;
    }
    return nil ;
}
//下一页
- (IBAction)nextPage:(UIButton *)sender
{
    ThreePageController *tvc = [[ThreePageController alloc]init];
    [self.navigationController pushViewController:tvc animated:YES];
}
//加载gif
-(void)createDelayLoad
{
    //UIWindow *window = [UIApplication sharedApplication].keyWindow;
    bigView   = [[UIView alloc]initWithFrame:CGRectMake(0, 0, Screen_Width, self.view.bounds.size.height+64)];
    bigView.backgroundColor = [UIColor lightGrayColor];
    bigView.alpha = 0.4;
    NSString  *name = @"loadRoutes.gif";
    
    NSString  *filePath = [[NSBundle bundleWithPath:[[NSBundle mainBundle] bundlePath]] pathForResource:name ofType:nil];
    
    NSData  *imageData = [NSData dataWithContentsOfFile:filePath];
    
    loadingImageView1 = [[UIImageView alloc] init];
    
    loadingImageView1.backgroundColor = [UIColor clearColor];
    
    loadingImageView1.image = [self gifChangeToImageWithData:imageData];
    
    loadingImageView1.frame = CGRectMake(0,200, 72, 116);
    
    
    
    [self configUI:loadingImageView1];
    
    
    
}
- (UIImage *)gifChangeToImageWithData:(NSData *)data

{
    
    if (!data)
        
    {
        
        return nil;
        
    }
    
    
    
    CGImageSourceRef source = CGImageSourceCreateWithData((__bridge CFDataRef)data, NULL);
    
    
    
    size_t count = CGImageSourceGetCount(source);
    
    
    
    UIImage *animatedImage;
    
    
    
    if (count <= 1)
        
    {
        
        animatedImage = [[UIImage alloc] initWithData:data];
        
    }
    
    else
        
    {
        
        NSMutableArray *images = [NSMutableArray array];
        
        
        
        NSTimeInterval duration = 0.1f;
        
        
        
        for (size_t i = 0; i < count; i++)
            
        {
            
            CGImageRef image = CGImageSourceCreateImageAtIndex(source, i, NULL);
            
            if (!image)
                
            {
                
                continue;
                
            }
            
            
            
            duration += [self frameDurationAtIndex:i source:source];
            
            
            
            [images addObject:[UIImage imageWithCGImage:image scale:[UIScreen mainScreen].scale orientation:UIImageOrientationUp]];
            
            
            
            CGImageRelease(image);
            
        }
        
        
        
        if (!duration)
            
        {
            
            duration = (1.0f / 10.0f) * count;
            
        }
        
        
        
        animatedImage = [UIImage animatedImageWithImages:images duration:duration];
        
    }
    
    
    
    CFRelease(source);
    
    
    
    return animatedImage;
    
}



- (void)configUI:(UIImageView *)loadingImageView

{
    
    
    
    loadingImageView.center = CGPointMake(Screen_Width / 2, Screen_Width/ 2+110);
    
    loadingImageView.tag = 0xadd;
    
    [self.view addSubview:loadingImageView];
    
    
    
}



- (float)frameDurationAtIndex:(NSUInteger)index source:(CGImageSourceRef)source

{
    
    float frameDuration = 0.1f;
    
    CFDictionaryRef cfFrameProperties = CGImageSourceCopyPropertiesAtIndex(source, index, nil);
    
    NSDictionary *frameProperties = (__bridge NSDictionary *)cfFrameProperties;
    
    NSDictionary *gifProperties = frameProperties[(__bridge NSString *)kCGImagePropertyGIFDictionary];
    
    
    
    NSNumber *delayTimeUnclampedProp = gifProperties[(__bridge NSString *)kCGImagePropertyGIFUnclampedDelayTime];
    
    if (delayTimeUnclampedProp)
        
    {
        
        frameDuration = [delayTimeUnclampedProp floatValue];
        
    }
    
    else
        
    {
        
        NSNumber *delayTimeProp = gifProperties[(__bridge NSString *)kCGImagePropertyGIFDelayTime];
        
        if (delayTimeProp)
            
        {
            
            frameDuration = [delayTimeProp floatValue];
            
        }
        
    }
    
    if (frameDuration < 0.011f)
        
    {
        
        frameDuration = 0.100f;
        
    }
    
    CFRelease(cfFrameProperties);
    
    return frameDuration;
    
}


@end
