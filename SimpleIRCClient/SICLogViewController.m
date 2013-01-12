//
//  SICLogViewController.m
//  SimpleIRCClient
//
//  Created by 佐々木 悠人 on 2013/01/05.
//  Copyright (c) 2013年 yewton. All rights reserved.
//

#import "SICLogViewController.h"
#import "SICChannel.h"
#import "SICLog.h"
#import "SICServer.h"
#import "SICClient.h"

@interface SICLogViewController ()

@end

@interface UILabel (BPExtensions)
- (void)sizeToFitFixedFidth:(CGFloat)fixedWidth;
@end

@implementation UILabel (BPExtensions)
- (void)sizeToFitFixedFidth:(CGFloat)fixedWidth
{
    self.frame = CGRectMake(self.frame.origin.x, self.frame.origin.y, fixedWidth, 0);
    self.lineBreakMode = NSLineBreakByCharWrapping;
    self.numberOfLines = 0;
    [self sizeToFit];
}
@end

@interface SICLogViewController ()
@property (nonatomic, strong) NSTimer *timer;
@end

@implementation SICLogViewController
@synthesize scrollView = _scrollView, channel = _channel, timer = _timer, client = _client;

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    [self registerForKeyboardNotifications];
    self.tableView.transform = CGAffineTransformMakeRotation(M_PI);
    CGRect r = [[UIScreen mainScreen] bounds];
    CGFloat w = r.size.width;
    CGFloat h = r.size.height;
    
    CGRect textFieldFrame = self.textField.frame;
    CGRect tableViewFrame = self.tableView.frame;
    CGRect nButtonFrame = self.noticeButton.frame;
    CGRect pButtonFrame = self.privmsgButton.frame;
    
    // set the table frame
    {
        [self.tableView setFrame:CGRectMake(0.0, 0.0, w, h - 80.0)];
        static CGFloat innerOffset = 9.0;
        UIEdgeInsets insets = UIEdgeInsetsMake(0.0, // top
                                               0.0, // left
                                               0.0, // bottom
                                               CGRectGetWidth(_tableView.frame) - innerOffset // right
                                               );
        self.tableView.scrollIndicatorInsets = insets;
    }
    
    // set frames of the text field and the button
    {
        static CGFloat padding = 7.0;
        CGFloat offsetY = CGRectGetMaxY(tableViewFrame) + padding;
        [self.textField setFrame:CGRectMake(CGRectGetMinX(textFieldFrame),
                                            offsetY,
                                            CGRectGetWidth(textFieldFrame),
                                            CGRectGetHeight(textFieldFrame))];
        [self.noticeButton setFrame:CGRectMake(CGRectGetMinX(nButtonFrame),
                                         offsetY,
                                         CGRectGetWidth(nButtonFrame),
                                         CGRectGetHeight(nButtonFrame))];
        [self.privmsgButton setFrame:CGRectMake(CGRectGetMinX(pButtonFrame),
                                                offsetY,
                                                CGRectGetWidth(pButtonFrame),
                                                CGRectGetHeight(pButtonFrame))];
    }
    if (self.client.connected) {
        [self changeConnectionControllerStateToConnected];
    } else {
        [self changeConnectionControllerStateToDisconnected];
    }
}

- (void)viewDidAppear:(BOOL)animated
{
    _timer = [NSTimer scheduledTimerWithTimeInterval:1
                                              target:self
                                            selector:@selector(reloadData:)
                                            userInfo:nil repeats:YES];
    [_timer fire];
}

- (void)viewDidDisappear:(BOOL)animated
{
    [_timer invalidate];
}

- (void)reloadData:(NSTimer *)timer
{
    [self.tableView reloadData];
}

- (void)registerForKeyboardNotifications
{
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWasShown:)
                                                 name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillBeHidden:)
                                                 name:UIKeyboardWillHideNotification object:nil];
}

- (void)keyboardWasShown:(NSNotification*)aNotification
{
    // UIKeyboardFrameEndUserInfoKeyが使える時と使えない時で処理を分ける
    CGRect keyboardBounds;

    // frameだがoriginを使わないのでbounds扱いで良い
    keyboardBounds = [[aNotification.userInfo objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue];
    CGFloat keyboardHeight = keyboardBounds.size.height;
    CGPoint scrollPoint = CGPointMake(0.0, keyboardHeight);
    NSLog(@"keyboardHeight: %f", keyboardHeight);
    [self.scrollView setContentOffset:scrollPoint animated:YES];
    //    [self.scrollView setContentSize:CGSizeMake(0.0, 0.0)];
}


- (void)keyboardWillBeHidden:(NSNotification*)aNotification
{
    [self.scrollView setContentOffset:CGPointZero animated:YES];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.channel.log.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{

    NSString *cellIdentifier;
    
    // Configure the cell...
    NSUInteger index = (self.channel.log.count - 1) - indexPath.row;
    SICLog *log = [self.channel.log objectAtIndex:index];
 
    if (log.sender) {
        // 通常ログ
        cellIdentifier = @"LogMessageCell";
    } else {
        // サーバログ
        cellIdentifier = @"ServerLogCell";
    }
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier forIndexPath:indexPath];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
    }
    UILabel *timeLabel = (UILabel *)[cell viewWithTag:1];
    UILabel *bodyLabel = (UILabel *)[cell viewWithTag:2];
    static NSDateFormatter *formatter = nil;
    if (formatter == nil) {
        formatter = [[NSDateFormatter alloc] init];
        [formatter setDateFormat:@"HH:mm:ss"];
    }
    
    [timeLabel setText:[formatter stringFromDate:log.time]];
    [bodyLabel setText:log.body];
    if (log.sender) {
        UILabel *nickLabel = (UILabel *)[cell viewWithTag:3];
        [nickLabel setText:[[NSString alloc] initWithFormat:@"(%@)", log.sender]];
        if (log.notice) {
            [bodyLabel setTextColor:[UIColor colorWithRed:0.5 green:0.5 blue:0.5 alpha:1.0]];
        } else {
            [bodyLabel setTextColor:[UIColor blackColor]];
        }
    }

//    [bodyLabel needsUpdateConstraints];
//    [cell needsUpdateConstraints];
    cell.transform = CGAffineTransformMakeRotation(-M_PI);
//    cell.transform = CGAffineTransformRotate(cell.transform, -M_PI);
    return cell;
}

- (CGFloat)tableView:(UITableView*)tableView heightForRowAtIndexPath:(NSIndexPath*)indexPath
{
    const CGFloat padding = 20;
    NSUInteger index = (self.channel.log.count - 1) - indexPath.row;
    SICLog *log = [self.channel.log objectAtIndex:index];
    CGFloat width;
    if (log.sender) {
        width = 520;
    } else {
        width = 657;
    }
 	CGSize size = [log.body sizeWithFont:[UIFont systemFontOfSize:17] // magic
                       constrainedToSize:CGSizeMake(width, 4000) // magic
                           lineBreakMode:NSLineBreakByCharWrapping];
//    NSLog(@"%@", log.body);
    return size.height + padding;
}

/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    }   
    else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath
{
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

#pragma mark -
#pragma mark UITextFieldDelegate
- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [textField resignFirstResponder];
    return YES;
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Navigation logic may go here. Create and push another view controller.
    /*
     <#DetailViewController#> *detailViewController = [[<#DetailViewController#> alloc] initWithNibName:@"<#Nib name#>" bundle:nil];
     // ...
     // Pass the selected object to the new view controller.
     [self.navigationController pushViewController:detailViewController animated:YES];
     */
}

- (IBAction)sendPrivMsg:(id)sender {
    [self sendMessageWithCommand:@"PRIVMSG"];
}

- (IBAction)sendNotice:(id)sender {
    [self sendMessageWithCommand:@"NOTICE"];
}

- (void)sendMessageWithCommand:(NSString *)cmd
{
    NSString *msg = self.textField.text;
    if (0 < msg.length) {
        SICLog *log = [[SICLog alloc] initWithSender:self.server.nick body: msg];
        if ([cmd isEqualToString:@"PRIVMSG"]) {
            [self.client sendPrivMsg:msg toChannel:self.channel.name];
        } else if ([cmd isEqualToString:@"NOTICE"]) {
            [self.client sendNotice:msg toChannel:self.channel.name];
            log.notice = YES;
        }
        [self.channel addLog:log];
    }
    self.textField.text = @"";
}

- (IBAction)toggleConnection:(id)sender {
    if (self.client.connected) {
        [self changeConnectionControllerStateToDisconnected];
    } else {
        [self changeConnectionControllerStateToConnected];
    }
}

- (void) changeConnectionControllerStateToDisconnected
{
    [self.client disconnect];
    [self.toggleConnectionButton setTitle:@"Connect"];
}

- (void) changeConnectionControllerStateToConnected
{
    [self.client connect];
    [self.toggleConnectionButton setTitle:@"Disconnect"];
}
@end
