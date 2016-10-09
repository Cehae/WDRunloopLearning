//
//  ViewController.m
//  WDRunloopDemo
//
//  Created by WD on 16/10/10.
//  Copyright © 2016年 WD. All rights reserved.
//  github：https://github.com/Cehae/WDRunloopLearning
//  相关博客：http://blog.csdn.net/cehae/article/details/52773592

#import "ViewController.h"

@interface ViewController ()
/** 注释 */
@property (nonatomic, strong) NSThread *thread;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
}
#pragma mark - 一 监听Runloop
- (IBAction)RunloopObserver:(id)sender {
    NSLog(@"处理点击事件：%s",__func__);
}
-(void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    [self observer];
}
-(void)observer
{
    //1.创建监听者
    /*
     第一个参数:怎么分配存储空间
     第二个参数:要监听的状态 kCFRunLoopAllActivities 所有的状态
     第三个参数:时候持续监听
     第四个参数:优先级 总是传0
     第五个参数:当状态改变时候的回调
     */
    CFRunLoopObserverRef observer = CFRunLoopObserverCreateWithHandler(CFAllocatorGetDefault(), kCFRunLoopAllActivities, YES, 0, ^(CFRunLoopObserverRef observer, CFRunLoopActivity activity) {
        
        /*
         kCFRunLoopEntry = (1UL << 0),        即将进入runloop
         kCFRunLoopBeforeTimers = (1UL << 1), 即将处理timer事件
         kCFRunLoopBeforeSources = (1UL << 2),即将处理source事件
         kCFRunLoopBeforeWaiting = (1UL << 5),即将进入睡眠
         kCFRunLoopAfterWaiting = (1UL << 6), 被唤醒
         kCFRunLoopExit = (1UL << 7),         runloop退出
         kCFRunLoopAllActivities = 0x0FFFFFFFU
         */
        switch (activity) {
            case kCFRunLoopEntry:
                NSLog(@"即将进入runloop");
                break;
            case kCFRunLoopBeforeTimers:
                NSLog(@"即将处理timer事件");
                break;
            case kCFRunLoopBeforeSources:
                NSLog(@"即将处理source事件");
                break;
            case kCFRunLoopBeforeWaiting:
                NSLog(@"即将进入睡眠");
                break;
            case kCFRunLoopAfterWaiting:
                NSLog(@"被唤醒");
                break;
            case kCFRunLoopExit:
                NSLog(@"runloop退出");
                break;
                
            default:
                break;
        }
    });
    
    /*
     第一个参数:要监听哪个runloop
     第二个参数:观察者
     第三个参数:运行模式
     */
    CFRunLoopAddObserver(CFRunLoopGetCurrent(),observer, kCFRunLoopDefaultMode);
    
    //NSDefaultRunLoopMode == kCFRunLoopDefaultMode
    //NSRunLoopCommonModes == kCFRunLoopCommonModes
}

#pragma mark - 二 创建常驻线程
- (IBAction)createThread:(id)sender {
    
    //1.创建线程
    self.thread = [[NSThread alloc]initWithTarget:self selector:@selector(task) object:nil];
    [self.thread start];
}
-(void)task
{
    NSLog(@"task---%@",[NSThread currentThread]);
    //    while (1) {
    //       NSLog(@"task1---%@",[NSThread currentThread]);
    //    }
    //解决方法:开runloop
    //1.获得子线程对应的runloop
    NSRunLoop *runloop = [NSRunLoop currentRunLoop];
    
    //保证runloop不退出
    //NSTimer *timer = [NSTimer timerWithTimeInterval:2.0 target:self selector:@selector(run) userInfo:nil repeats:YES];
    //[runloop addTimer:timer forMode:NSDefaultRunLoopMode];
    [runloop addPort:[NSPort port] forMode:NSDefaultRunLoopMode];
    
    //2.默认是没有开启
    [runloop run];//开启
//    [runloop runUntilDate:[NSDate dateWithTimeIntervalSinceNow:10]];//开启Runloop，到特定时间结束
    
    NSLog(@"---end----");
}
- (IBAction)doOthertask:(id)sender {
    //[self.thread start];
    
    [self performSelector:@selector(OtheTask) onThread:self.thread withObject:nil waitUntilDone:YES];
}
-(void)OtheTask
{
    NSLog(@"OtheTask---%@",[NSThread currentThread]);
}

-(void)run
{
    NSLog(@"%s",__func__);
}

//Runloop中自动释放池的创建和释放
//第一次创建:启动runloop
//最后一次销毁:runloop退出的时候
//其他时候的创建和销毁:当runloop即将睡眠的时候销毁之前的释放池,重新创建一个新的

@end
