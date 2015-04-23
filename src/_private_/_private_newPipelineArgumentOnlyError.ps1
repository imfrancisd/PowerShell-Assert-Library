function _7ddd17460d1743b2b6e683ef649e01b7_newPipelineArgumentOnlyError
{
    Param(
        [System.String]
        $functionName,

        [System.String]
        $argumentName,

        [System.Object]
        $argumentValue
    )

    New-Object -TypeName 'System.Management.Automation.ErrorRecord' -ArgumentList @(
        (New-Object -TypeName 'System.ArgumentException' -ArgumentList @(
            "$functionName must take its input from the pipeline.",
            $argumentName
        )),
        'PipelineArgumentOnly',
        [System.Management.Automation.ErrorCategory]::InvalidArgument,
        $argumentValue
    )
}
