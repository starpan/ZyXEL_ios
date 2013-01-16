//
//  MenuViewController.m
//  ECSlidingViewController
//
//  Created by Michael Enriquez on 1/23/12.
//  Copyright (c) 2012 EdgeCase. All rights reserved.
//

#import "MenuViewController.h"

@interface MenuViewController()
@property (nonatomic, strong) NSArray *menuItems;
@end

@implementation MenuViewController
@synthesize menuItems;

- (void)awakeFromNib
{
  self.menuItems = [NSArray arrayWithObjects:@"Guest Wi-Fi", @"Search Device", @"Info", @"Settings", nil];
}

- (void)viewDidLoad
{
  [super viewDidLoad];
  
  [self.slidingViewController setAnchorRightRevealAmount:256.0f];
  self.slidingViewController.underLeftWidthLayout = ECFullWidth;
    UILabel* menutitle = [[UILabel alloc] init];
    menutitle.frame =CGRectMake(0.0f, 0.0f, 260,44);
    menutitle.text = @"MENU";
    menutitle.textColor = [UIColor whiteColor];
    menutitle.backgroundColor = [UIColor clearColor];
    menutitle.textAlignment = UITextAlignmentCenter;
    UIImageView *barimgview = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"bg_menubar_blue.png"]];
    CGRect bartestframe = CGRectMake(0.0f, 0.0f, 320,44);
    [barimgview setFrame:bartestframe];
    
    
    [self.view addSubview:barimgview];
    [self.view addSubview:menutitle];
    self.view.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"bg_menu.png"]];
  
}
- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    if (menutable) {
        [menutable reloadData];
    }

}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 60;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)sectionIndex
{
  return self.menuItems.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
  NSString *cellIdentifier = @"MenuItemCell";
  tableView.backgroundColor = [UIColor clearColor];
    menutable = tableView;
    CGRect testframe = CGRectMake(20.0f, 64.0f,288,240 );//self.view.bounds.size.width,self.view.bounds.size.height);
    [tableView setFrame:testframe];
  UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
  if (cell == nil) {
    cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:cellIdentifier];
  }
  
  //cell.textLabel.text = [self.menuItems objectAtIndex:indexPath.row];

    if (indexPath.row == 0) {
        cell.backgroundView = [ [[UIImageView alloc] initWithImage:[ [UIImage imageNamed:@"btn_menu_guest_1.png"] stretchableImageWithLeftCapWidth:0.0 topCapHeight:5.0] ]autorelease];
        cell.selectedBackgroundView = [ [[UIImageView alloc] initWithImage:[ [UIImage imageNamed:@"btn_menu_guest_2.png"] stretchableImageWithLeftCapWidth:0.0 topCapHeight:5.0] ]autorelease];
    }else if(indexPath.row == 1)
    {
        cell.backgroundView = [ [[UIImageView alloc] initWithImage:[ [UIImage imageNamed:@"btn_menu_search_1.png"] stretchableImageWithLeftCapWidth:0.0 topCapHeight:5.0] ]autorelease];
        cell.selectedBackgroundView = [ [[UIImageView alloc] initWithImage:[ [UIImage imageNamed:@"btn_menu_search_2.png"] stretchableImageWithLeftCapWidth:0.0 topCapHeight:5.0] ]autorelease];
    }else if(indexPath.row == 2)
    {
        cell.backgroundView = [ [[UIImageView alloc] initWithImage:[ [UIImage imageNamed:@"btn_menu_info_1.png"] stretchableImageWithLeftCapWidth:0.0 topCapHeight:5.0] ]autorelease];
        cell.selectedBackgroundView = [ [[UIImageView alloc] initWithImage:[ [UIImage imageNamed:@"btn_menu_info_2.png"] stretchableImageWithLeftCapWidth:0.0 topCapHeight:5.0] ]autorelease];
    }else if(indexPath.row == 3)
    {
        cell.backgroundView = [ [[UIImageView alloc] initWithImage:[ [UIImage imageNamed:@"btn_menu_settings_1.png"] stretchableImageWithLeftCapWidth:0.0 topCapHeight:5.0] ]autorelease];
        cell.selectedBackgroundView = [ [[UIImageView alloc] initWithImage:[ [UIImage imageNamed:@"btn_menu_settings_2.png"] stretchableImageWithLeftCapWidth:0.0 topCapHeight:5.0] ]autorelease];
    }
  
    tableView.scrollEnabled = NO;
  return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
  NSString *identifier = [NSString stringWithFormat:@"%@", [self.menuItems objectAtIndex:indexPath.row]];

  UIViewController *newTopViewController = [self.storyboard instantiateViewControllerWithIdentifier:identifier];
    //newTopViewController.connection = self.slidingViewController.topViewController.connection;
  [self.slidingViewController anchorTopViewOffScreenTo:ECRight animations:nil onComplete:^{
    CGRect frame = self.slidingViewController.topViewController.view.frame;
    self.slidingViewController.topViewController = newTopViewController;
    self.slidingViewController.topViewController.view.frame = frame;
    [self.slidingViewController resetTopView];

  }];
}

@end
