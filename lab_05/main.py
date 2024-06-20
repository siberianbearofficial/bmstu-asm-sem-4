def input_dec():
    from sys import argv
    return int(input('Enter a 16-bit unsigned decimal number: ') if len(argv) < 2 else argv[1])


def output_unsigned_hex(n):
    print('Unsigned hex:', hex(n)[2:])


def output_bin_as_char(n):
    truncated_value = n & 0xFF
    print(f'Bin as char: {(truncated_value - 0x100 if truncated_value >= 0x80 else truncated_value) & 0xFF:08b}')


def output_min_power_of_2(n):
    power, i = 1, 0
    while power <= n:
        power <<= 1
        i += 1
    print('Min power of 2:', i)


num = input_dec()
output_unsigned_hex(num)
output_bin_as_char(num)
output_min_power_of_2(num)
