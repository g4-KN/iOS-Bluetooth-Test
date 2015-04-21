//
//  ViewController.h
//  Bluetooth Scanner
//
//  Created by ken ng on 2015-04-18.
//  Copyright (c) 2015 NG. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MessageUI/MessageUI.h>

#import <CoreBluetooth/CoreBluetooth.h>

//connect to the protocols
//protocol delegate callback- so that each time it finds a new device it calls me back
//and i can decide whether that's a device i want to talk to
@interface ViewController : UIViewController
<
CBCentralManagerDelegate,
CBPeripheralDelegate,
MFMailComposeViewControllerDelegate
>
#define TRANSFER_SERVICE_UUID           @"1818"//"FB694B90-F49E-4597-8306-171BBA78F846"
#define TRANSFER_CHARACTERISTIC_UUID    @"271D69CC-7B53-4C16-A335-FD78AA419399" //"EB6727C4-F184-497A-A656-76B0CDAC633A"


@property (weak, nonatomic) IBOutlet UITextView *outputTextView;
- (IBAction)showEmail:(id)sender;



@end
