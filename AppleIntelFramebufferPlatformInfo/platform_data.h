//
//  platform_data.h
//  AppleIntelFramebufferPlatformInfo
//
//  Created by Muntashir Al-Islam on 7/28/17.
//  Copyright © 2017 Muntashir Al-Islam. All rights reserved.
//

#ifndef platform_data_h
#define platform_data_h


//
// This file contains platform related info
//

//
// Framebuffer constants
//
#define AppleIntelKBLGraphicsFramebuffer 6
#define AppleIntelSKLGraphicsFramebuffer 5
#define AppleIntelBDWGraphicsFramebuffer 4
#define AppleIntelFramebufferAzul        3
#define AppleIntelFramebufferCapri       2
#define AppleIntelSNBGraphicsFB          1  // No ig-platform-id, snb-platform-id
#define AppleIntelHDGraphicsFB           0  // Has no platform information list

//
// Stores platform id (aka ig-platform-id)
//
NSDictionary *platformIDs;

void init_platform_info(){
    //
    // Store platform related info
    // credit @Piker-Alpha
    //
    platformIDs = @{
                    // KabyLake : No data has been found yet
                    @"591e0000" : @"[No Data]",
                    @"59160000" : @"[No Data]",
                    @"59230000" : @"[No Data]",
                    @"59260000" : @"[No Data]",
                    @"59270000" : @"[No Data]",
                    @"59270009" : @"[No Data]",
                    @"59120000" : @"[No Data]",
                    @"591b0000" : @"[No Data]",
                    @"591e0001" : @"[No Data]",
                    @"59180002" : @"[No Data]",
                    @"59120003" : @"[No Data]",
                    @"59260007" : @"[No Data]",
                    @"59270004" : @"[No Data]",
                    @"59260002" : @"[No Data]",
                    @"591b0006" : @"[No Data]",
                    // SkyLake
                    @"191e0000" : @"Intel® HD Graphics 515..........(Skylake ULX GT2)",
                    @"19160000" : @"Intel® HD Graphics 520..........(Skylake ULT GT2)",
                    @"19260000" : @"Intel® Iris™ Graphics 550.......(Skylake ULT GT3)",
                    @"19270000" : @"[No Data]",
                    @"191b0000" : @"Intel® HD Graphics 530..........(Skylake Halo GT2)",
                    @"193b0000" : @"Intel® Iris™ Pro Graphics 580...(Skylake Halo GT4)",
                    @"19120000" : @"Intel® HD Graphics 530..........(Skylake Desktop GT2)",
                    @"19020001" : @"Intel® HD Graphics 510..........(Skylake Desktop GT1)",
                    @"19170001" : @"Skylake Desktop.................(Skylake GT1.5)",
                    @"19120001" : @"Intel® HD Graphics 530..........(Skylake Desktop GT2)",
                    @"19320001" : @"Skylake Desktop.................(Skylake GT4)",
                    @"19160002" : @"Intel® HD Graphics 520..........(Skylake ULT GT2)",
                    @"19260002" : @"Intel® Iris™ Graphics 540.......(Skylake ULT GT3)",
                    @"191e0003" : @"Intel® HD Graphics 515..........(Skylake ULX GT2)",
                    @"19260004" : @"Intel® Iris™ Graphics 540.......(Skylake ULT GT3)",
                    @"19270004" : @"[No Data]",
                    @"193b0005" : @"Intel® Iris™ Pro Graphics 580...(Skylake Halo GT4)",
                    @"193b0006" : @"Intel® Iris™ Pro Graphics 580...(Skylake Halo GT4)",
                    @"191b0006" : @"[No Data]",
                    @"19260007" : @"[No Data]",
                    // Broadwell
                    @"16060000" : @"Intel® HD Graphics..............(Broadwell GT1)",
                    @"160e0000" : @"Intel® HD Graphics..............(Broadwell GT1)",
                    @"16160000" : @"Intel® HD Graphics 5500.........(Broadwell GT2)",
                    @"161e0000" : @"Intel® HD Graphics 5300.........(Broadwell GT2)",
                    @"16260000" : @"Intel® HD Graphics 6000.........(Broadwell GT3)",
                    @"162b0000" : @"Intel® Iris™ Graphics 6100......(Broadwell GT3)",
                    @"16220000" : @"Intel® Iris™ Pro Graphics 6200..(Broadwell GT3)",
                    @"160e0001" : @"Intel® HD Graphics..............(Broadwell GT1)",
                    @"161e0001" : @"Intel® HD Graphics 5300.........(Broadwell GT2)",
                    @"16060002" : @"Intel® HD Graphics..............(Broadwell GT1)",
                    @"16160002" : @"Intel® HD Graphics 5500.........(Broadwell GT2)",
                    @"16260002" : @"Intel® HD Graphics 6000.........(Broadwell GT3)",
                    @"16220002" : @"Intel® Iris™ Pro Graphics 6200..(Broadwell GT3)",
                    @"162b0002" : @"Intel® Iris™ Graphics 6100......(Broadwell GT3)",
                    @"16120003" : @"Intel® HD Graphics 5600.........(Broadwell GT2)",
                    @"162b0004" : @"Intel® Iris™ Graphics 6100......(Broadwell GT3)",
                    @"16260004" : @"Intel® HD Graphics 6000.........(Broadwell GT3)",
                    @"16220007" : @"[No Data]",
                    @"16260005" : @"Intel® HD Graphics 6000.........(Broadwell GT3)",
                    @"16260006" : @"Intel® HD Graphics 6000.........(Broadwell GT3)",
                    @"162b0008" : @"[No Data]",
                    @"16260008" : @"[No Data]",
                    // Haswell : Graphics related info is unavailable
                    @"0c060000" : @"(Haswell SDV Mobile GT1)",
                    @"0c160000" : @"(Haswell SDV Mobile GT2)",
                    @"0c260000" : @"(Haswell SDV Mobile GT3)",
                    @"04060000" : @"(Haswell Mobile GT1)",
                    @"04160000" : @"(Haswell Mobile GT2)",
                    @"04260000" : @"(Haswell Mobile GT3)",
                    @"0d260000" : @"(Haswell CRW Mobile GT3)",
                    @"0a160000" : @"(Haswell ULT Mobile GT2)",
                    @"0a260000" : @"(Haswell ULT Mobile GT3)",
                    @"0a260005" : @"(Haswell ULT Mobile GT3)",
                    @"0a260006" : @"(Haswell ULT Mobile GT3)",
                    @"0a2e0008" : @"(Haswell ULT E GT3)",
                    @"0a16000c" : @"(Haswell ULT Mobile GT2)",
                    @"0d260007" : @"(Haswell CRW Mobile GT3)",
                    @"0d220003" : @"(Haswell CRW GT3)",
                    @"0a2e000a" : @"(Haswell ULT E GT3)",
                    @"0a26000a" : @"(Haswell ULT Mobile GT3)",
                    @"0a2e000d" : @"(Haswell ULT E GT3)",
                    @"0a26000d" : @"(Haswell ULT Mobile GT3)",
                    @"04120004" : @"(Haswell GT2)",
                    @"0412000b" : @"(Haswell GT2)",
                    @"0d260009" : @"(Haswell CRW Mobile GT3)",
                    @"0d26000e" : @"[No Data]",
                    @"0d26000f" : @"[No Data]",
                    // IvyBridge : Graphics related info is unavailable
                    @"01660000" : @"(Ivy Bridge Mobile GT2)",
                    @"01620006" : @"(Ivy Bridge GT2)",
                    @"01620007" : @"(Ivy Bridge GT2)",
                    @"01620005" : @"(Ivy Bridge GT2)",
                    @"01660001" : @"(Ivy Bridge Mobile GT2)",
                    @"01660002" : @"(Ivy Bridge Mobile GT2)",
                    @"01660008" : @"(Ivy Bridge Mobile GT2)",
                    @"01660009" : @"(Ivy Bridge Mobile GT2)",
                    @"01660003" : @"(Ivy Bridge Mobile GT2)",
                    @"01660004" : @"(Ivy Bridge Mobile GT2)",
                    @"0166000a" : @"(Ivy Bridge Mobile GT2)",
                    @"0166000b" : @"(Ivy Bridge Mobile GT2)",
                    // SandyBridge: There's no such thing as ig-platform-id, but snb-platform-id
                    // HD Graphics: There's no such thing as platform id
    };
}

/*
 */
#endif /* platform_data_h */
