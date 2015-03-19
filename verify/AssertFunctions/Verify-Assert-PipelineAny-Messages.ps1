write-host $('=' * ($HOST.ui.rawui.buffersize.width - 1))
write-host $MyInvocation.MyCommand
write-host $('=' * ($HOST.ui.rawui.buffersize.width - 1))
write-host ''
write-host ''

& {
    $VerbosePreference = 'SilentlyContinue'
    $DebugPreference = 'SilentlyContinue'

    write-host '----------------------------------------------------------'
    write-host 'There should be a line: hello'
    write-host 'There should be a line: world'
    write-host "    @('hello', 'world') | assert-pipelineany <# line 16 #>"
    write-host '----------------------------------------------------------'
    @('hello', 'world') | assert-pipelineany
    write-host ''
    write-host ''
}

& {
    $VerbosePreference = 'SilentlyContinue'
    $DebugPreference = 'SilentlyContinue'

    write-host '-------------------------------------------------------------------'
    write-host 'There should be a line: hello'
    write-host 'There should be a line: world'
    write-host 'There should be a PASSING VERBOSE message'
    write-host "    @('hello', 'world') | assert-pipelineany -verbose <# line 31 #>"
    write-host '-------------------------------------------------------------------'
    @('hello', 'world') | assert-pipelineany -verbose
    write-host ''
    write-host ''
}

& {
    $VerbosePreference = 'SilentlyContinue'
    $DebugPreference = 'SilentlyContinue'

    write-host '-----------------------------------------------------------------'
    write-host 'There should be a line: hello'
    write-host 'There should be a line: world'
    write-host "    @('hello', 'world') | assert-pipelineany -debug <# line 45 #>"
    write-host '-----------------------------------------------------------------'
    @('hello', 'world') | assert-pipelineany -debug
    write-host ''
    write-host ''
}

& {
    $VerbosePreference = 'SilentlyContinue'
    $DebugPreference = 'SilentlyContinue'

    write-host '--------------------------------------------------------------------------'
    write-host 'There should be a line: hello'
    write-host 'There should be a line: world'
    write-host 'There should be a PASSING VERBOSE message'
    write-host "    @('hello', 'world') | assert-pipelineany -verbose -debug <# line 60 #>"
    write-host '--------------------------------------------------------------------------'
    @('hello', 'world') | assert-pipelineany -verbose -debug
    write-host ''
    write-host ''
}

& {
    $VerbosePreference = 'SilentlyContinue'
    $DebugPreference = 'SilentlyContinue'

    write-host '----------------------------------------------------------'
    write-host 'There should be a line: hello'
    write-host 'There should be a line: world'
    write-host "    @('hello', 'world') | assert-pipelineany <# line 74 #>"
    write-host '----------------------------------------------------------'
    @('hello', 'world') | assert-pipelineany
    write-host ''
    write-host ''
}

& {
    $VerbosePreference = 'Continue'
    $DebugPreference = 'SilentlyContinue'

    write-host '----------------------------------------------------------'
    write-host 'There should be a line: hello'
    write-host 'There should be a line: world'
    write-host 'There should be a PASSING VERBOSE message'
    write-host "    @('hello', 'world') | assert-pipelineany <# line 89 #>"
    write-host '----------------------------------------------------------'
    @('hello', 'world') | assert-pipelineany
    write-host ''
    write-host ''
}

& {
    $VerbosePreference = 'SilentlyContinue'
    $DebugPreference = 'Continue'

    write-host '-----------------------------------------------------------'
    write-host 'There should be a line: hello'
    write-host 'There should be a line: world'
    write-host "    @('hello', 'world') | assert-pipelineany <# line 103 #>"
    write-host '-----------------------------------------------------------'
    @('hello', 'world') | assert-pipelineany
    write-host ''
    write-host ''
}

& {
    $VerbosePreference = 'Continue'
    $DebugPreference = 'Continue'

    write-host '-----------------------------------------------------------'
    write-host 'There should be a line: hello'
    write-host 'There should be a line: world'
    write-host 'There should be a PASSING VERBOSE message'
    write-host "    @('hello', 'world') | assert-pipelineany <# line 118 #>"
    write-host '-----------------------------------------------------------'
    @('hello', 'world') | assert-pipelineany
    write-host ''
    write-host ''
}

& {
    $VerbosePreference = 'SilentlyContinue'
    $DebugPreference = 'SilentlyContinue'

    write-host '---------------------------------------------------------'
    write-host 'There should be an ERROR message'
    write-host '    try   {@() | assert-pipelineany} <# line 131 #>'
    write-host '---------------------------------------------------------'
    try   {@() | assert-pipelineany}
    catch {$_ | out-host}
    write-host ''
    write-host ''
}

& {
    $VerbosePreference = 'Continue'
    $DebugPreference = 'SilentlyContinue'

    write-host '--------------------------------------------------------------'
    write-host 'There should be a VERBOSE and an ERROR message (order matters)'
    write-host '    try   {@() | assert-pipelineany} <# line 145 #>'
    write-host '--------------------------------------------------------------'
    try   {@() | assert-pipelineany}
    catch {$_ | out-host}
    write-host ''
    write-host ''
}

& {
    $VerbosePreference = 'SilentlyContinue'
    $DebugPreference = 'Continue'

    write-host '------------------------------------------------------------'
    write-host 'There should be a DEBUG and an ERROR message (order matters)'
    write-host '    try   {@() | assert-pipelineany} <# line 159 #>'
    write-host '------------------------------------------------------------'
    try   {@() | assert-pipelineany}
    catch {$_ | out-host}
    write-host ''
    write-host ''
}

& {
    $VerbosePreference = 'Continue'
    $DebugPreference = 'Continue'

    write-host '-------------------------------------------------------------------'
    write-host 'There should be a VERBOSE, DEBUG and ERROR messages (order matters)'
    write-host '    try   {@() | assert-pipelineany} <# line 173 #>'
    write-host '-------------------------------------------------------------------'
    try   {@() | assert-pipelineany}
    catch {$_ | out-host}
    write-host ''
    write-host ''
}

write-host $('=' * ($HOST.ui.rawui.buffersize.width - 1))
write-host ''
