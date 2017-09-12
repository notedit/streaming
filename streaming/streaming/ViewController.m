//
//  ViewController.m
//  streaming
//
//  Created by xiang on 12/09/2017.
//  Copyright © 2017 dotEngine. All rights reserved.
//

#import "ViewController.h"
#import <ReplayKit/ReplayKit.h>

@interface ViewController ()<RPBroadcastActivityViewControllerDelegate,RPBroadcastControllerDelegate>

{
    RPBroadcastController* _broadcastController;
}
@property (weak, nonatomic) IBOutlet UILabel *timeLable;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    
    NSTimer *t = [NSTimer scheduledTimerWithTimeInterval: 0.05
                                                  target: self
                                                selector:@selector(onTick)
                                                userInfo: nil repeats:YES];
    
    [t fire];
    
}


-(void)onTick {
    
    NSDate *date = [NSDate date];
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"hh:mm A"];
    NSString *formattedDateString = [dateFormatter stringFromDate:date];
    
    self.timeLable.text = formattedDateString;
    
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}



- (IBAction)startStream:(id)sender {
    
    [RPBroadcastActivityViewController loadBroadcastActivityViewControllerWithHandler:^(RPBroadcastActivityViewController * _Nullable broadcastActivityViewController, NSError * _Nullable error) {
        
        broadcastActivityViewController.delegate = self;
        [self presentViewController:broadcastActivityViewController animated:YES completion:^{
            
        }];
        
    }];
}


#pragma delegate


- (void)broadcastActivityViewController:(RPBroadcastActivityViewController *)broadcastActivityViewController didFinishWithBroadcastController:(nullable RPBroadcastController *)broadcastController error:(nullable NSError *)error
{
    
    _broadcastController = broadcastController;
    
    _broadcastController.delegate = self;
    
    [broadcastActivityViewController dismissViewControllerAnimated:YES completion:^{
        
        [_broadcastController startBroadcastWithHandler:^(NSError * _Nullable error) {
            
            NSLog(@"error %@", error);
            //NSLog(@"serviceInfo %@", _broadcastController.serviceInfo);
            
        }];
    }];
    
}



- (void)broadcastController:(RPBroadcastController *)broadcastController
         didFinishWithError:(NSError * __nullable)error
{
    
    NSLog(@"didFinishWithError %@", error);
    
}


- (void)broadcastController:(RPBroadcastController *)broadcastController
       didUpdateServiceInfo:(NSDictionary <NSString *, NSObject <NSCoding> *> *)serviceInfo
{
    
    NSLog(@"didUpdateServiceInfo %@", serviceInfo);
    
}



@end
