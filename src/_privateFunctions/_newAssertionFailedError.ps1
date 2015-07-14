$_7ddd17460d1743b2b6e683ef649e01b7_newAssertionFailedError = {
    param(
        [Parameter(Mandatory = $true)]
        [System.String]
        $message,

        [Parameter(Mandatory = $true)]
        [AllowNull()]
        [System.Exception]
        $innerException,

        [Parameter(Mandatory = $true)]
        [AllowNull()]
        [System.Object]
        $value
    )

    Microsoft.PowerShell.Utility\New-Object -TypeName 'System.Management.Automation.ErrorRecord' -ArgumentList @(
        (Microsoft.PowerShell.Utility\New-Object -TypeName 'System.Exception' -ArgumentList @($message, $innerException)),
        'AssertionFailed',
        [System.Management.Automation.ErrorCategory]::OperationStopped,
        $value
    )
}
