//
//  ViewController.h
//  Entrega3
//
//  Created by dedam on 20/1/17.
//  Copyright © 2017 dedam. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>
#import "Monumento.h"

@interface ViewController : UIViewController <MKMapViewDelegate,UIAlertViewDelegate>
{
    NSMutableArray *monumentos;
    Monumento *monumento;
    CGFloat distanciaAcumulada;
    UILongPressGestureRecognizer *longPress;
    BOOL touchSelected;
    BOOL OKPressed;
    BOOL finPartida;
}

@property(readwrite,nonatomic) CLLocationCoordinate2D coordenadaTouch;

@property (strong, nonatomic) IBOutlet UIView *mapSup;
@property (strong, nonatomic) IBOutlet UIView *mapInf;
@property(nonatomic,strong) MKMapView *mapMonumento;
@property(nonatomic,strong) MKMapView *mapMundo;


@property (strong, nonatomic) IBOutlet UILabel *lblResult;
@property (strong, nonatomic) IBOutlet UILabel *lblDistancia;
@property (strong, nonatomic) IBOutlet UIButton *btnValida;
@property (strong, nonatomic) IBOutlet UIButton *btnNext;

- (IBAction)siguienteMonumento:(id)sender;
- (IBAction)validarJuego:(id)sender;


@end

