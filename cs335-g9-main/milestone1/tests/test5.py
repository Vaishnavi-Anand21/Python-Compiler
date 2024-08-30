a: int = 10
b: int = 5
c: int = 7
d: int = 3
result1 = (a + b) * c / d
result2 = ((a * b) + (c * c)) ** 0.5
result3 = (a ** 3) + (b ** 2) - (c * d)
result4 = (a + b) / (c - d)
result5 = ((a - (a // b)) * (b + (b % d))) + (c * (d // b))
def chordCnt(A):
    m: int = 10**9 + 7
    dp = [0] * (2 * A + 2)
    dp[0] = 1
    dp[1] = 0
    for i in range(2, 2 * A + 1, 2):
        for j in range(2, i + 1):
            dp[i] += (dp[i - j] % m) * (dp[j - 2] % m)
            dp[i] %= m
    return dp[2 * A] % m
def longestSubsequenceLength(A):
    n: int = len(A)
    maxi = 0
    count = 0
    f = 0
    front = [0] * (n + 1)
    back = [0] * (n + 1)    
    if n == 0:
        return 0   
    front[0] = 1
    for i in range(1, n):
        front[i] = 1
        for j in range(i):
            if A[i] > A[j]:
                front[i] = max(front[i], front[j] + 1)    
    temp: int = 0
    back[n - 1] = 1
    ans: int = 0    
    for i in range(n):
        ans = max(front[i] + back[i] - 1, ans)    
    return ans
def main():
    A = [1, 11, 2, 10, 4, 5, 2, 1]
    result = longestSubsequenceLength(A)
if __name__ == "__main__":
    main()
