//
//  ViewController.m
//  Entrega3
//
//  Created by dedam on 20/1/17.
//  Copyright © 2017 dedam. All rights reserved.
//

#import "ViewController.h"
#import "SoundManager.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    _mapMonumento = [[MKMapView alloc] initWithFrame:self.mapSup.bounds];
    _mapMundo = [[MKMapView alloc] initWithFrame:self.mapInf.bounds];

    [self initJuego];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

//IMPLEMENTANDO METODOS...

-(void) handleLongPressGesture:(UILongPressGestureRecognizer*)paramGestureRecognizer{
    CGPoint touchPoint = [paramGestureRecognizer locationInView:paramGestureRecognizer.view];
    _coordenadaTouch=[_mapMundo convertPoint:touchPoint toCoordinateFromView:_mapInf];
    touchSelected=YES;
    [self mostrarAnotacion:_coordenadaTouch title:@"" subtitle:@""];
}

-(void)initJuego{
    distanciaAcumulada=0;
    _lblDistancia.text=@"0 Km";
    _lblDistancia.textColor=[UIColor redColor];
    _lblResult.text=@"SELECCIONE UN PUNTO SOBRE EL MAPA";
    touchSelected=NO;
    finPartida=NO;
 
    //configuro mundo
    [_mapMundo setDelegate:self];
    [_mapMundo setMapType:MKMapTypeStandard];
    [_mapMundo setAutoresizingMask:UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight];
    [_mapMundo setZoomEnabled:NO];
    
    [self setRegion:CLLocationCoordinate2DMake(40,0) distancia:3000000 enMapa:_mapMundo];
    [self.mapInf addSubview:_mapMundo];

    [self initMonumentos];
    [self selectRandomMonumento];
    
    //GESTURE RECOGNIZER: LONG PRESS
    longPress = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(handleLongPressGesture:)];
    [longPress setNumberOfTouchesRequired:1];
    [longPress setMinimumPressDuration:1];
    [longPress setAllowableMovement:100]; //solo lo puedo desplazar maximo 100 pixeles
    [self.mapInf addGestureRecognizer:longPress];
}

-(void)selectRandomMonumento{
    NSLog(@"Monumentos: %d",(int)monumentos.count);
    if(monumentos.count!=0){
        NSInteger posicionAzar=arc4random()%monumentos.count;
        monumento=[monumentos objectAtIndex:posicionAzar];
        [monumentos removeObjectAtIndex:posicionAzar];
    }
    else{
        finPartida=YES;
    }
    [self mostrarMonumento];

}

-(void) mostrarMonumento{
    //TODO reiniciar cuando acaben los monumentos
    if(!finPartida){
        CLLocationCoordinate2D monumentLocation = CLLocationCoordinate2DMake(monumento.lat, monumento.lng);
        MKMapCamera *camera = [MKMapCamera cameraLookingAtCenterCoordinate:monumentLocation fromDistance:monumento.distancia pitch:monumento.pitch heading:monumento.heading];
        
        OKPressed=NO;
        
        //PREPARO Y DIBUJO MONUMENTO
        [self setRegion:monumentLocation distancia:monumento.distancia enMapa:_mapMonumento];
        
        [_mapMonumento setMapType:MKMapTypeSatelliteFlyover];
        [_mapMonumento setAutoresizingMask:UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight];
        
        [_mapMonumento setZoomEnabled:NO];
        [_mapMonumento setScrollEnabled:NO];
        [_mapMonumento setPitchEnabled:YES];
        [_mapMonumento setCamera:camera animated:NO];
        
        [self.mapSup addSubview: _mapMonumento];
        
        [self setRegion:CLLocationCoordinate2DMake(40,0) distancia:3500000 enMapa:_mapMundo];
        
        _lblResult.text=@"SELECCIONE UN PUNTO SOBRE EL MAPA";
 
    }else{
        UIAlertView *alert=[[UIAlertView alloc]initWithTitle:@"FIN DE LA PARTIDA" message:@"Volver a Jugar?" delegate:self cancelButtonTitle:@"SI" otherButtonTitles:@"NO", nil];
        [alert show];
    }
}

-(void)setRegion:(CLLocationCoordinate2D)centro distancia:(int)distancia enMapa:(MKMapView*)mapa{
    MKCoordinateRegion region = MKCoordinateRegionMakeWithDistance(centro, distancia, distancia);
    [mapa setRegion:region animated:YES];
    [mapa regionThatFits:region];
}

-(IBAction)validarJuego:(id)sender{
    CLLocation *clLocationMonumento = [[CLLocation alloc] initWithLatitude:monumento.lat longitude:monumento.lng];
    CLLocation *clLocationTouch=[[CLLocation alloc] initWithLatitude:_coordenadaTouch.latitude longitude:_coordenadaTouch.longitude];
    CLLocationCoordinate2D monumentLocation = CLLocationCoordinate2DMake(monumento.lat, monumento.lng);
    
    
    if(touchSelected){
        [self.mapInf removeGestureRecognizer:longPress];
        touchSelected=NO;
        OKPressed=YES;
        
        //llamar funcion distancia
        int distanciaError=[self distancia:clLocationTouch hasta:clLocationMonumento];
        [self setRegion:monumentLocation distancia:3500000 enMapa:_mapMundo];
        if(distanciaError<300){
            [[SoundManager sharedManager] prepareToPlayWithSound:@"applause-moderate-03.wav"];
            [[SoundManager sharedManager] playSound:@"applause-moderate-03.wav"];
        }
        else if(distanciaError>=300 && distanciaError<1000){
            [[SoundManager sharedManager] prepareToPlayWithSound:@"applause-light-02.wav"];
            [[SoundManager sharedManager] playSound:@"applause-light-02.wav"];
        }
        else{
            [[SoundManager sharedManager] prepareToPlayWithSound:@"boo-01.wav"];
            [[SoundManager sharedManager] playSound:@"boo-01.wav"];
            
        }
        
        //llamada a mostrarAnotacion
        NSString *ciudadDistancia=[NSString stringWithFormat:@"%@ (%dKm)",monumento.ciudad,distanciaError];
        [self mostrarAnotacion:monumentLocation title:monumento.nombre subtitle:ciudadDistancia];
        
        //muestro datos en label
        NSString *textResult=[NSString stringWithFormat:@"%@ \n %@",monumento.nombre,ciudadDistancia];
        [_lblResult setText:textResult];
        
        //dibujar linea
        [self dibujarLineaDesde:_coordenadaTouch hasta:monumentLocation];
    }
}

-(IBAction)siguienteMonumento:(id)sender{
    
        [self borrarAnotaciones];
        if(OKPressed==NO){
            [monumentos addObject:monumento];
        }
        [self selectRandomMonumento];
        [self.mapInf addGestureRecognizer:longPress];
}

-(int)distancia:(CLLocation*)desde hasta:(CLLocation*)hasta{
    CLLocationDistance kilometros = [hasta distanceFromLocation:desde]/1000;
    distanciaAcumulada+=kilometros;
    NSString *escribeDistancia=[NSString stringWithFormat:@"%d Km",(int)distanciaAcumulada];
     _lblDistancia.text=escribeDistancia;
    return kilometros;
}

-(void)dibujarLineaDesde:(CLLocationCoordinate2D)desde hasta:(CLLocationCoordinate2D)hasta{
    CLLocationCoordinate2D points[2];
    points[1]=desde;
    points[0]=hasta;
    
    MKPolyline *overlayPolyline=[MKPolyline polylineWithCoordinates:points count:2];
    [_mapMundo addOverlay:overlayPolyline];
}

-(void)borrarAnotaciones{
    // Esborro les anteriors
    for (id annotation in _mapMundo.annotations) {
        [_mapMundo removeAnnotation:annotation];
    }
    [_mapMundo removeOverlays:_mapMundo.overlays];
    [_mapMundo removeAnnotations:_mapMundo.annotations];
}

-(void)mostrarAnotacion:(CLLocationCoordinate2D)coordenadas title:(NSString*)titulo subtitle:(NSString*)subtitulo{
    [self borrarAnotaciones];
    
    MKPointAnnotation *nota = [[MKPointAnnotation alloc] init];
    [nota setCoordinate:coordenadas];
    [nota setTitle:titulo];
    [nota setSubtitle:subtitulo];
    
    // Posem el pin en el mapa
    [_mapMundo addAnnotation:nota];
}

-(MKOverlayRenderer*) mapView:(MKMapView *)mapView rendererForOverlay:(nonnull id<MKOverlay>)overlay{
    MKPolylineRenderer *polyrenderer=[[MKPolylineRenderer alloc]initWithOverlay:overlay];
    [polyrenderer setStrokeColor:[UIColor redColor]];
    [polyrenderer setLineWidth:3];
    return polyrenderer;
}

//ALERTA
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    if(buttonIndex==0){
        //NSLog(@"Has apretado OK");
        [self initJuego];
    }
    if(buttonIndex==1){
        [_lblResult setText:@"FIN DEL JUEGO"];
        [self.mapInf removeGestureRecognizer:longPress];
    }
}

-(void) initMonumentos {
    
    Monumento *monumento1 = [[Monumento alloc] init];
    monumento1.nombre = @"La Sagrada Familia";
    monumento1.ciudad = @"BARCELONA";
    monumento1.lat = 41.4028931;
    monumento1.lng = 2.1719068;
    monumento1.distancia = 450;
    monumento1.pitch = 80;
    monumento1.heading = 70;
    
    Monumento *monumento2 = [[Monumento alloc] init];
    monumento2.nombre = @"La Puerta de Alcalá";
    monumento2.ciudad = @"MADRID";
    monumento2.lat = 40.420788;
    monumento2.lng = -3.688876;
    monumento2.distancia = 200;
    monumento2.pitch = 25;
    monumento2.heading = 230;
  
    Monumento *monumento3 = [[Monumento alloc] init];
    monumento3.nombre = @"Empire State";
    monumento3.ciudad = @"NEW YORK";
    monumento3.lat = 40.748327;
    monumento3.lng = -73.985471;
    monumento3.distancia = 925;
    monumento3.pitch = 45;
    monumento3.heading = 170;
    
    Monumento *monumento4 = [[Monumento alloc] init];
    monumento4.nombre = @"La Torre Eiffel";
    monumento4.ciudad = @"PARÍS";
    monumento4.lat = 48.8583701;
    monumento4.lng = 2.2922926;
    monumento4.distancia = 1200;
    monumento4.pitch = 60;
    monumento4.heading = 60;
    
    Monumento *monumento5 = [[Monumento alloc] init];
    monumento5.nombre = @"El Coliseo";
    monumento5.ciudad = @"ROMA";
    monumento5.lat = 41.8902102;
    monumento5.lng = 12.4900422;
    monumento5.distancia = 250;
    monumento5.pitch = 80;
    monumento5.heading = 75;
    
    Monumento *monumento6 = [[Monumento alloc] init];
    monumento6.nombre = @"La Casa Blanca";
    monumento6.ciudad = @"WASHINGTON";
    monumento6.lat = 38.8976815;
    monumento6.lng = -77.0368423;
    monumento6.distancia = 500;
    monumento6.pitch = 45;
    monumento6.heading = 0;
    
    Monumento *monumento7 = [[Monumento alloc] init];
    monumento7.nombre = @"El Big Ben";
    monumento7.ciudad = @"LONDRES";
    monumento7.lat = 51.5007292;
    monumento7.lng = -0.1268141;
    monumento7.distancia = 550;
    monumento7.pitch = 80;
    monumento7.heading = 260;
    
    Monumento *monumento8 = [[Monumento alloc] init];
    monumento8.nombre = @"El Kremlin";
    monumento8.ciudad = @"MOSCÚ";
    monumento8.lat = 55.751382;
    monumento8.lng = 37.618446;
    monumento8.distancia = 600;
    monumento8.pitch = 30;
    monumento8.heading = 280;
    
    Monumento *monumento9 = [[Monumento alloc] init];
    monumento9.nombre = @"Tokyo Tower";
    monumento9.ciudad = @"TOKYO";
    monumento9.lat = 35.6585805;
    monumento9.lng = 139.7448857;
    monumento9.distancia = 900;
    monumento9.pitch = 45;
    monumento9.heading = 0;
    
    Monumento *monumento10 = [[Monumento alloc] init];
    monumento10.nombre = @"La Opera";
    monumento10.ciudad = @"SIDNEY";
    monumento10.lat = -33.857033;
    monumento10.lng = 151.215191;
    monumento10.distancia = 500;
    monumento10.pitch = 45;
    monumento10.heading = 110;
    
    Monumento *monumento11 = [[Monumento alloc] init];
    monumento11.nombre = @"El Partenón";
    monumento11.ciudad = @"ATENES";
    monumento11.lat = 37.971402;
    monumento11.lng = 23.726591;
    monumento11.distancia = 500;
    monumento11.pitch = 65;
    monumento11.heading = 0;
    
    Monumento *monumento12 = [[Monumento alloc] init];
    monumento12.nombre = @"Plaza de la Constitución";
    monumento12.ciudad = @"MEXICO DF";
    monumento12.lat = 19.4319642;
    monumento12.lng = -99.1333981;
    monumento12.distancia = 500;
    monumento12.pitch = 45;
    monumento12.heading = 0;
    
    Monumento *monumento13 = [[Monumento alloc] init];
    monumento13.nombre = @"Santa Sofía";
    monumento13.ciudad = @"ISTANBUL";
    monumento13.lat = 41.005270;
    monumento13.lng = 28.976960;
    monumento13.distancia = 500;
    monumento13.pitch = 45;
    monumento13.heading = 0;
    
    Monumento *monumento14 = [[Monumento alloc] init];
    monumento14.nombre = @"La Puerta de Brandenburgo";
    monumento14.ciudad = @"BERLÍN";
    monumento14.lat = 52.5162746;
    monumento14.lng = 13.3755153;
    monumento14.distancia = 400;
    monumento14.pitch = 75;
    monumento14.heading = 260;
    
    Monumento *monumento15 = [[Monumento alloc] init];
    monumento15.nombre = @"La Plaza de Mayo";
    monumento15.ciudad = @"BUENOS AIRES";
    monumento15.lat = -34.6080556;
    monumento15.lng = -58.3724665;
    monumento15.distancia = 500;
    monumento15.pitch = 45;
    monumento15.heading = 75;
    
    monumentos = [NSMutableArray arrayWithObjects:monumento1, monumento2, monumento3, monumento4, monumento5, monumento6, monumento7, monumento8, monumento9, monumento10, monumento11, monumento12, monumento13, monumento14, monumento15, nil];
}

@end
