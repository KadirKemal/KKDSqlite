//
//  citiesViewController.m
//  KKDSqlite_Example
//
//  Created by Kadir Kemal Dursun on 22/10/2017.
//  Copyright © 2017 kadirkemal. All rights reserved.
//

#import "citiesViewController.h"
#import "City.h"

@interface citiesViewController ()<UITableViewDataSource, UITableViewDelegate>

@property (weak, nonatomic) IBOutlet UITableView *table;
@property NSMutableArray *cityList;

@end

@implementation citiesViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    _cityList = [City modelListFromDB:[NSDictionary dictionaryWithObjectsAndKeys:@(_country.id), @"countryId", nil]];
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return _cityList.count + 2;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    static NSString *CityCellIdentifier = @"CityCellIdentifier";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CityCellIdentifier];
    
    if(indexPath.row < _cityList.count){
        City *city = [_cityList objectAtIndex:indexPath.row];
        cell.textLabel.text = city.name;
        cell.backgroundColor = [UIColor grayColor];
    }else if(indexPath.row == _cityList.count){
        cell.textLabel.text = @"Add New City";
        cell.backgroundColor = [UIColor greenColor];
    }else{
        cell.textLabel.text = @"Delete country and cities in one transaction!";
        cell.backgroundColor = [UIColor redColor];
    }
    
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    City *city;
    if(indexPath.row < _cityList.count){
        city = [_cityList objectAtIndex:indexPath.row];
        [self showCityDetail:city];
    }else if(indexPath.row == _cityList.count){
        city = [City new];
        city.countryId = _country.id;
        [self showCityDetail:city];
    }else{
        [self deleteCountry];
    }
}

-(void) showCityDetail:(City *) city{
    __weak typeof(self) weakSelf = self;
    
    UIAlertController * alert=   [UIAlertController
                                  alertControllerWithTitle:_country.name
                                  message: @"Enter the name of city"
                                  preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction* ok = [UIAlertAction actionWithTitle:@"Save" style:UIAlertActionStyleDefault
                                               handler:^(UIAlertAction * action) {
                                                   city.name = ((UITextField *)[alert.textFields objectAtIndex:0]).text;
                                                   [weakSelf saveCity:city];
                                               }];
    UIAlertAction* delete = [UIAlertAction actionWithTitle:@"Delete" style:UIAlertActionStyleDefault
                                                   handler:^(UIAlertAction * action) {
                                                       [weakSelf deleteCity:city];
                                                   }];
    UIAlertAction* cancel = [UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleDefault
                                                   handler:^(UIAlertAction * action) {
                                                       [alert dismissViewControllerAnimated:YES completion:nil];
                                                   }];
    
    [alert addAction:ok];
    if(! city.isNew){
        [alert addAction:delete];;
    }
    [alert addAction:cancel];
    
    [alert addTextFieldWithConfigurationHandler:^(UITextField *textField) {
        textField.text = city.name;
    }];
    
    [self presentViewController:alert animated:YES completion:nil];
}

-(void) saveCity:(City *) city{
    bool isNewCity = city.isNew;
    
    [city saveMe];
    if(isNewCity){
        [_cityList addObject:city];
    }
    
    [_table reloadData];
}

-(void) deleteCity:(City *) city{
    [city deleteMe];
    [_cityList removeObject:city];
    [_table reloadData];
}

-(void) deleteCountry{
    [_country deleteMeWith:_cityList];
    [self.navigationController popViewControllerAnimated:YES];
}

@end
