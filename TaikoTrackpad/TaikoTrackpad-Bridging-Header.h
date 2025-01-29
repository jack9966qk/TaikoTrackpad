//
//  TaikoTrackpad-Bridging-Header.h
//  TaikoTrackpad
//
//  Created by Jack on 2021/8/14.
//

#ifndef TaikoTrackpad_Bridging_Header_h
#define TaikoTrackpad_Bridging_Header_h

#import <CoreGraphics/CoreGraphics.h>

typedef int CGSConnectionID;

CGError CGSSetConnectionProperty(
    CGSConnectionID cid,
    CGSConnectionID targetCID,
    CFStringRef key,
    CFTypeRef value);

int _CGSDefaultConnection();

#endif /* TaikoTrackpad_Bridging_Header_h */
