import AppKit
import Foundation
import Cocoa

import Windfish

final class LR35902RegistersView: NSView {
  let pcView = AddressView()
  let spView = AddressView()
  let aView = RegisterView<UInt8>()
  let fView = RegisterView<UInt8>()
  let bView = RegisterView<UInt8>()
  let cView = RegisterView<UInt8>()
  let dView = RegisterView<UInt8>()
  let eView = RegisterView<UInt8>()
  let hView = RegisterView<UInt8>()
  let lView = RegisterView<UInt8>()
  let flagsView = CPUFlagsView()
  override init(frame frameRect: NSRect) {
    super.init(frame: frameRect)

    pcView.name = "pc:"
    pcView.translatesAutoresizingMaskIntoConstraints = false
    addSubview(pcView)

    spView.name = "sp:"
    spView.translatesAutoresizingMaskIntoConstraints = false
    addSubview(spView)

    aView.name = "a:"
    aView.translatesAutoresizingMaskIntoConstraints = false
    addSubview(aView)
    fView.name = "f:"
    fView.translatesAutoresizingMaskIntoConstraints = false
    addSubview(fView)

    bView.name = "b:"
    bView.translatesAutoresizingMaskIntoConstraints = false
    addSubview(bView)
    cView.name = "c:"
    cView.translatesAutoresizingMaskIntoConstraints = false
    addSubview(cView)

    dView.name = "d:"
    dView.translatesAutoresizingMaskIntoConstraints = false
    addSubview(dView)
    eView.name = "e:"
    eView.translatesAutoresizingMaskIntoConstraints = false
    addSubview(eView)

    hView.name = "h:"
    hView.translatesAutoresizingMaskIntoConstraints = false
    addSubview(hView)
    lView.name = "l:"
    lView.translatesAutoresizingMaskIntoConstraints = false
    addSubview(lView)

    flagsView.translatesAutoresizingMaskIntoConstraints = false
    addSubview(flagsView)

    NSLayoutConstraint.activate([
      pcView.leadingAnchor.constraint(equalTo: leadingAnchor),
      pcView.topAnchor.constraint(equalTo: topAnchor),

      spView.topAnchor.constraint(equalTo: pcView.bottomAnchor),
      spView.leadingAnchor.constraint(equalTo: pcView.leadingAnchor),

      aView.leadingAnchor.constraint(equalToSystemSpacingAfter: pcView.trailingAnchor, multiplier: 1),
      fView.leadingAnchor.constraint(equalTo: aView.trailingAnchor, constant: 4),

      flagsView.leadingAnchor.constraint(equalTo: fView.trailingAnchor, constant: 4),
      flagsView.centerYAnchor.constraint(equalTo: fView.centerYAnchor),
      flagsView.trailingAnchor.constraint(equalTo: trailingAnchor),

      aView.topAnchor.constraint(equalTo: topAnchor),
      fView.topAnchor.constraint(equalTo: aView.topAnchor),

      bView.leadingAnchor.constraint(equalTo: aView.leadingAnchor),
      cView.leadingAnchor.constraint(equalTo: bView.trailingAnchor, constant: 4),

      bView.topAnchor.constraint(equalTo: aView.bottomAnchor),
      cView.topAnchor.constraint(equalTo: bView.topAnchor),

      dView.leadingAnchor.constraint(equalTo: aView.leadingAnchor),
      eView.leadingAnchor.constraint(equalTo: dView.trailingAnchor, constant: 4),

      dView.topAnchor.constraint(equalTo: bView.bottomAnchor),
      eView.topAnchor.constraint(equalTo: dView.topAnchor),

      hView.leadingAnchor.constraint(equalTo: aView.leadingAnchor),
      lView.leadingAnchor.constraint(equalTo: hView.trailingAnchor, constant: 4),

      hView.topAnchor.constraint(equalTo: dView.bottomAnchor),
      lView.topAnchor.constraint(equalTo: hView.topAnchor),

      hView.bottomAnchor.constraint(equalTo: bottomAnchor),
    ])
  }

  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  func update(with emulator: Emulator) {
    let gb = emulator.gb.pointee
    pcView.value = gb.pc
    spView.value = gb.sp
    aView.value  = gb.a
    fView.value  = gb.f
    bView.value  = gb.b
    cView.value  = gb.c
    dView.value  = gb.d
    eView.value  = gb.e
    hView.value  = gb.h
    lView.value  = gb.l
    flagsView.update(with: emulator)
  }
}

final class IBLR35902RegistersView: NSView {
  @IBOutlet var pcView: FixedWidthTextView?
  @IBOutlet var spView: FixedWidthTextView?
  @IBOutlet var aView: FixedWidthTextView?
  @IBOutlet var fView: FixedWidthTextView?
  @IBOutlet var bView: FixedWidthTextView?
  @IBOutlet var cView: FixedWidthTextView?
  @IBOutlet var dView: FixedWidthTextView?
  @IBOutlet var eView: FixedWidthTextView?
  @IBOutlet var hView: FixedWidthTextView?
  @IBOutlet var lView: FixedWidthTextView?
  @IBOutlet var flagsView: CPUFlagsView?

  func update(with emulator: Emulator) {
    let gb = emulator.gb.pointee
    pcView?.integerValue = Int(truncatingIfNeeded: gb.pc)
    spView?.integerValue = Int(truncatingIfNeeded: gb.sp)
    aView?.integerValue  = Int(truncatingIfNeeded: gb.a)
    fView?.integerValue  = Int(truncatingIfNeeded: gb.f)
    bView?.integerValue  = Int(truncatingIfNeeded: gb.b)
    cView?.integerValue  = Int(truncatingIfNeeded: gb.c)
    dView?.integerValue  = Int(truncatingIfNeeded: gb.d)
    eView?.integerValue  = Int(truncatingIfNeeded: gb.e)
    hView?.integerValue  = Int(truncatingIfNeeded: gb.h)
    lView?.integerValue  = Int(truncatingIfNeeded: gb.l)
    flagsView?.update(with: emulator)
  }
}
