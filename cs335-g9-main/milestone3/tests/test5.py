

def complex_arithmetic(a:int,b:int,c:int,d:int,e:int,f:int,g:int,h:int,i:int,j:int) -> int:
    part1: int = (a + b) * (c - d)
    part2: int = (e * f) // (g + h)  # Use integer division
    part3: int = (i ** j) % h

    # Adding bitwise operations
    bitwise_and: int = part1 & part3
    bitwise_or: int = part2 | part1
    bitwise_xor: int = part3 ^ part2
    bitwise_not: int = ~part3

    step1: int = part1 + part2
    step2: int = step1 * part3
    step3: int = step2 - (a * b * c)
    step4: int = step3 // (d - e + f - g)  # Use integer division
    step5: int = step4 + (h * i * j)

    # Apply bitwise results
    final_result: int = step5

    value1: int = final_result * a
    value2: int = value1 + b
    value3: int = value2 - c
    value4: int = value3 * d
    value5: int = value4 // e  # Use integer division
    value6: int = value5 + f
    value7: int = value6 - g
    value8: int = value7 * h
    value9: int = value8 // i  # Use integer division
    value10: int = value9 + j

    result1: int = value10 - bitwise_and
    result2: int = result1 + bitwise_or
    result3: int = result2 - bitwise_xor
    result4: int = result3 + step1
    result5: int = result4 - step2
    result6: int = result5 + step3
    result7: int = result6 - step4
    result8: int = result7 + step5
    result9: int = result8 - final_result

    # Final application of bitwise NOT
    final_bitwise_not: int = ~result9

    return final_bitwise_not
def main():
    a: int = 10
    b: int = 3
    c: int = 2
    d: int = 4
    e: int = 5
    f: int = 6
    g: int = 7
    h: int = 8
    i: int = 9
    j: int = 11
    output: int = complex_arithmetic(a,b,c,d,e,f,g,h,i,j)
    print(output)
if __name__=="__main__":
    main()