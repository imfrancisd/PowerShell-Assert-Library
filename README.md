# PowerShell Assert Library
A library of PowerShell functions that gives testers complete control over the meaning of their assertions.

Well, at least that's the goal.

# Getting Started

#### Where do I begin?
Explore the "src" folder, find the functions that you need, and include them in your scripts or use them directly in the shell.

The functions are fully documented with specifications and examples.

Use PowerShell's Get-Help cmdlet to see the documentation for each function.

#### What do I need?
You need PowerShell version 2 or above.

The functions were tested on PowerShell versions 2 and 4.

#### What kinds of things can I do with these functions?
There are three kinds of functions in this library:
* Assert Functions
* Collection Functions
* Comparison Functions

The Assert Functions will throw an error if some condition is not met. For example, you can:
* assert that the result of a comparison is true
* assert that a pipeline is empty in order to make sure that a function doesn't return anything
* assert that a pipeline has n objects in order to make sure that a function returns the correct number of objects.

The Collection Functions will allow you to process collections. For example, you can:
* pair up adjacent items in a list in order to assert that a list is sorted
* zip one or more lists together to test them for equality
* create the Cartesian product of multiple lists to generate test cases.

The Comparison Functions will allow you to make comparisons at a high level. For example, you can:
* compare strings as programmatic strings or linguistic texts
* compare the month, day, and year of two dates only if they are both in UTC
* compare two numbers only if their types are Int32, Int64 or Double, but their types don't have to match.

#### Can I use these functions in PowerShell testing frameworks?
Yes.

In fact, the functions were designed so that they can be used in different PowerShell testing frameworks. For example, if you need to rename one of the functions (because the name of the function conflicts with another function in the testing framework) then renaming that function won't break the other functions.

#### Can I use these functions without any frameworks?
Yes.

You can even use these functions directly in the shell.
