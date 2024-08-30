def get_grade(score: int) -> str:
    if score < 0 or score > 100:
        return "Invalid score. Score must be between 0 and 100."
    elif score >= 95:
        return "A+"
    elif score >= 90:
        return "A"
    elif score >= 85:
        return "A-"
    elif score >= 80:
        return "B+"
    elif score >= 75:
        return "B"
    elif score >= 70:
        return "B-"
    elif score >= 65:
        return "C+"
    elif score >= 60:
        return "C"
    elif score >= 55:
        return "C-"
    elif score >= 50:
        return "D+"
    elif score >= 45:
        return "D"
    elif score >= 40:
        return "D-"
    elif score >= 35:
        return "E+"
    elif score >= 30:
        return "E"
    elif score >= 25:
        return "E-"
    elif score >= 20:
        return "F+"
    elif score >= 15:
        return "F"
    elif score >= 10:
        return "F-"
    else:
        return "F--"

def main():
    k: int = (5 * 3 + 14 / 7 - 11 + 75 + 65 // 6) % 100
    print("Marks of the student:")
    print(k)
    print("Finding the grade of student-1:")
    v: str = get_grade(k)
    print(v)
    print("Finding the grade of student-2:")
    m:str=get_grade(10)
    print(m)
    print("Finding the grade of student-3:")
    m1:str=get_grade(25^30)
    print(m1)

if __name__ == "__main__":
    main()
