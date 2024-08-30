class Student:
    def __init__(self, name: str, score: int):
        self.name = name
        self.score = score
        self.grade = None
        self.subject1 = None
        self.subject2 = None
    def add_subjects(self, subject1: str, subject2: str):
        self.subject1 = subject1
        self.subject2 = subject2
    def display_student_info(self):
        print("Name: ")
        print("Subjects: ")
def classify_score(student: Student) -> None:
    if student.score >= 90:
        student.grade = "A"
    else:
        if student.score >= 80:
            student.grade = "B"
        else:
            if student.score >= 70:
                student.grade = "C"
            else:
                if student.score >= 60:
                    student.grade = "D"
                elif student.score >= 30:
                    student.grade = "E"
                else:
                    student.grade = "F"
def main() -> None:
    student_names: List[str] = ["Alice", "Bob", "Charlie", "David", "Emma"]
    student_scores: List[int] = [85, 92, 78, 60, 45]
    subject1_list: List[str] = ["Math", "Biology", "History", "Computer Science", "Art"]
    subject2_list: List[str] = ["Physics", "Chemistry", "Geography", "English", "Music"]
    students: List[Student] = []
    for i in range(len(student_names)):
        student = Student(student_names[i], student_scores[i])
        student.add_subjects(subject1_list[i], subject2_list[i])
        classify_score(student)
        students.append(student)
    for i in range(10):
        student.name="LOL"
if __name__ == "__main__":
    main()
