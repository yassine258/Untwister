from random import Random
load("./../Untwister/untwister.sage")
r1=Random()
# 32 bit Test
output=[format(r1.getrandbits(32), f"0{32}b") for i in range(624)]
Untwiste=Untwister(32)
for i in output:
    Untwiste.submit(i)
r2=Untwiste.getRandom()
for i in range(100):
    assert r2.getrandbits(32)==r1.getrandbits(32)
print("Done 32 bit")
#################################################################################
r1=Random()
# 1 bit Test
output=[format(r1.getrandbits(1), f"0{1}b")+"?"*31 for i in range(624*32)]
Untwiste=Untwister(1)
for i in output:
    Untwiste.submit(i)
r2=Untwiste.getRandom()
for i in range(100):
    assert r2.getrandbits(32)==r1.getrandbits(32)
print("Done 1 bit")