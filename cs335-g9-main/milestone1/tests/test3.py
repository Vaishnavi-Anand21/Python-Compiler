def main() -> None:
    print("Nested for loop:")
    for i in range(1, 4):
        print( i)
        for j in range(1, 4):
            print("Inner loop iteration:", j)
            if j == 2:
                break  
            elif j == 3:
                print("Reached the end of inner loop")
        else:
            print("Inner loop completed without break")
    print("\nNested while loop:")
    i: int = 1
    while i < 4:
        print(i)
        j: int = 1
        while j < 4:
            print(j)
            if j == 2:
                j += 1
                continue  
            elif j == 3:
                print("Reached the end of inner loop")
            j += 1
        else:
            print("Inner loop completed without break")
        i += 1
    print("\nAdditional functionality:")
    numbers: List[int] = [1, 2, 3, 4, 5]
    for num in numbers:
        if num == 3:
            print("Found 3, skipping...")
            continue
        print(num)
        if num == 5:
            print("Breaking at 5")
            break
    else:
        print("Loop completed without break")
if __name__ == "__main__":
    main()
