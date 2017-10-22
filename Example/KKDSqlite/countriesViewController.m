//
//  countriesViewController.m
//  KKDSqlite_Example
//
//  Created by Kadir Kemal Dursun on 22/10/2017.
//  Copyright © 2017 kadirkemal. All rights reserved.
//

#import "countriesViewController.h"
#import "Country.h"
#import "citiesViewController.h"

@interface countriesViewController ()<UITableViewDataSource, UITableViewDelegate>

@property (weak, nonatomic) IBOutlet UITableView *table;

@property NSArray *countryList;

@end

@implementation countriesViewController

- (void)viewDidLoad {
    [super viewDidLoad];
}


- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if([segue.identifier isEqualToString:@"cityList"]){
        citiesViewController *vc = segue.destinationViewController;
        vc.country = [_countryList objectAtIndex:_table.indexPathForSelectedRow.row];
    }
}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    
    _countryList = [Country modelListFromDB:nil orderBy:@"order by name"];
    [_table reloadData];
}



-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return _countryList.count + 1;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    static NSString *CountryCellIdentifier = @"CountryCellIdentifier";
    static NSString *NewCountryCellIdentifier = @"NewCountryCellIdentifier";
    
    UITableViewCell *cell;
    if(indexPath.row < _countryList.count){
        Country *country = [_countryList objectAtIndex:indexPath.row];
        
        cell = [tableView dequeueReusableCellWithIdentifier:CountryCellIdentifier];
        cell.textLabel.text = country.name;
        cell.backgroundColor = [UIColor grayColor];
    }else{
        cell = [tableView dequeueReusableCellWithIdentifier:NewCountryCellIdentifier];
        cell.textLabel.text = @"New Country";
        cell.backgroundColor = [UIColor greenColor];
    }
    
    
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    return cell;
}


@end
