//
//  Monumento.h
//  Entrega3
//
//  Created by dedam on 20/1/17.
//  Copyright © 2017 dedam. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface Monumento : UIView

@property(nonatomic,strong) NSString *nombre;
@property(nonatomic,strong) NSString *ciudad;
@property(nonatomic,assign) CGFloat lat;
@property(nonatomic,assign) CGFloat lng;
@property(nonatomic,assign) CGFloat distancia;
@property(nonatomic,assign) CGFloat pitch;
@property(nonatomic,assign) CGFloat heading;

@end
