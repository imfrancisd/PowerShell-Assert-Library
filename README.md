# PowerShell Assert Library
A library of PowerShell functions that gives testers complete control over the meaning of their assertions.

Well, at least that's the goal.

# Getting Started

#### Where do I begin?
You can dot source the script
```
    . .\Release\Script\AssertLibrary.ps1
```
or you can import the module
```
    Import-Module .\Release\Module\AssertLibrary
```

The functions are fully documented with specifications and examples.

Use PowerShell's Get-Help cmdlet to see the documentation for each function.

The functions were tested on PowerShell versions 2 and 4.

#### What do I need?
You need PowerShell version 2 or higher.

Include 1 of the following in your scripts or module if you want to use these functions in your automated tests:
* "Release\Script\AssertLibrary.ps1" script file
* "Release\Module\AssertLibrary\" module directory.

##### Note:
The "Release\Script\" directory has multiple script files.

The only difference between these script files is the language used to write the documentation. For example, "AssertLibrary_en-US.ps1" contains documentation written for people who speak English in the US.

You only need 1 of these files.

#### What kinds of things can I do with these functions?
There are three kinds of functions in this library:
* Assert Functions
* Collection Functions
* Comparison Functions.

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

#### What are the names of the functions?
If you are using the module, you can get a list of all the functions using this command:
````
    get-help about_assertlibrary
````
or by using this command:
````
    (get-module assertlibrary).exportedfunctions.keys
````

If you are not using the module, here are the names of the functions:
* Assert-True
* Assert-False
* Assert-Null
* Assert-NotTrue
* Assert-NotFalse
* Assert-NotNull
* Assert-All
* Assert-Exists
* Assert-NotExists
* Assert-PipelineAny
* Assert-PipelineCount
* Assert-PipelineEmpty
* Assert-PipelineSingle
* Group-ListItem
* Test-DateTime
* Test-Guid
* Test-Number
* Test-String
* Test-Text
* Test-TimeSpan
* Test-Version

#### How do I use the functions?
You can view the help file for each function using PowerShell's Get-Help cmdlet.
````
    # this will display the help file for Group-ListItem
    Get-Help Group-ListItem -Full
````
The help file contains detailed information about the function as well as examples of how to use the function.

