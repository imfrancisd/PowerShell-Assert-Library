$_7ddd17460d1743b2b6e683ef649e01b7_newPredicateFailedError = {
    param(
        [Parameter(Mandatory = $true)]
        [System.Management.Automation.ErrorRecord]
        $errorRecord,

        [Parameter(Mandatory = $true)]
        [AllowNull()]
        [System.Management.Automation.ScriptBlock]
        $predicate
    )

    Microsoft.PowerShell.Utility\New-Object -TypeName 'System.Management.Automation.ErrorRecord' -ArgumentList @(
        (Microsoft.PowerShell.Utility\New-Object -TypeName 'System.InvalidOperationException' -ArgumentList @('Could not invoke predicate.', $errorRecord.Exception)),
        'PredicateFailed',
        [System.Management.Automation.ErrorCategory]::OperationStopped,
        $predicate
    )
}
