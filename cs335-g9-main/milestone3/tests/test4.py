def bubblesort(arr: list[int])->int: 
    z: int = 0
    for z in range(7):
        swapped: bool = False
        v: int = 0
        while v < 7 - z - 1:
  
            if arr[v+1] < arr[v]:
                temp: int = arr[v]
                arr[v] = arr[v+1]
                arr[v+1] = temp
                swapped = True
            v += 1
        if not swapped:
            break
    return 0

def main():
    arr: list[int] = [64, -34, 25, -12, 22, 11, 90]
    j: int = 0
    t: int = len(arr)
    for j in range(t):
        print(arr[j])
    print("Sorted array is:") 
    o:int=bubblesort(arr)
    k: int = len(arr)
    i: int = 0
    for i in range(k):
        print(arr[i])
    a:int=9
    b:int=8
    print("Bit operations:")
    k1:int=a&b
    print("Bit and between a and b:")
    print(k1)
    print("Bit or between a and b:")
    k2:int=a|b
    print(k2)
    print("Bit xor between a and b:")
    k3:int=a^b
    print(k3)
    print("Bit not of a:")
    k4:int=~a
    print(k4)

if __name__ == "__main__":
    main()
