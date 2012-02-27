Project Description

This project is designed to make a solvable Sudoku puzzle written in assembler.  The program will follow an algorithm designed to ensure that every row, column, and square contains exactly one of each number 1-9.  (It would come up with a random satisfactory combination, then remove numbers in order to create a puzzle).  Ideally the project would also have a difficulty selector that would determine how many numbers to remove, with higher difficulties removing more numbers.  If time permits, perhaps we could also follow up with an algorithm wherein an existing puzzle can be plugged in to the program and a solution provided.

Division of Tasks

Solver: Writes the solving algorithm.

Generator (2 people): One person writes an algorithm to create a random solved board. The other writes one that starts with a solved board, then goes through squares in shuffled order and removes them, ensuring that:
	1. The puzzle is solvable.
	2. There is a unique solution.

Interface Design: Makes the interface look pretty and easy to use.