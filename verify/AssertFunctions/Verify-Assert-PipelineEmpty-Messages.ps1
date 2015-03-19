write-host $('=' * ($HOST.ui.rawui.buffersize.width - 1))
write-host $MyInvocation.MyCommand
write-host $('=' * ($HOST.ui.rawui.buffersize.width - 1))
write-host ''
write-host ''

& {
    $VerbosePreference = 'SilentlyContinue'
    $DebugPreference = 'SilentlyContinue'

    write-host '--------------------------------------------'
    write-host 'There should be no messages'
    write-host '    @() | assert-pipelineempty <# line 15 #>'
    write-host '--------------------------------------------'
    @() | assert-pipelineempty
    write-host ''
    write-host ''
}

& {
    $VerbosePreference = 'SilentlyContinue'
    $DebugPreference = 'SilentlyContinue'

    write-host '-----------------------------------------------------'
    write-host 'There should be a PASSING VERBOSE message'
    write-host '    @() | assert-pipelineempty -verbose <# line 28 #>'
    write-host '-----------------------------------------------------'
    @() | assert-pipelineempty -verbose
    write-host ''
    write-host ''
}

& {
    $VerbosePreference = 'SilentlyContinue'
    $DebugPreference = 'SilentlyContinue'

    write-host '---------------------------------------------------'
    write-host 'There should be no messages'
    write-host '    @() | assert-pipelineempty -debug <# line 41 #>'
    write-host '---------------------------------------------------'
    @() | assert-pipelineempty -debug
    write-host ''
    write-host ''
}

& {
    $VerbosePreference = 'SilentlyContinue'
    $DebugPreference = 'SilentlyContinue'

    write-host '------------------------------------------------------------'
    write-host 'There should be a PASSING VERBOSE message'
    write-host '    @() | assert-pipelineempty -verbose -debug <# line 54 #>'
    write-host '------------------------------------------------------------'
    @() | assert-pipelineempty -verbose -debug
    write-host ''
    write-host ''
}

& {
    $VerbosePreference = 'SilentlyContinue'
    $DebugPreference = 'SilentlyContinue'

    write-host '--------------------------------------------'
    write-host 'There should be no messages'
    write-host '    @() | assert-pipelineempty <# line 67 #>'
    write-host '--------------------------------------------'
    @() | assert-pipelineempty
    write-host ''
    write-host ''
}

& {
    $VerbosePreference = 'Continue'
    $DebugPreference = 'SilentlyContinue'

    write-host '--------------------------------------------'
    write-host 'There should be a PASSING VERBOSE message'
    write-host '    @() | assert-pipelineempty <# line 80 #>'
    write-host '--------------------------------------------'
    @() | assert-pipelineempty
    write-host ''
    write-host ''
}

& {
    $VerbosePreference = 'SilentlyContinue'
    $DebugPreference = 'Continue'

    write-host '--------------------------------------------'
    write-host 'There should be no messages'
    write-host '    @() | assert-pipelineempty <# line 93 #>'
    write-host '--------------------------------------------'
    @() | assert-pipelineempty
    write-host ''
    write-host ''
}

& {
    $VerbosePreference = 'Continue'
    $DebugPreference = 'Continue'

    write-host '---------------------------------------------'
    write-host 'There should be a PASSING VERBOSE message'
    write-host '    @() | assert-pipelineempty <# line 106 #>'
    write-host '---------------------------------------------'
    @() | assert-pipelineempty
    write-host ''
    write-host ''
}

& {
    $VerbosePreference = 'SilentlyContinue'
    $DebugPreference = 'SilentlyContinue'

    write-host '---------------------------------------------------------'
    write-host 'There should be an ERROR message'
    write-host '    try   {@(1, 2) | assert-pipelineempty} <# line 119 #>'
    write-host '---------------------------------------------------------'
    try   {@(1, 2) | assert-pipelineempty}
    catch {$_ | out-host}
    write-host ''
    write-host ''
}

& {
    $VerbosePreference = 'Continue'
    $DebugPreference = 'SilentlyContinue'

    write-host '--------------------------------------------------------------'
    write-host 'There should be a VERBOSE and an ERROR message (order matters)'
    write-host '    try   {@(1, 2) | assert-pipelineempty} <# line 133 #>'
    write-host '--------------------------------------------------------------'
    try   {@(1, 2) | assert-pipelineempty}
    catch {$_ | out-host}
    write-host ''
    write-host ''
}

& {
    $VerbosePreference = 'SilentlyContinue'
    $DebugPreference = 'Continue'

    write-host '------------------------------------------------------------'
    write-host 'There should be a DEBUG and an ERROR message (order matters)'
    write-host '    try   {@(1, 2) | assert-pipelineempty} <# line 147 #>'
    write-host '------------------------------------------------------------'
    try   {@(1, 2) | assert-pipelineempty}
    catch {$_ | out-host}
    write-host ''
    write-host ''
}

& {
    $VerbosePreference = 'Continue'
    $DebugPreference = 'Continue'

    write-host '-------------------------------------------------------------------'
    write-host 'There should be a VERBOSE, DEBUG and ERROR messages (order matters)'
    write-host '    try   {@(1, 2) | assert-pipelineempty} <# line 161 #>'
    write-host '-------------------------------------------------------------------'
    try   {@(1, 2) | assert-pipelineempty}
    catch {$_ | out-host}
    write-host ''
    write-host ''
}

write-host $('=' * ($HOST.ui.rawui.buffersize.width - 1))
write-host ''
