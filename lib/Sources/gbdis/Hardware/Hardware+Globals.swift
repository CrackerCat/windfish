import Foundation
import Windfish
import DisassemblyRequest

func populateRequestWithHardwareGlobals(_ request: DisassemblyRequest<LR35902.Address, Gameboy.Cartridge.Location, LR35902.Instruction>) {
  request.addGlobals([
    0x0143: "HW_COLORGAMEBOY HeaderIsColorGB",
    0x0146: "HW_SUPERGAMEBOY HeaderSGBFlag",
    0x0148: "HW_ROMSIZE HeaderROMSize",
    0x0149: "HW_RAMSIZE HeaderRAMSize",
    0x014A: "HW_DESTINATIONCODE HeaderDestinationCode",
    0x8000: "gbVRAM",
    0x8800: "gbBGCHARDAT",
    0x9800: "gbBGDAT0",
    0x9c00: "gbBGDAT1",
    0xa000: "gbCARTRAM",
    0xc000: "gbRAM",
    0xfe00: "gbOAMRAM",
    0xff00: "JOYPAD gbP1",
    0xff01: "gbSB",
    0xff02: "gbSC",
    0xff04: "gbDIV",
    0xff05: "gbTIMA",
    0xff06: "gbTMA",
    0xff07: "gbTAC",
    0xff0f: "gbIF",
    0xff10: "gbAUD1SWEEP",
    0xff11: "gbAUD1LEN",
    0xff12: "gbAUD1ENV",
    0xff13: "gbAUD1LOW",
    0xff14: "gbAUD1HIGH",
    0xff16: "gbAUD2LEN",
    0xff17: "gbAUD2ENV",
    0xff18: "gbAUD2LOW",
    0xff19: "gbAUD2HIGH",
    0xff1a: "gbAUD3ENA",
    0xff1b: "gbAUD3LEN",
    0xff1c: "gbAUD3LEVEL",
    0xff1d: "gbAUD3LOW",
    0xff1e: "gbAUD3HIGH",
    0xff20: "gbAUD4LEN",
    0xff21: "gbAUD4ENV",
    0xff22: "gbAUD4POLY",
    0xff23: "gbAUD4CONSEC",
    0xff24: "gbAUDVOL",
    0xff25: "gbAUDTERM",
    0xff26: "gbAUDENA",
    0xff30: "gbAUD3WAVERAM",
    0xff40: "LCDCF gbLCDC",
    0xff41: "STATF gbSTAT",
    0xff42: "decimal gbSCY",
    0xff43: "decimal gbSCX",
    0xff44: "decimal gbLY",
    0xff45: "decimal gbLYC",
    0xff46: "gbDMA",
    0xff47: "gbBGP",
    0xff48: "gbOBP0",
    0xff49: "gbOBP1",
    0xff4a: "gbWY",
    0xff4b: "gbWX",
    0xff4d: "gbKEY1",
    0xff4f: "gbVBK",
    0xff51: "gbHDMA1",
    0xff52: "gbHDMA2",
    0xff53: "gbHDMA3",
    0xff54: "gbHDMA4",
    0xff55: "gbHDMA5",
    0xff56: "gbRP",
    0xff68: "gbBCPS",
    0xff69: "gbBCPD",
    0xff6a: "gbOCPS",
    0xff6b: "gbOCPD",
    0xff70: "gbSVBK",
    0xff76: "gbPCM12",
    0xff77: "gbPCM34",
    0xffff: "HW_IE gbIE",
  ])
}
