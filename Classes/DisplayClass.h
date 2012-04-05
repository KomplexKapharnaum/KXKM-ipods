//
//  DisplayClass.h
//  KXKM
//
//  Created by Snow Leopard User on 08/02/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface DisplayClass : NSObject {

    UIWindow *_secondWindow;
    NSString *screenResolution;
    
    //views
    UIView *liveview;
        UIView *live1view;
        UIView *live2view;
    
    UIView *movieview;
        UIView *movie1view;
        UIView *movie2view;
    
    UIView *mirview;
    UIView *muteview;
    UIView *fadeview;
    UIView *flashview;
    UIView *titlesview;
    
    //Colors
    int flashcolorRed;
    int flashcolorGreen;
    int flashcolorBlue;
    int flashcolorAlpha;
    
    int fadecolorRed;
    int fadecolorGreen;
    int fadecolorBlue;
    int fadecolorAlpha;
    
    int titlescolorRed;
    int titlescolorGreen;
    int titlescolorBlue;
    int titlescolorAlpha;

    NSString *customTitles;
    int titlesCounter;
    int titlesMode;
    NSArray *subTitles;
    UILabel* soustitres;
    UILabel* soustitres2;
}

@property (nonatomic, retain) IBOutlet UIWindow *_secondWindow;
@property (nonatomic, retain) NSString *screenResolution;

@property (nonatomic,retain) UIView *liveview;
@property (nonatomic,retain) UIView *live1view;
@property (nonatomic,retain) UIView *live2view;

@property (nonatomic,retain) UIView *movieview;
@property (nonatomic,retain) UIView *movie1view;
@property (nonatomic,retain) UIView *movie2view;

@property (nonatomic,retain) UIView *muteview;
@property (nonatomic,retain) UIView *mirview;
@property (nonatomic,retain) UIView *fadeview;
@property (nonatomic,retain) UIView *flashview;
@property (nonatomic,retain) UIView *titlesview;


-(BOOL) checkScreen;
-(NSString*) resolution;

-(void) mute:(BOOL)muteMe;
-(BOOL) muted;

-(void) mir:(BOOL)mirDisp;
-(BOOL) mired;

-(void) fade:(BOOL)fadeMe;
-(void) fadeColor:(int)Red:(int)Green:(int)Blue:(int)Alpha;
-(BOOL) faded;

-(void) flash;
-(void) flashColor:(int)Red:(int)Green:(int)Blue:(int)Alpha;

-(void) titles;
-(void) titlesColor:(int)Red:(int)Green:(int)Blue:(int)Alpha;
-(void) titlesText:(NSString*) txt;

-(void) live:(BOOL)go;

@end
