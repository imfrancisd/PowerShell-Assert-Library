function _7ddd17460d1743b2b6e683ef649e01b7_newAssertionStatus
{
    Param(
        [System.Management.Automation.InvocationInfo]
        $invocation,

        [System.Management.Automation.SwitchParameter]
        $fail
    )

    'Assertion {0}: {1}, file {2}, line {3}' -f @(
        $(if ($fail) {'failed'} else {'passed'}),
        $invocation.Line.Trim(),
        $invocation.ScriptName,
        $invocation.ScriptLineNumber
    )
}
