#!/usr/bin/env python
# raven_gpio_gen_mif.py

cfg_mif_size = 8192
cfg_hex_file = "raven_gpio.hex"
cfg_mif_file = "sample_m8k.mif"

cfg_mif_header = '''WIDTH=32;
DEPTH=8192;

ADDRESS_RADIX=HEX;
DATA_RADIX=HEX;

CONTENT BEGIN

'''
cfg_mif_content_example = '''
00 : 00000093;
04 : 00000193;
08 : 00000213;
0c : 00000293;
10 : 00000313;
14 : 00000393;
18 : 00000413;
1c : 00000493;
'''
cfg_mif_tailer = '''
END;

'''

with open(cfg_hex_file, "r") as inf:
    with open(cfg_mif_file, "w") as outf:
        outf.write(cfg_mif_header)
        bytecnt = 0
        linecnt = 0
        read_done = False
        while bytecnt < cfg_mif_size:
            while True:
                rv = inf.readline()
                rv = rv.strip()
                if len(rv) < 1:
                    read_done = True
                    break
                if not rv.startswith("@"):
                    break
            if len(rv) < 1:
                print("Ok: finished bytes %d at line %d" % (bytecnt, linecnt))
                break
            linecnt += 1
            segs = rv.split(' ')
            slen = len(segs)
            if (slen % 4) != 0:
                if (slen %4) == 1 and segs[-1] == '00': # ok
                    segs = segs[:-1]
                elif (slen % 4) == 3 and segs[-1] == '00': # ok
                    segs.append("00")
                elif (slen % 4) == 2 and segs[-1] == '00': # ok
                    segs.append("00")
                    segs.append("00")
                else:
                    print("Error: slen %d not a multiple of 4 at line %d" % (slen, linecnt))
                    break
            content = ""
            for ix,x in enumerate(segs):
                content = x + content
                if (ix % 4) == 3:
                    outf.write("%02x : %s;\n" % (bytecnt, content))
                    content = ""
                    bytecnt += 4
        outf.write(cfg_mif_tailer)
        outf.close()
    inf.close()

