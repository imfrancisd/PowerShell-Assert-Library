write-host $('=' * ($HOST.ui.rawui.buffersize.width - 1))
write-host $MyInvocation.MyCommand
write-host $('=' * ($HOST.ui.rawui.buffersize.width - 1))
write-host ''
write-host ''

& {
    $VerbosePreference = 'SilentlyContinue'
    $DebugPreference = 'SilentlyContinue'

    write-host '-------------------------------------------------------------------------'
    write-host 'There should be a line: 1'
    write-host 'There should be a line: 2'
    write-host '    @(1, 2) | assert-pipelinenotexists {param($n) $n -gt 5} <# line 16 #>'
    write-host '-------------------------------------------------------------------------'
    @(1, 2) | assert-pipelinenotexists {param($n) $n -gt 5}
    write-host ''
    write-host ''
}

& {
    $VerbosePreference = 'SilentlyContinue'
    $DebugPreference = 'SilentlyContinue'

    write-host '----------------------------------------------------------------------------------'
    write-host 'There should be a line: 1'
    write-host 'There should be a line: 2'
    write-host 'There should be a PASSING VERBOSE message'
    write-host '    @(1, 2) | assert-pipelinenotexists {param($n) $n -gt 5} -verbose <# line 31 #>'
    write-host '----------------------------------------------------------------------------------'
    @(1, 2) | assert-pipelinenotexists {param($n) $n -gt 5} -verbose
    write-host ''
    write-host ''
}

& {
    $VerbosePreference = 'SilentlyContinue'
    $DebugPreference = 'SilentlyContinue'

    write-host '--------------------------------------------------------------------------------'
    write-host 'There should be a line: 1'
    write-host 'There should be a line: 2'
    write-host '    @(1, 2) | assert-pipelinenotexists {param($n) $n -gt 5} -debug <# line 45 #>'
    write-host '--------------------------------------------------------------------------------'
    @(1, 2) | assert-pipelinenotexists {param($n) $n -gt 5} -debug
    write-host ''
    write-host ''
}

& {
    $VerbosePreference = 'SilentlyContinue'
    $DebugPreference = 'SilentlyContinue'

    write-host '-----------------------------------------------------------------------------------------'
    write-host 'There should be a line: 1'
    write-host 'There should be a line: 2'
    write-host 'There should be a PASSING VERBOSE message'
    write-host '    @(1, 2) | assert-pipelinenotexists {param($n) $n -gt 5} -verbose -debug <# line 60 #>'
    write-host '-----------------------------------------------------------------------------------------'
    @(1, 2) | assert-pipelinenotexists {param($n) $n -gt 5} -verbose -debug
    write-host ''
    write-host ''
}

& {
    $VerbosePreference = 'SilentlyContinue'
    $DebugPreference = 'SilentlyContinue'

    write-host '-------------------------------------------------------------------------'
    write-host 'There should be a line: 1'
    write-host 'There should be a line: 2'
    write-host '    @(1, 2) | assert-pipelinenotexists {param($n) $n -gt 5} <# line 74 #>'
    write-host '-------------------------------------------------------------------------'
    @(1, 2) | assert-pipelinenotexists {param($n) $n -gt 5}
    write-host ''
    write-host ''
}

& {
    $VerbosePreference = 'Continue'
    $DebugPreference = 'SilentlyContinue'

    write-host '-------------------------------------------------------------------------'
    write-host 'There should be a line: 1'
    write-host 'There should be a line: 2'
    write-host 'There should be a PASSING VERBOSE message'
    write-host '    @(1, 2) | assert-pipelinenotexists {param($n) $n -gt 5} <# line 89 #>'
    write-host '-------------------------------------------------------------------------'
    @(1, 2) | assert-pipelinenotexists {param($n) $n -gt 5}
    write-host ''
    write-host ''
}

& {
    $VerbosePreference = 'SilentlyContinue'
    $DebugPreference = 'Continue'

    write-host '--------------------------------------------------------------------------'
    write-host 'There should be a line: 1'
    write-host 'There should be a line: 2'
    write-host '    @(1, 2) | assert-pipelinenotexists {param($n) $n -gt 5} <# line 103 #>'
    write-host '--------------------------------------------------------------------------'
    @(1, 2) | assert-pipelinenotexists {param($n) $n -gt 5}
    write-host ''
    write-host ''
}

& {
    $VerbosePreference = 'Continue'
    $DebugPreference = 'Continue'

    write-host '--------------------------------------------------------------------------'
    write-host 'There should be a line: 1'
    write-host 'There should be a line: 2'
    write-host 'There should be a PASSING VERBOSE message'
    write-host '    @(1, 2) | assert-pipelinenotexists {param($n) $n -gt 5} <# line 118 #>'
    write-host '--------------------------------------------------------------------------'
    @(1, 2) | assert-pipelinenotexists {param($n) $n -gt 5}
    write-host ''
    write-host ''
}

& {
    $VerbosePreference = 'SilentlyContinue'
    $DebugPreference = 'SilentlyContinue'

    write-host '----------------------------------------------------------------------------------'
    write-host 'There should be an ERROR message'
    write-host '    try   {@(1, 2) | assert-pipelinenotexists {param($n) $n -gt 0}} <# line 131 #>'
    write-host '----------------------------------------------------------------------------------'
    try   {@(1, 2) | assert-pipelinenotexists {param($n) $n -gt 0}}
    catch {$_ | out-host}
    write-host ''
    write-host ''
}

& {
    $VerbosePreference = 'Continue'
    $DebugPreference = 'SilentlyContinue'

    write-host '----------------------------------------------------------------------------------'
    write-host 'There should be a VERBOSE and an ERROR message (order matters)'
    write-host '    try   {@(1, 2) | assert-pipelinenotexists {param($n) $n -gt 0}} <# line 145 #>'
    write-host '----------------------------------------------------------------------------------'
    try   {@(1, 2) | assert-pipelinenotexists {param($n) $n -gt 0}}
    catch {$_ | out-host}
    write-host ''
    write-host ''
}

& {
    $VerbosePreference = 'SilentlyContinue'
    $DebugPreference = 'Continue'

    write-host '----------------------------------------------------------------------------------'
    write-host 'There should be a DEBUG and an ERROR message (order matters)'
    write-host '    try   {@(1, 2) | assert-pipelinenotexists {param($n) $n -gt 0}} <# line 159 #>'
    write-host '----------------------------------------------------------------------------------'
    try   {@(1, 2) | assert-pipelinenotexists {param($n) $n -gt 0}}
    catch {$_ | out-host}
    write-host ''
    write-host ''
}

& {
    $VerbosePreference = 'Continue'
    $DebugPreference = 'Continue'

    write-host '----------------------------------------------------------------------------------'
    write-host 'There should be a VERBOSE, DEBUG and ERROR messages (order matters)'
    write-host '    try   {@(1, 2) | assert-pipelinenotexists {param($n) $n -gt 0}} <# line 173 #>'
    write-host '----------------------------------------------------------------------------------'
    try   {@(1, 2) | assert-pipelinenotexists {param($n) $n -gt 0}}
    catch {$_ | out-host}
    write-host ''
    write-host ''
}

write-host $('=' * ($HOST.ui.rawui.buffersize.width - 1))
write-host ''
