import struct

PATH = r"D:/jelle/Vapecord-ACNL-Plugin/Turnip-Bank-ACNL/garden_plus.dat"
d = open(PATH, "rb").read()
def u64(o): return struct.unpack_from("<Q", d, o)[0]

MASK = 0xFFFFFFFF
def decrypt(money):
    enc       = money & MASK
    adjust    = (money >> 32) & 0xFFFF
    shift_val = (money >> 48) & 0xFF
    chk       = (money >> 56) & 0xFF
    calc = ((enc>>0)+(enc>>8)+(enc>>16)+(enc>>24)+0xBA) & 0xFF
    valid = (calc == chk)
    left = (0x1C - shift_val) & 0xFF
    right = 0x20 - left
    if left >= 0x20:
        value = ((enc << right) - (adjust + 0x8F187432)) & MASK
    else:
        rotl = ((enc << left) | (enc >> right)) & MASK
        value = (rotl - (adjust + 0x8F187432)) & MASK
    return value, valid

print("=== sanity: geld/bank velden (player 0) ===")
for name,o in [("PocketMoney",0x6FA8),("BankAmount",0x6C2C),("DebtAmount",0x6C34),
               ("MedalAmount",0x6C3C),("BellsFromReese",0x6C44),("MeowCoupons",0x8DBC)]:
    v,ok = decrypt(u64(o))
    print(f"  {name:14}: {v:>12,}  (valid={ok})")

print("\n=== TurnipPrices gedecodeerd (12 entries @0x6ADE0) ===")
raw = [u64(0x6ADE0+8*i) for i in range(12)]
dec = [decrypt(r) for r in raw]
for i,(v,ok) in enumerate(dec):
    print(f"  raw[{i:2}] -> {v:>6}  (valid={ok})")

DAYS = ["Ma","Di","Wo","Do","Vr","Za"]
print("\n--- interpretatie A: Vapecord-code [0-5]=AM, [6-11]=PM ---")
for day in range(6):
    am,_ = dec[day]; pm,_ = dec[day+6]
    print(f"   {DAYS[day]}: AM={am:>4}  PM={pm:>4}")

print("\n--- interpretatie B: interleaved (AM=even idx, PM=odd idx) ---")
for day in range(6):
    am,_ = dec[2*day]; pm,_ = dec[2*day+1]
    print(f"   {DAYS[day]}: AM={am:>4}  PM={pm:>4}")
