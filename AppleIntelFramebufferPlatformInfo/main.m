//
//  main.m
//  AppleIntelFramebufferPlatformInfo
//
//  Created by Muntashir Al-Islam on 7/25/17.
//  Copyright © 2017 Muntashir Al-Islam. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "platform_data.h"

//
// Use NSLog for formatted print
//
#define NSLog(FORMAT, ...) printf("%s\n", [[NSString stringWithFormat:FORMAT, ##__VA_ARGS__] UTF8String]);

//#define SLE       @"/System/Library/Extensions/"
#define SLE       @"/Users/muntashir/Desktop/Playground/10.13.pb3/"
#define LC_SYMTAB @"02000000"     // 0x02000000
#define _gPlatformInformationList @"5f67506c6174666f726d496e666f726d6174696f6e4c697374" // Hex representation of _gPlatformInformationList (IvyBridge and later)
#define _PlatformInformationList  @"5F506C6174666F726D496E666F726D6174696F6E4C697374"   // Hex representation of _PlatformInformationList (SandyBridge)
#define read_byte 8192*2          // read 8192 bytes

//
// Platform table constants
//
#define PlatformTableEnd   @"fffffff"
#define FourBit 4*2

#define FBName                    @"name"
#define FBConnectorTableRowLength @"pt_len"
#define FBDVMTStart               @"dvmt_start"
#define FBDVMTLength              @"svmt_len"

NSMutableDictionary *fbKBL;  // KabyLake
NSMutableDictionary *fbSKL;  // SkyLake
NSMutableDictionary *fbBDW;  // Broadwell
NSMutableDictionary *fbAzul; // Haswell
NSMutableDictionary *fbCapri;// IvyBridge
NSMutableDictionary *fbSNB;  // SandyBridge
NSMutableDictionary *fbHD;   // HD Graphics

NSArray<NSMutableDictionary *> *gFramebuffers;
NSInteger currentFramebuffer;

//
// Initialise globals (since it cannot be done on compile-time)
//
void init(){
    // KabyLake
    fbKBL = [NSMutableDictionary dictionaryWithObjectsAndKeys:
             @"AppleIntelKBLGraphicsFramebuffer", FBName,
             @46, FBConnectorTableRowLength,
             @4, FBDVMTStart,
             @3, FBDVMTLength, nil];
    // SkyLake
    fbSKL = [fbKBL mutableCopy];
    [fbSKL setObject:@"AppleIntelSKLGraphicsFramebuffer" forKey:FBName];
    // Broadwell
    fbBDW = [NSMutableDictionary dictionaryWithObjectsAndKeys:
             @"AppleIntelBDWGraphicsFramebuffer", FBName,
             @34, FBConnectorTableRowLength,
             @0, FBDVMTStart,
             @4, FBDVMTLength, nil];
    // Haswell
    fbAzul = [fbBDW mutableCopy];
    [fbAzul setValue:@"AppleIntelFramebufferAzul" forKey:FBName];
    [fbAzul setValue:@28 forKey:FBConnectorTableRowLength];
    [fbAzul setValue:@5 forKey:FBDVMTLength];
    // IvyBridge: DVMT unknown
    fbCapri = [NSMutableDictionary dictionaryWithObjectsAndKeys:
             @"AppleIntelFramebufferCapri", FBName,
             @50, FBConnectorTableRowLength,
             @0, FBDVMTStart,
             @0, FBDVMTLength, nil];
    // SandyBridge: DVMT unknown, uses snb-platform-id
    fbSNB = [fbCapri mutableCopy];
    [fbSNB setValue:@"AppleIntelSNBGraphicsFB" forKey:FBName];
    [fbSNB setValue:@15 forKey:FBConnectorTableRowLength];
    // HD Graphics
    fbHD = [NSMutableDictionary dictionaryWithObjectsAndKeys:
            @"AppleIntelHDGraphicsFB", FBName,
            @0, FBConnectorTableRowLength,
            @0, FBDVMTStart,
            @0, FBDVMTLength, nil];
    
    // global framebuffer array
    gFramebuffers = @[fbHD, fbSNB, fbCapri, fbAzul, fbBDW, fbSKL, fbKBL];
}

//
// Reverse the hex pair
//
NSString *reverseHex(NSString *oldHex){
    NSInteger n = [oldHex length];
    NSMutableString *newHex = [NSMutableString string];
    for(NSInteger i = n-2; i>=0; i-=2){
        [newHex appendString:[oldHex substringWithRange:NSMakeRange(i, 2)]];
    }
    return newHex;
}

//
// Hex to integer
//
unsigned hexToInt(NSString *hex){
    unsigned integer;
    [[NSScanner scannerWithString:hex] scanHexInt:&integer];
    return integer;
}

 /*
NSMutableArray *getDVMTPrealloc(NSString *hex_data){
    NSMutableArray *PTRows = [[NSMutableArray alloc] init];
    for (NSString *PTRow in getConnectorTable(hex_data, NO)) {
        [PTRows addObject:[PTRow substringWithRange:NSMakeRange([gFramebuffers[currentFramebuffer][FBDVMTStart] integerValue] * EightBit, [gFramebuffers[currentFramebuffer][FBDVMTLength] integerValue] * FourBit)]];
    }
    return PTRows;
}*/

//
// Get connector data offset
//
// idea-credit @Piker-Alpha
// @see https://github.com/Piker-Alpha/AppleIntelFramebufferAzul.sh/blob/master/AppleIntelFramebufferAzul.sh
//
// This is an alternative to the single command:
// `nm -t d -Ps __DATA __data -arch "x86_64" <TARGET_FILE> | grep '_gPlatformInformationList'`
// which doesn't exist in most of the PC's (so the long way around)
//
// NOTE: For AppleIntelSNBGraphicsFB, _gPlatformInformationList is _PlatformInformationList, and
//       for AppleIntelHDGraphicsFB,  there's no platform information list at all
//
// Returns gConnectorTableOffset or zero
//
unsigned getConnectorTableOffset(NSString *hex_data){
    unsigned gConnectorTableOffset = 0;
    //
    // Return false if AppleIntelHDGraphicsFB is given
    //
    if(currentFramebuffer == AppleIntelHDGraphicsFB || [hex_data length] == 0) return gConnectorTableOffset;
    //
    // Get load command
    //
    unsigned sizeOfLoadCommands = hexToInt(reverseHex([hex_data substringWithRange:NSMakeRange(40, 8)]));
             sizeOfLoadCommands+= 32;
             sizeOfLoadCommands*= 2;
    NSString *loadCommands      = [hex_data substringWithRange:NSMakeRange(0, sizeOfLoadCommands)];
    //
    // Get table info
    //
    unsigned commandSize        = 0;
    unsigned gSymbolTableOffset = 0;
    unsigned gNumberOfSymbols   = 0;
    unsigned gStringTableOffset = 0;
    unsigned gStringTableSize   = 0;
    NSString *command           = [NSString string];
             sizeOfLoadCommands*= 2;
    for (NSInteger i=64; i<sizeOfLoadCommands; ) {
        command = [loadCommands substringWithRange:NSMakeRange(i, 8)];
        commandSize = hexToInt(reverseHex([loadCommands substringWithRange:NSMakeRange(i + 8, 8)]));
        if([command  isEqual: LC_SYMTAB]){
            gSymbolTableOffset = hexToInt(reverseHex([loadCommands substringWithRange:NSMakeRange(i + 16, 8)])) * 2;
            gNumberOfSymbols   = hexToInt(reverseHex([loadCommands substringWithRange:NSMakeRange(i + 24, 8)])) * 2;
            gStringTableOffset = hexToInt(reverseHex([loadCommands substringWithRange:NSMakeRange(i + 32, 8)])) * 2;
            gStringTableSize   = hexToInt(reverseHex([loadCommands substringWithRange:NSMakeRange(i + 40, 8)])) * 2;
            break;
        }else{
            i+=commandSize*2;
        }
    }
    //
    // Get table data
    //
    NSString *gStringTableData = [hex_data substringWithRange:NSMakeRange(gStringTableOffset, gStringTableSize)];
    NSString *pattern          = [NSString stringWithFormat:@"%@[0-9a-f]*", currentFramebuffer == AppleIntelSNBGraphicsFB ? _PlatformInformationList : _gPlatformInformationList]; // Different PlatformInformationList for SandyBridge
    NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:pattern options:NSRegularExpressionCaseInsensitive error:NULL];
    gStringTableData           = [regex stringByReplacingMatchesInString:gStringTableData options:0 range:NSMakeRange(0, [gStringTableData length]) withTemplate:@""];
    unsigned gPILOffset        = gStringTableOffset+(unsigned)[gStringTableData length];
    //NSLog(@"%hhd", [[hex_data substringWithRange:NSMakeRange(gPILOffset, 25*2)] isEqual:_gPlatformInformationList]);
    // it means _gPlatformInformationList is found at `gPILOffset`, useful for debugging
    
    //
    // Get symbol table data and analyze
    //
    unsigned symbolTablestart  = gSymbolTableOffset;
    unsigned symbolTablelength = gNumberOfSymbols * 16 * 2;
    unsigned symbolTableEnd    = gSymbolTableOffset + symbolTablelength;
    NSString *symbolTableData  = [NSString string];
    unsigned stringTableIndex;
    unsigned currentAddress;
    //unsigned stringTableOffset     = 0; // Useful for debugging
    while(symbolTablestart < symbolTableEnd){
        symbolTableData        = [hex_data substringWithRange:NSMakeRange(symbolTablestart, read_byte)];
        for (NSInteger i = 0; i<read_byte; ) {
            stringTableIndex   = hexToInt(reverseHex([symbolTableData substringWithRange:NSMakeRange(i, 8)]));
            currentAddress     = gStringTableOffset + (stringTableIndex * 2);
            if(gPILOffset == currentAddress){
                gConnectorTableOffset = hexToInt(reverseHex([symbolTableData substringWithRange:NSMakeRange(i + 16, 8)]));
                //stringTableOffset     = symbolTablestart + (unsigned)i;
                break;
            }else{
                i+=32;
            }
        }
        symbolTablestart+=read_byte;
    }
    return gConnectorTableOffset;
}


//
// Get connector table from framebuffer
//
// FIXME: No valid implementation for AppleIntelSNBGraphicsFB
//
NSMutableArray<NSString *> *getConnectorTable(NSString *hex_data, unsigned gConnectorTableOffset, BOOL onlyIGPlatformID){
    //
    // Return nil if it cannot locate gConnectorTableOffset
    //
    if(gConnectorTableOffset == 0) return nil;
    
    //
    // Extract platform table rows
    //
    gConnectorTableOffset*=2;
    NSString *pattern = [NSString stringWithFormat:@"([0-9a-e]+F{0,7})+"];
    NSRegularExpression *regex   = [NSRegularExpression regularExpressionWithPattern:pattern options:NSRegularExpressionCaseInsensitive error:nil];
    NSTextCheckingResult *result = [regex firstMatchInString:hex_data options:0 range:NSMakeRange(gConnectorTableOffset, [hex_data length]-gConnectorTableOffset)];
    NSString *connectorTable     = [[hex_data substringWithRange:[result range]] stringByReplacingOccurrencesOfString:PlatformTableEnd withString:@""];
    //NSLog(@"%@", connectorTable);
    NSInteger connectorTableLength     = [connectorTable length];
    NSInteger connectorTableRowLength  = FourBit * [gFramebuffers[currentFramebuffer][FBConnectorTableRowLength] integerValue];
    NSInteger connectorTableRowTotal   = connectorTableLength / connectorTableRowLength;
    NSMutableArray<NSString *> *connectorTableRows = [[NSMutableArray alloc] init];
    //NSLog(@"Connector Table Total Rows: %ld\nRows:", connectorTableRowTotal);
    
    for(NSInteger i = 0; i < connectorTableRowTotal; ++i){
        [connectorTableRows addObject:[connectorTable substringWithRange:NSMakeRange(i * connectorTableRowLength, onlyIGPlatformID ? FourBit : connectorTableRowLength)]];
        //NSLog(@"%ld. %@", i+1, [connectorTableRows objectAtIndex:i]);
        // Reverse string if only ig-platform-id is requested
        if(onlyIGPlatformID)
            [connectorTableRows setObject:reverseHex([connectorTableRows objectAtIndex:i]) atIndexedSubscript:i];
    }
    return connectorTableRows;
}


//
// main function
//
int main(int argc, const char * argv[]) {
    @autoreleasepool {
        init();
        //
        // Changing this value changes the framebuffer
        //
        currentFramebuffer = AppleIntelKBLGraphicsFramebuffer;
        
        //
        // Get data
        //
        NSString *FramebufferName = gFramebuffers[currentFramebuffer][FBName];
        NSString *binary_path     = [NSString stringWithFormat:SLE @"%@.kext/Contents/MacOS/%@", FramebufferName, FramebufferName];
        NSData   *data            = [NSData dataWithContentsOfFile:binary_path];
        BOOL onlyIGPlatformID     = YES;
        
        //
        // data to hex string
        //
        NSMutableString* hex_data = [NSMutableString string];
        
        [data enumerateByteRangesUsingBlock:^(const void *bytes, NSRange byteRange, BOOL *stop){
            for (NSUInteger i = 0; i < byteRange.length; ++i){
                [hex_data appendFormat:@"%02x", ((uint8_t*)bytes)[i]];
            }
        }];
        
        //
        // Connector table info
        //
        unsigned gConnectorTableOffset = getConnectorTableOffset(hex_data);
        NSArray *gConnectorTable       = getConnectorTable(hex_data, gConnectorTableOffset, onlyIGPlatformID);
        
        //
        // Output
        //
        NSLog(@"Current Framebuffer: %@ (id: %ld)", FramebufferName, currentFramebuffer);
        NSLog(@"Connector Table Offset: 0x%016x", gConnectorTableOffset);
        NSLog(@"Connector Table Total Rows: %ld", [gConnectorTable count]);
        NSLog(@"Rows:");
        
        for (NSInteger i = 0; i < [gConnectorTable count]; ++i) {
            if(onlyIGPlatformID){
                //NSLog(@"%02ld. 0x%@", i+1, gConnectorTable[i]);
                init_platform_info();
                NSLog(@"%02ld. 0x%@ - %@", i+1, gConnectorTable[i], [platformIDs objectForKey:gConnectorTable[i]]);
                //NSLog(@"\t\t@\"%@\" : @\"[No Data]\",", gConnectorTable[i]);
            }else{
                NSLog(@"%02ld. %@", i+1, gConnectorTable[i]);
            }
        }

    }
    return 0;
}
