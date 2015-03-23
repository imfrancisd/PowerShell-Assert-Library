# PowerShell Assert Library
A library of PowerShell functions that gives testers complete control over the meaning of their assertions.

Well, at least that's the goal.

# Getting Started
Explore the "src" folder, find the functions that you need, and include them in your scripts or use them directly in the shell.

You can create many kinds of assertions just by combining the functions in different ways.

#### Assert Functions
These functions will throw an error if some condition is not met. For example, you can:
* assert that the result of a comparison is true
* assert that a pipeline is empty in order to make sure that a function doesn't return anything
* assert that a pipeline has n objects in order to make sure that a function returns the correct number of objects.

#### Collection Functions
These functions will allow you to process collections. For example, you can:
* pair up adjacent items in a list in order to assert that a list is sorted
* zip one or more lists together to test them for equality
* create the Cartesian product of multiple lists to generate test cases.

#### Comparison Functions.
These functions will allow you to make comparisons at a high level. For example, you can:
* compare strings as programmatic strings or linguistic texts
* compare the month, day, and year of two dates only if they are both in UTC
* compare two numbers only if their types are Int32, Int64 or Double, but their types don't have to match.


