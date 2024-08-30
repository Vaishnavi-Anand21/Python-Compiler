def fibonacci(n:int)->int:
    if n <= 1:
        return n
    else:
        return fibonacci(n-1) + fibonacci(n-2)
def f(a:list[int]):
    a[1]=10000
def main():
  a:list[int]=[0,0,0,0,0,0,0,0,0,0] 
  i:int=0
  print("Fibonacci using Recursion:")
  for i in range(5):
    v:int=fibonacci(i)
    a[i]=v
  while(i<10):
    k:int=fibonacci(i)
    a[i]=k
    i=i+1
  for i in range(10):
    print(a[i])
  b:list[int]=[0,0,0,0,0,0,0,0,0,0]  
  b[0]=0
  b[1]=1
  j:int=0
  z:int=0
  print("Fibonacci using Loop:")
  for z in range(2,10):
    b[z]=b[z-1]+b[z-2]
  for j in range(10):
    print(b[j])
  print("Checking if the 2 lists generated are equal")
  for i in range(10):
    if a[i]!=b[i]:
      print("They are not equal")
      break
      
  print("Changing the value of the list element by passing it into a function:")
  print("Initial value:")
  print(a[1])
  print("After Changing:")
  f(a)
  print(a[1])


if __name__=="__main__":
  main()

    
