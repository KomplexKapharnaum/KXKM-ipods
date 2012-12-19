//
//  ConfigConst.h
//  KXKM
//
//  Created by Snow Leopard User on 09/02/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#ifndef KXKM_ConfigConst_h
#define KXKM_ConfigConst_h


//###########################################################
// CONFIGURATION & CONSTANTS

//TITRAGE
#define ERASE_TIME          30  //temps d'effacement des titrages en seconde

//TIMERS
#define TIMER_RUN           0.1 //10ms   Runner : recieved orders
#define TIMER_CHECK         0.8  //800ms  Checker : IP / Screen / ..
#define TIMER_RELMOVIE      0.4  //400ms  Movie Releaser (remove movie in the back)

//CHECKER SUB-TIMERS
#define TIMER_CHECK_HOME    6     // IN AUTO : CHECK TICKS BEFORE GOING BACK ON HOME PAGE  // 0 TO DISABLE
#define TIMER_CHECK_USER    40    // CHECK TICKS BEFORE EXIT FILE-LIST PAGE
#define TIMER_CHECK_BATT    300   // CHECK TICKS BEFORE REFRESH BATTERY STATE  // 0 TO DISABLE
#define TIMER_CHECK_BROAD    10   // CHECK TICKS TO RE-ASK IP REGIE WHEN BROADCAST MODE

//PLAYER TYPES
#define PLAYER_LOCAL       0
#define PLAYER_STREAM      1

//MODES
#define UNKNOWN     0
#define AUTO        1
#define MANU        2

//VIEWS INIT 
#define VIEW_MIR        YES
#define VIEW_MUTE       NO
#define VIEW_FADE       NO

//EFFECTS
#define FLASH_LENGHT   0.35   //flash duration

//SEGMENT BUFFER LIVE MODE
#define LIVE_BUFFER    2

//RECODER
#define CAPTURE_FRAMES_PER_SECOND   30

//DEBUG
#define DEBUG_PLAYERS   NO   //separate and colorize rotative players views

//HTTP SERVER PORT
//#define HTTP_PORT   8074 unused: TODO make it configurable or sended by the server


#endif
