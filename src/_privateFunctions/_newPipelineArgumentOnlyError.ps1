$_7ddd17460d1743b2b6e683ef649e01b7_newPipelineArgumentOnlyError = {
    param(
        [Parameter(Mandatory = $true)]
        [System.String]
        $functionName,

        [Parameter(Mandatory = $true)]
        [System.String]
        $argumentName,

        [Parameter(Mandatory = $true)]
        [AllowNull()]
        [System.Object]
        $argumentValue
    )

    Microsoft.PowerShell.Utility\New-Object -TypeName 'System.Management.Automation.ErrorRecord' -ArgumentList @(
        (Microsoft.PowerShell.Utility\New-Object -TypeName 'System.ArgumentException' -ArgumentList @(
            "$functionName must take its input from the pipeline.",
            $argumentName
        )),
        'PipelineArgumentOnly',
        [System.Management.Automation.ErrorCategory]::InvalidArgument,
        $argumentValue
    )
}
