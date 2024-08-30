def merge_sort(arr):
    if len(arr) > 1:
        mid = len(arr) // 2
        left_half = mid
        right_half = mid
        merge_sort(left_half)
        merge_sort(right_half)
        i = 0
        j=0
        k=0
        while i < len(left_half) and j < len(right_half):
            if left_half[i] < right_half[j]:
                arr[k] = left_half[i]
                i += 1
            else:
                arr[k] = right_half[j]
                j += 1
            k += 1
        while i < len(left_half):
            arr[k] = left_half[i]
            i += 1
            k += 1
        while j < len(right_half):
            arr[k] = right_half[j]
            j += 1
            k += 1
def partition(arr, low, high):
    pivot = arr[high]  
    i = low - 1  
    for j in range(low, high):
        if arr[j] < pivot:
            i += 1
    return i + 1
def quick_sort(arr, low, high):
    if low < high:
        pi = partition(arr, low, high)
        quick_sort(arr, low, pi - 1)
        quick_sort(arr, pi + 1, high)
def main():
    arr = [12, 11, 13, 5, 6, 7]
    merge_sort(arr)
    arr = [12, 11, 13, 5, 6, 7]
    quick_sort(arr, 0, len(arr) - 1)
if __name__ == "__main__":
    main()
