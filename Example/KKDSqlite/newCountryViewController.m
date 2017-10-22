//
//  newCountryViewController.m
//  KKDSqlite_Example
//
//  Created by Kadir Kemal Dursun on 22/10/2017.
//  Copyright © 2017 kadirkemal. All rights reserved.
//

#import "newCountryViewController.h"

#import "Country.h"
#import "City.h"

@interface newCountryViewController ()

@property (weak, nonatomic) IBOutlet UITextField *txtCountryName;

@property (weak, nonatomic) IBOutlet UITextField *txtCityName1;
@property (weak, nonatomic) IBOutlet UITextField *txtCityName2;
@property (weak, nonatomic) IBOutlet UITextField *txtCityName3;
@property (weak, nonatomic) IBOutlet UITextField *txtCityName4;
@property (weak, nonatomic) IBOutlet UITextField *txtCityName5;


@end

@implementation newCountryViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (IBAction)onClickSave:(id)sender {
    NSString *countryName = _txtCountryName.text;
    if(countryName.length == 0){
        return;
    }
    
    Country *country = [Country new];
    country.name = countryName;
    
    NSMutableArray<SqliteBaseData *> *cityList = [NSMutableArray new];
    [self addCityToList:_txtCityName1.text list:cityList];
    [self addCityToList:_txtCityName2.text list:cityList];
    [self addCityToList:_txtCityName3.text list:cityList];
    [self addCityToList:_txtCityName4.text list:cityList];
    [self addCityToList:_txtCityName5.text list:cityList];
    
    [country saveMeWithChildren:cityList];
    [self.navigationController popViewControllerAnimated:YES];
}

-(void) addCityToList:(NSString *)name list:(NSMutableArray<SqliteBaseData *> *)arr{
    if(name.length > 0){
        City *city = [City new];
        city.name = name;
        [arr addObject:city];
    }
}


@end
