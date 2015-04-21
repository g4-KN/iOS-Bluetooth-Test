//
//  ViewController.m
//  Bluetooth Scanner
//
//  Created by ken ng on 2015-04-18.
//  Copyright (c) 2015 NG. All rights reserved.
//
//need to understand the technology before using it
//if don't know the device UUID, then need to scan for the devices
// scan for iBeacon but cannot interact with it.  need to use Core Location for that
// 3 kinds of charateristic, read, write, notify
//
//You cannot create a service on a normal (non-jailbroken) phone. Isn't even possible to distribute something like that (read the app review guidelines). Sure, you can scan for BLE data on whatever interval you want, but your app needs to be active, or it needs to be doing something approved by Apple for making connections to BLE devices in the background. Just be aware that like any other background app, iOS might suspend or terminate your app at any time, and there's nothing you can do about it.

//iOS stuff always get depreciated?
// push notification need to get a device token from apple server
//BLE is not a constant polling, so it is hard to detect disconnection that way. Even if I disconnect from the central side, the bluetooth peripheral still takes time until then next period to react to the action.

#import "ViewController.h"

@interface ViewController ()
//created an instance of my custom cell subclass
//@property (weak, nonatomic) IBOutlet UITextView *outputTextView;
@property (weak, nonatomic) IBOutlet UISegmentedControl *verbositySelector;
//instance to hold the the central manager
@property (strong, nonatomic) CBCentralManager *centralManager;
@property (strong, nonatomic) CBPeripheral *discoveredPeripheral;
@property BOOL bluetoothOn;
@property BOOL checkFlag;
@property BOOL isThereFlag;
@property BOOL scanningFlag;
//@property (weak, nonatomic) IBOutlet UILabel *valueLabel;

@end

@implementation ViewController

//setup central manager
- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    [self tLog:@"Bluetooth LE - Internet of Things 101: Never Lose Any Thing!"];
    self.bluetoothOn = NO;
    self.checkFlag = NO;
    self.isThereFlag = NO;
    //init centralManager
    self.centralManager = [[CBCentralManager alloc] initWithDelegate:self queue:nil];
    //[self startScanning];
    
}

//reflects back the content of our selected segmented control
- (bool)verboseMode{
    return(self.verbositySelector.selectedSegmentIndex != 0);
}
//log data to the onscreen text view
//so that when the phone is not connected to Xcode i can still view the log instead of using nslog
- (void)tLog:(NSString *)msg{
    //append text so it doesn't override the old one (newline and then the msg)
    self.outputTextView.text = [@"\r\n\r\n" stringByAppendingString:self.outputTextView.text];
    self.outputTextView.text = [msg stringByAppendingString:self.outputTextView.text];
}

//start scanning
- (IBAction)startButton:(id)sender {
    //calling my own method
    self.checkFlag = NO;
    [self startScanning];
    
}

//check for a specific service
- (IBAction)checkButton:(id)sender {
//    while(1){
//        @autoreleasepool{
//        //this sleeps for 1 second
//        //sleep(1);
//        if (i == 10000){
//        //usleep(200);
//        //[NSThread sleepForTimeInterval:1.0f];
//            [self scanningFor];
//            i = 0;
//        }
//        
//        i++;
//        }
//    }
    
        self.checkFlag = YES;
    //usleep(20000);
    if ( self.checkFlag == YES&& self.scanningFlag ==YES){
        [self tLog:@"failed to find Cycling Power" ];
    }
        [self scanningFor];
        //[self scanningFor];
        //the dispatcher creates a new thread, so huge memory leak
        //usleep(20000);
        //[self startTimedTask];
    
}

//scanning for all devices
- (void)startScanning{
    [self tLog:@"Bluetooth scanning started"];
    if (!self.bluetoothOn){
        [self tLog:@"Bluetooth is OFF" ];
        return;
    }
    //if i know the service uuid, then can avoid scanning all bluetooth device -> find the correct device and the access the services
    //for the scanner we will have all peripheral
    //B8617CDE-E7A5-D9EB-7914-77C734E7126F
    //passed in nil, so it will start looking for any services
    //271D69CC-7B53-4C16-A335-FD78AA419399
    //SECOND PARAM IS to continuously check for the range then set it to YES, if not (save power) set to NO
    //if set to yes it can also crash the phone with too many request
    //@[[CBUUID UUIDWithString:TRANSFER_SERVICE_UUID]]
    self.scanningFlag = YES;
    [self.centralManager scanForPeripheralsWithServices: nil options:@{
                                                                       CBCentralManagerScanOptionAllowDuplicatesKey
                                                                       : @NO
                                                                       }];
    
}

//scanning for specific service - with UUID 1818
- (void)scanningFor{
    [self tLog:@"check started"];
    if (!self.bluetoothOn){
        [self tLog:@"Bluetooth is OFF" ];
        return;
    }
    self.checkFlag = YES;
    [self.centralManager scanForPeripheralsWithServices: @[[CBUUID UUIDWithString:TRANSFER_SERVICE_UUID]] options:@{
                                                                       CBCentralManagerScanOptionAllowDuplicatesKey
                                                                       : @NO
                                                                       }];

    
}

- (void)startTimedTask
{
    //NSTimer *fiveSecondTimer = [NSTimer scheduledTimerWithTimeInterval:5.0 target:self selector:@selector(performBackgroundTask) userInfo:nil repeats:YES];
}

- (void)performBackgroundTask
{
    
    [self tLog: (@"timed task started")];
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        //[self scanningFor];
        dispatch_async(dispatch_get_main_queue(), ^{
            //Update UI
        });
    });
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

//be called whenever a device is discovered
-(void) centralManager:(CBCentralManager *)central didDiscoverPeripheral:(CBPeripheral *)peripheral advertisementData:(NSDictionary *)advertisementData RSSI:(NSNumber *)RSSI{
    self.scanningFlag = NO;
    //[] something means object or something related to class
    // check against the dictionary, advertismentData so I know what it really is. instead of "peripheral.name"
    [self tLog:[NSString stringWithFormat:@"Discovered %@, RSSI: %@\n", [advertisementData objectForKey:@"kCBAdvDataLocalName"], RSSI]];
    //save a copy of the peripheral
    self.discoveredPeripheral=peripheral;
    
    NSString *temp = [advertisementData objectForKey:@"kCBAdvDataLocalName"];
    //[self tLog: [NSString stringWithFormat: @"%@", temp]];
    if(self.checkFlag == YES && self.isThereFlag == NO &&[temp containsString:(@"Cycling Power")]){
        [self tLog: (@"Cycling Power is there")];
        self.isThereFlag = YES;
        self.checkFlag = NO;
    }else if(self.checkFlag == YES && self.isThereFlag == YES && [temp containsString:(@"Cycling Power")]){
            [self tLog: (@"Cycling Power is STILL there")];
            self.isThereFlag = YES;
            self.checkFlag = NO;
    }else if(self.checkFlag == YES && self.isThereFlag == YES){
        [self tLog: (@"NOTIFICATION: Cycling Power is not here anymore, cannot scan for it")];
        
        self.isThereFlag = YES;
        sleep(1);
        self.checkFlag = NO;
    }
    else if (self.checkFlag == NO){
//    if([self verboseMode])
        [self tLog:[NSString stringWithFormat:@"Connecting to peripheral %@", peripheral]];
        [self.centralManager connectPeripheral:peripheral options:nil];
    }
    else{
        
    }
    
    
}

-(void) centralManager: (CBCentralManager *)central didFailToConnectPeripheral:(CBPeripheral *)peripheral error:(NSError *)error{
    //indicating disconnection
    [self tLog:@"//////////////////////////Failed to connect/////////////////////////"];
    //[self cleanup];
    	
}

/*!
 *  @method connectPeripheral:options:
 *
 *  @param peripheral   The <code>CBPeripheral</code> to be connected.
 *  @param options      An optional dictionary specifying connection behavior options.
 *
 *  @discussion         Initiates a connection to <i>peripheral</i>. Connection attempts never time out and, depending on the outcome, will result
 *                      in a call to either {@link centralManager:didConnectPeripheral:} or {@link centralManager:didFailToConnectPeripheral:error:}.
 *                      Pending attempts are cancelled automatically upon deallocation of <i>peripheral</i>, and explicitly via {@link cancelPeripheralConnection}.
 *
 *  @see                centralManager:didConnectPeripheral:
 *  @see                centralManager:didFailToConnectPeripheral:error:
 *  @seealso            CBConnectPeripheralOptionNotifyOnConnectionKey
 *  @seealso            CBConnectPeripheralOptionNotifyOnDisconnectionKey
 *  @seealso            CBConnectPeripheralOptionNotifyOnNotificationKey
 *
 */

// use CBConnectPeripheralOptionNotifyOnDisconnectionKey
- (void) centralManager:(CBCentralManager *)central didConnectPeripheral:(CBPeripheral *)peripheral
{
    [self tLog: (@"//////////////////////Connected########################")];
    
    //[_centralManager stopScan];
    //[self tLog:(@"Scanning stopped")];
    
    peripheral.delegate = self;
    //call the next method
    [peripheral discoverServices: nil];
    
}

- (void)centralManager:(CBCentralManager *)central didDisconnectPeripheral:(CBPeripheral *)peripheral error:(NSError *)error {
    [_centralManager connectPeripheral:peripheral options:@{CBConnectPeripheralOptionNotifyOnDisconnectionKey:[NSNumber numberWithBool:NO]}];
    [self tLog: (@"something has disconnected")];
    
    // Email Subject
    NSString *emailTitle = @"Test Notification";
    // Email Content
    NSString *messageBody = @"<h1>Notification generated by device disconnection </h1>";
    // To address
    NSArray *toRecipents = [NSArray arrayWithObject: @"info@linquet.com"];
    //@"kenng329@gmail.com"];
    MFMailComposeViewController *mc = [[MFMailComposeViewController alloc] init];
    mc.mailComposeDelegate = self;
    [mc setSubject:emailTitle];
    [mc setMessageBody:messageBody isHTML:YES];
    [mc setToRecipients:toRecipents];
    
    // Present mail view controller on screen
    [self presentViewController:mc animated:YES completion:NULL];
    
    //alert box
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Notification: "
                                                    message:@"Peripheral Disconnected"
                                                   delegate:nil
                                          cancelButtonTitle:@"OK"
                                          otherButtonTitles:nil];
    [alert show];
    //[alert release];
}

-(void) peripheral:(CBPeripheral *)peripheral didDiscoverServices:(NSError *)error{
   if(error){
        [self tLog:[error description]];
        
    }
    for (CBService *service in peripheral.services){
        [self tLog:[NSString stringWithFormat:@"Discovered services: %@", [service description]]];
        //can pass in an array of charateristics, but we wont
        [peripheral discoverCharacteristics:nil forService:service];
    }
    
}

-(void) peripheral:(CBPeripheral *)peripheral didDiscoverCharacteristicsForService:(CBService *)service error:(NSError *)error{
    if(error){
        [self tLog:[error description]];
        return;
    }
    for(CBCharacteristic *charateristic in service.characteristics){
        [self tLog:[NSString stringWithFormat:@"Characteristic found: %@", [charateristic description]]];
        if ([charateristic.UUID isEqual:[CBUUID UUIDWithString: TRANSFER_CHARACTERISTIC_UUID]]) {
            [peripheral setNotifyValue:YES forCharacteristic:charateristic];
        }
    }
    
    [self tLog:(@"\r\n\r\n\r\n\r\n\r\n\r\n")];

}

-(void) peripheral:(CBPeripheral *)peripheral didUpdateValueForCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error{
    if(error){
        [self tLog:[error description]];
        return;
    }
    NSString *stringFromData = [[NSString alloc ] initWithData:characteristic.value encoding:NSUTF8StringEncoding];
    [self tLog:[NSString stringWithFormat:@"Characteristic updated: %@", stringFromData]];
    //self.valueLabel.text = stringFromData;
    
}

- (void)cleanup {
    [self tLog:(@"cleaning up")];
    // See if we are subscribed to a characteristic on the peripheral
    if (_discoveredPeripheral.services != nil) {
        for (CBService *service in _discoveredPeripheral.services) {
            if (service.characteristics != nil) {
                for (CBCharacteristic *characteristic in service.characteristics) {
                    if ([characteristic.UUID isEqual:[CBUUID UUIDWithString:TRANSFER_CHARACTERISTIC_UUID]]) {
                        if (characteristic.isNotifying) {
                            [_discoveredPeripheral setNotifyValue:NO forCharacteristic:characteristic];
                            return;
                        }
                    }
                }
            }
        }
    }
    
    [_centralManager cancelPeripheralConnection:_discoveredPeripheral];
}

-(void) centralManagerDidUpdateState:(CBCentralManager *)central{
    if(central.state != CBCentralManagerStatePoweredOn){
        [self tLog:@"Bluetooth OFF"];
        self.bluetoothOn = NO;
        
    }
    else{
        [self tLog:@"Bluetooth ON"];
        self.bluetoothOn = YES;
    }
    
}

- (IBAction)showEmail:(id)sender {
    // Email Subject
    NSString *emailTitle = @"Test Email";
    // Email Content
    NSString *messageBody = @"<h1>learning is so fun!</h1>";
    // To address
    NSArray *toRecipents = [NSArray arrayWithObject:@"kenng329@gmail.com"];
    
    MFMailComposeViewController *mc = [[MFMailComposeViewController alloc] init];
    mc.mailComposeDelegate = self;
    [mc setSubject:emailTitle];
    [mc setMessageBody:messageBody isHTML:YES];
    [mc setToRecipients:toRecipents];
    
    // Present mail view controller on screen
    [self presentViewController:mc animated:YES completion:NULL];
    
}

- (void) mailComposeController:(MFMailComposeViewController *)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError *)error
{
    switch (result)
    {
        case MFMailComposeResultCancelled:
            [self tLog:(@"Mail cancelled")];
            break;
        case MFMailComposeResultSaved:
            [self tLog:(@"Mail saved")];
            break;
        case MFMailComposeResultSent:
            [self tLog:(@"Mail sent")];
            break;
        case MFMailComposeResultFailed:
            [self tLog:[NSString stringWithFormat:@"Mail sent failure: %@", [error localizedDescription]]];
            break;
        default:
            break;
    }
    
    // Close the Mail Interface
    [self dismissViewControllerAnimated:YES completion:NULL];
}
@end
