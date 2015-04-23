function _7ddd17460d1743b2b6e683ef649e01b7_newAssertionFailedError
{
    Param(
        [System.String]
        $message,

        [System.Exception]
        $innerException,

        [System.Object]
        $value
    )

    New-Object -TypeName 'System.Management.Automation.ErrorRecord' -ArgumentList @(
        (New-Object -TypeName 'System.Exception' -ArgumentList @($message, $innerException)),
        'AssertionFailed',
        [System.Management.Automation.ErrorCategory]::OperationStopped,
        $value
    )
}
