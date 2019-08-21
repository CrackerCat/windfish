import Foundation

extension LR35902.Instruction {
  static let tableCB: [Spec] = [
    /* 0x00 */ .cb(.rlc(.b)),
    /* 0x01 */ .cb(.rlc(.c)),
    /* 0x02 */ .cb(.rlc(.d)),
    /* 0x03 */ .cb(.rlc(.e)),
    /* 0x04 */ .cb(.rlc(.h)),
    /* 0x05 */ .cb(.rlc(.l)),
    /* 0x06 */ .cb(.rlc(.hladdr)),
    /* 0x07 */ .cb(.rlc(.a)),
    /* 0x08 */ .cb(.rrc(.b)),
    /* 0x09 */ .cb(.rrc(.c)),
    /* 0x0a */ .cb(.rrc(.d)),
    /* 0x0b */ .cb(.rrc(.e)),
    /* 0x0c */ .cb(.rrc(.h)),
    /* 0x0d */ .cb(.rrc(.l)),
    /* 0x0e */ .cb(.rrc(.hladdr)),
    /* 0x0f */ .cb(.rrc(.a)),

    /* 0x10 */ .cb(.rl(.b)),
    /* 0x11 */ .cb(.rl(.c)),
    /* 0x12 */ .cb(.rl(.d)),
    /* 0x13 */ .cb(.rl(.e)),
    /* 0x14 */ .cb(.rl(.h)),
    /* 0x15 */ .cb(.rl(.l)),
    /* 0x16 */ .cb(.rl(.hladdr)),
    /* 0x17 */ .cb(.rl(.a)),
    /* 0x18 */ .cb(.rr(.b)),
    /* 0x19 */ .cb(.rr(.c)),
    /* 0x1a */ .cb(.rr(.d)),
    /* 0x1b */ .cb(.rr(.e)),
    /* 0x1c */ .cb(.rr(.h)),
    /* 0x1d */ .cb(.rr(.l)),
    /* 0x1e */ .cb(.rr(.hladdr)),
    /* 0x1f */ .cb(.rr(.a)),

    /* 0x20 */ .cb(.sla(.b)),
    /* 0x21 */ .cb(.sla(.c)),
    /* 0x22 */ .cb(.sla(.d)),
    /* 0x23 */ .cb(.sla(.e)),
    /* 0x24 */ .cb(.sla(.h)),
    /* 0x25 */ .cb(.sla(.l)),
    /* 0x26 */ .cb(.sla(.hladdr)),
    /* 0x27 */ .cb(.sla(.a)),
    /* 0x28 */ .cb(.sra(.b)),
    /* 0x29 */ .cb(.sra(.c)),
    /* 0x2a */ .cb(.sra(.d)),
    /* 0x2b */ .cb(.sra(.e)),
    /* 0x2c */ .cb(.sra(.h)),
    /* 0x2d */ .cb(.sra(.l)),
    /* 0x2e */ .cb(.sra(.hladdr)),
    /* 0x2f */ .cb(.sra(.a)),

    /* 0x30 */ .cb(.swap(.b)),
    /* 0x31 */ .cb(.swap(.c)),
    /* 0x32 */ .cb(.swap(.d)),
    /* 0x33 */ .cb(.swap(.e)),
    /* 0x34 */ .cb(.swap(.h)),
    /* 0x35 */ .cb(.swap(.l)),
    /* 0x36 */ .cb(.swap(.hladdr)),
    /* 0x37 */ .cb(.swap(.a)),
    /* 0x38 */ .cb(.srl(.b)),
    /* 0x39 */ .cb(.srl(.c)),
    /* 0x3a */ .cb(.srl(.d)),
    /* 0x3b */ .cb(.srl(.e)),
    /* 0x3c */ .cb(.srl(.h)),
    /* 0x3d */ .cb(.srl(.l)),
    /* 0x3e */ .cb(.srl(.hladdr)),
    /* 0x3f */ .cb(.srl(.a)),

    /* 0x40 */ .cb(.bit(.b0, .b)),
    /* 0x41 */ .cb(.bit(.b0, .c)),
    /* 0x42 */ .cb(.bit(.b0, .d)),
    /* 0x43 */ .cb(.bit(.b0, .e)),
    /* 0x44 */ .cb(.bit(.b0, .h)),
    /* 0x45 */ .cb(.bit(.b0, .l)),
    /* 0x46 */ .cb(.bit(.b0, .hladdr)),
    /* 0x47 */ .cb(.bit(.b0, .a)),
    /* 0x48 */ .cb(.bit(.b1, .b)),
    /* 0x49 */ .cb(.bit(.b1, .c)),
    /* 0x4a */ .cb(.bit(.b1, .d)),
    /* 0x4b */ .cb(.bit(.b1, .e)),
    /* 0x4c */ .cb(.bit(.b1, .h)),
    /* 0x4d */ .cb(.bit(.b1, .l)),
    /* 0x4e */ .cb(.bit(.b1, .hladdr)),
    /* 0x4f */ .cb(.bit(.b1, .a)),

    /* 0x50 */ .cb(.bit(.b2, .b)),
    /* 0x51 */ .cb(.bit(.b2, .c)),
    /* 0x52 */ .cb(.bit(.b2, .d)),
    /* 0x53 */ .cb(.bit(.b2, .e)),
    /* 0x54 */ .cb(.bit(.b2, .h)),
    /* 0x55 */ .cb(.bit(.b2, .l)),
    /* 0x56 */ .cb(.bit(.b2, .hladdr)),
    /* 0x57 */ .cb(.bit(.b2, .a)),
    /* 0x58 */ .cb(.bit(.b3, .b)),
    /* 0x59 */ .cb(.bit(.b3, .c)),
    /* 0x5a */ .cb(.bit(.b3, .d)),
    /* 0x5b */ .cb(.bit(.b3, .e)),
    /* 0x5c */ .cb(.bit(.b3, .h)),
    /* 0x5d */ .cb(.bit(.b3, .l)),
    /* 0x5e */ .cb(.bit(.b3, .hladdr)),
    /* 0x5f */ .cb(.bit(.b3, .a)),

    /* 0x60 */ .cb(.bit(.b4, .b)),
    /* 0x61 */ .cb(.bit(.b4, .c)),
    /* 0x62 */ .cb(.bit(.b4, .d)),
    /* 0x63 */ .cb(.bit(.b4, .e)),
    /* 0x64 */ .cb(.bit(.b4, .h)),
    /* 0x65 */ .cb(.bit(.b4, .l)),
    /* 0x66 */ .cb(.bit(.b4, .hladdr)),
    /* 0x67 */ .cb(.bit(.b4, .a)),
    /* 0x68 */ .cb(.bit(.b5, .b)),
    /* 0x69 */ .cb(.bit(.b5, .c)),
    /* 0x6a */ .cb(.bit(.b5, .d)),
    /* 0x6b */ .cb(.bit(.b5, .e)),
    /* 0x6c */ .cb(.bit(.b5, .h)),
    /* 0x6d */ .cb(.bit(.b5, .l)),
    /* 0x6e */ .cb(.bit(.b5, .hladdr)),
    /* 0x6f */ .cb(.bit(.b5, .a)),

    /* 0x70 */ .cb(.bit(.b6, .b)),
    /* 0x71 */ .cb(.bit(.b6, .c)),
    /* 0x72 */ .cb(.bit(.b6, .d)),
    /* 0x73 */ .cb(.bit(.b6, .e)),
    /* 0x74 */ .cb(.bit(.b6, .h)),
    /* 0x75 */ .cb(.bit(.b6, .l)),
    /* 0x76 */ .cb(.bit(.b6, .hladdr)),
    /* 0x77 */ .cb(.bit(.b6, .a)),
    /* 0x78 */ .cb(.bit(.b7, .b)),
    /* 0x79 */ .cb(.bit(.b7, .c)),
    /* 0x7a */ .cb(.bit(.b7, .d)),
    /* 0x7b */ .cb(.bit(.b7, .e)),
    /* 0x7c */ .cb(.bit(.b7, .h)),
    /* 0x7d */ .cb(.bit(.b7, .l)),
    /* 0x7e */ .cb(.bit(.b7, .hladdr)),
    /* 0x7f */ .cb(.bit(.b7, .a)),

    /* 0x80 */ .cb(.res(.b0, .b)),
    /* 0x81 */ .cb(.res(.b0, .c)),
    /* 0x82 */ .cb(.res(.b0, .d)),
    /* 0x83 */ .cb(.res(.b0, .e)),
    /* 0x84 */ .cb(.res(.b0, .h)),
    /* 0x85 */ .cb(.res(.b0, .l)),
    /* 0x86 */ .cb(.res(.b0, .hladdr)),
    /* 0x87 */ .cb(.res(.b0, .a)),
    /* 0x88 */ .cb(.res(.b1, .b)),
    /* 0x89 */ .cb(.res(.b1, .c)),
    /* 0x8a */ .cb(.res(.b1, .d)),
    /* 0x8b */ .cb(.res(.b1, .e)),
    /* 0x8c */ .cb(.res(.b1, .h)),
    /* 0x8d */ .cb(.res(.b1, .l)),
    /* 0x8e */ .cb(.res(.b1, .hladdr)),
    /* 0x8f */ .cb(.res(.b1, .a)),

    /* 0x90 */ .cb(.res(.b2, .b)),
    /* 0x91 */ .cb(.res(.b2, .c)),
    /* 0x92 */ .cb(.res(.b2, .d)),
    /* 0x93 */ .cb(.res(.b2, .e)),
    /* 0x94 */ .cb(.res(.b2, .h)),
    /* 0x95 */ .cb(.res(.b2, .l)),
    /* 0x96 */ .cb(.res(.b2, .hladdr)),
    /* 0x97 */ .cb(.res(.b2, .a)),
    /* 0x98 */ .cb(.res(.b3, .b)),
    /* 0x99 */ .cb(.res(.b3, .c)),
    /* 0x9a */ .cb(.res(.b3, .d)),
    /* 0x9b */ .cb(.res(.b3, .e)),
    /* 0x9c */ .cb(.res(.b3, .h)),
    /* 0x9d */ .cb(.res(.b3, .l)),
    /* 0x9e */ .cb(.res(.b3, .hladdr)),
    /* 0x9f */ .cb(.res(.b3, .a)),

    /* 0xa0 */ .cb(.res(.b4, .b)),
    /* 0xa1 */ .cb(.res(.b4, .c)),
    /* 0xa2 */ .cb(.res(.b4, .d)),
    /* 0xa3 */ .cb(.res(.b4, .e)),
    /* 0xa4 */ .cb(.res(.b4, .h)),
    /* 0xa5 */ .cb(.res(.b4, .l)),
    /* 0xa6 */ .cb(.res(.b4, .hladdr)),
    /* 0xa7 */ .cb(.res(.b4, .a)),
    /* 0xa8 */ .cb(.res(.b5, .b)),
    /* 0xa9 */ .cb(.res(.b5, .c)),
    /* 0xaa */ .cb(.res(.b5, .d)),
    /* 0xab */ .cb(.res(.b5, .e)),
    /* 0xac */ .cb(.res(.b5, .h)),
    /* 0xad */ .cb(.res(.b5, .l)),
    /* 0xae */ .cb(.res(.b5, .hladdr)),
    /* 0xaf */ .cb(.res(.b5, .a)),

    /* 0xb0 */ .cb(.res(.b6, .b)),
    /* 0xb1 */ .cb(.res(.b6, .c)),
    /* 0xb2 */ .cb(.res(.b6, .d)),
    /* 0xb3 */ .cb(.res(.b6, .e)),
    /* 0xb4 */ .cb(.res(.b6, .h)),
    /* 0xb5 */ .cb(.res(.b6, .l)),
    /* 0xb6 */ .cb(.res(.b6, .hladdr)),
    /* 0xb7 */ .cb(.res(.b6, .a)),
    /* 0xb8 */ .cb(.res(.b7, .b)),
    /* 0xb9 */ .cb(.res(.b7, .c)),
    /* 0xba */ .cb(.res(.b7, .d)),
    /* 0xbb */ .cb(.res(.b7, .e)),
    /* 0xbc */ .cb(.res(.b7, .h)),
    /* 0xbd */ .cb(.res(.b7, .l)),
    /* 0xbe */ .cb(.res(.b7, .hladdr)),
    /* 0xbf */ .cb(.res(.b7, .a)),

    /* 0xc0 */ .cb(.set(.b0, .b)),
    /* 0xc1 */ .cb(.set(.b0, .c)),
    /* 0xc2 */ .cb(.set(.b0, .d)),
    /* 0xc3 */ .cb(.set(.b0, .e)),
    /* 0xc4 */ .cb(.set(.b0, .h)),
    /* 0xc5 */ .cb(.set(.b0, .l)),
    /* 0xc6 */ .cb(.set(.b0, .hladdr)),
    /* 0xc7 */ .cb(.set(.b0, .a)),
    /* 0xc8 */ .cb(.set(.b1, .b)),
    /* 0xc9 */ .cb(.set(.b1, .c)),
    /* 0xca */ .cb(.set(.b1, .d)),
    /* 0xcb */ .cb(.set(.b1, .e)),
    /* 0xcc */ .cb(.set(.b1, .h)),
    /* 0xcd */ .cb(.set(.b1, .l)),
    /* 0xce */ .cb(.set(.b1, .hladdr)),
    /* 0xcf */ .cb(.set(.b1, .a)),

    /* 0xd0 */ .cb(.set(.b2, .b)),
    /* 0xd1 */ .cb(.set(.b2, .c)),
    /* 0xd2 */ .cb(.set(.b2, .d)),
    /* 0xd3 */ .cb(.set(.b2, .e)),
    /* 0xd4 */ .cb(.set(.b2, .h)),
    /* 0xd5 */ .cb(.set(.b2, .l)),
    /* 0xd6 */ .cb(.set(.b2, .hladdr)),
    /* 0xd7 */ .cb(.set(.b2, .a)),
    /* 0xd8 */ .cb(.set(.b3, .b)),
    /* 0xd9 */ .cb(.set(.b3, .c)),
    /* 0xda */ .cb(.set(.b3, .d)),
    /* 0xdb */ .cb(.set(.b3, .e)),
    /* 0xdc */ .cb(.set(.b3, .h)),
    /* 0xdd */ .cb(.set(.b3, .l)),
    /* 0xde */ .cb(.set(.b3, .hladdr)),
    /* 0xdf */ .cb(.set(.b3, .a)),

    /* 0xe0 */ .cb(.set(.b4, .b)),
    /* 0xe1 */ .cb(.set(.b4, .c)),
    /* 0xe2 */ .cb(.set(.b4, .d)),
    /* 0xe3 */ .cb(.set(.b4, .e)),
    /* 0xe4 */ .cb(.set(.b4, .h)),
    /* 0xe5 */ .cb(.set(.b4, .l)),
    /* 0xe6 */ .cb(.set(.b4, .hladdr)),
    /* 0xe7 */ .cb(.set(.b4, .a)),
    /* 0xe8 */ .cb(.set(.b5, .b)),
    /* 0xe9 */ .cb(.set(.b5, .c)),
    /* 0xea */ .cb(.set(.b5, .d)),
    /* 0xeb */ .cb(.set(.b5, .e)),
    /* 0xec */ .cb(.set(.b5, .h)),
    /* 0xed */ .cb(.set(.b5, .l)),
    /* 0xee */ .cb(.set(.b5, .hladdr)),
    /* 0xef */ .cb(.set(.b5, .a)),

    /* 0xf0 */ .cb(.set(.b6, .b)),
    /* 0xf1 */ .cb(.set(.b6, .c)),
    /* 0xf2 */ .cb(.set(.b6, .d)),
    /* 0xf3 */ .cb(.set(.b6, .e)),
    /* 0xf4 */ .cb(.set(.b6, .h)),
    /* 0xf5 */ .cb(.set(.b6, .l)),
    /* 0xf6 */ .cb(.set(.b6, .hladdr)),
    /* 0xf7 */ .cb(.set(.b6, .a)),
    /* 0xf8 */ .cb(.set(.b7, .b)),
    /* 0xf9 */ .cb(.set(.b7, .c)),
    /* 0xfa */ .cb(.set(.b7, .d)),
    /* 0xfb */ .cb(.set(.b7, .e)),
    /* 0xfc */ .cb(.set(.b7, .h)),
    /* 0xfd */ .cb(.set(.b7, .l)),
    /* 0xfe */ .cb(.set(.b7, .hladdr)),
    /* 0xff */ .cb(.set(.b7, .a))
  ]

}
