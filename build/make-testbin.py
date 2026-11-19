#!/usr/bin/env python3
"""Generate a small valid MODE1/2352 test image + cue sheet."""
import sys

SECTORS = 150  # 2 seconds' worth

def bcd(v):
    return ((v // 10) << 4) | (v % 10)

with open(sys.argv[1] if len(sys.argv) > 1 else "test.bin", "wb") as f:
    for lba in range(SECTORS):
        sector = bytearray()
        sector += b"\x00" + b"\xff" * 10 + b"\x00"      # sync pattern
        m, s, fr = lba // (75 * 60), (lba // 75) % 60, lba % 75
        sector += bytes([bcd(m), bcd(s), bcd(fr), 0x01])  # MSF + Mode 1
        sector += (bytes(range(256)) * 10)[:2336]         # payload filler
        assert len(sector) == 2352
        f.write(sector)

cue = """FILE "test.bin" BINARY
  TRACK 01 MODE1/2352
    INDEX 01 00:00:00
"""
with open("test.cue", "w") as f:
    f.write(cue)
print("test.bin + test.cue written")
