write-host $('=' * ($HOST.ui.rawui.buffersize.width - 1))
write-host $MyInvocation.MyCommand
write-host $('=' * ($HOST.ui.rawui.buffersize.width - 1))
write-host ''
write-host ''

& {
    $VerbosePreference = 'SilentlyContinue'
    $DebugPreference = 'SilentlyContinue'

    write-host '--------------------------------------------------------------'
    write-host 'There should be a line: hello'
    write-host 'There should be a line: world'
    write-host "    @('hello', 'world') | assert-pipelinecount 2 <# line 16 #>"
    write-host '--------------------------------------------------------------'
    @('hello', 'world') | assert-pipelinecount 2
    write-host ''
    write-host ''
}

& {
    $VerbosePreference = 'SilentlyContinue'
    $DebugPreference = 'SilentlyContinue'

    write-host '-----------------------------------------------------------------------'
    write-host 'There should be a line: hello'
    write-host 'There should be a line: world'
    write-host 'There should be a PASSING VERBOSE message'
    write-host "    @('hello', 'world') | assert-pipelinecount 2 -verbose <# line 31 #>"
    write-host '-----------------------------------------------------------------------'
    @('hello', 'world') | assert-pipelinecount 2 -verbose
    write-host ''
    write-host ''
}

& {
    $VerbosePreference = 'SilentlyContinue'
    $DebugPreference = 'SilentlyContinue'

    write-host '---------------------------------------------------------------------'
    write-host 'There should be a line: hello'
    write-host 'There should be a line: world'
    write-host "    @('hello', 'world') | assert-pipelinecount 2 -debug <# line 45 #>"
    write-host '---------------------------------------------------------------------'
    @('hello', 'world') | assert-pipelinecount 2 -debug
    write-host ''
    write-host ''
}

& {
    $VerbosePreference = 'SilentlyContinue'
    $DebugPreference = 'SilentlyContinue'

    write-host '------------------------------------------------------------------------------'
    write-host 'There should be a line: hello'
    write-host 'There should be a line: world'
    write-host 'There should be a PASSING VERBOSE message'
    write-host "    @('hello', 'world') | assert-pipelinecount 2 -verbose -debug <# line 60 #>"
    write-host '------------------------------------------------------------------------------'
    @('hello', 'world') | assert-pipelinecount 2 -verbose -debug
    write-host ''
    write-host ''
}

& {
    $VerbosePreference = 'SilentlyContinue'
    $DebugPreference = 'SilentlyContinue'

    write-host '--------------------------------------------------------------'
    write-host 'There should be a line: hello'
    write-host 'There should be a line: world'
    write-host "    @('hello', 'world') | assert-pipelinecount 2 <# line 74 #>"
    write-host '--------------------------------------------------------------'
    @('hello', 'world') | assert-pipelinecount 2
    write-host ''
    write-host ''
}

& {
    $VerbosePreference = 'Continue'
    $DebugPreference = 'SilentlyContinue'

    write-host '--------------------------------------------------------------'
    write-host 'There should be a line: hello'
    write-host 'There should be a line: world'
    write-host 'There should be a PASSING VERBOSE message'
    write-host "    @('hello', 'world') | assert-pipelinecount 2 <# line 89 #>"
    write-host '--------------------------------------------------------------'
    @('hello', 'world') | assert-pipelinecount 2
    write-host ''
    write-host ''
}

& {
    $VerbosePreference = 'SilentlyContinue'
    $DebugPreference = 'Continue'

    write-host '---------------------------------------------------------------'
    write-host 'There should be a line: hello'
    write-host 'There should be a line: world'
    write-host "    @('hello', 'world') | assert-pipelinecount 2 <# line 103 #>"
    write-host '---------------------------------------------------------------'
    @('hello', 'world') | assert-pipelinecount 2
    write-host ''
    write-host ''
}

& {
    $VerbosePreference = 'Continue'
    $DebugPreference = 'Continue'

    write-host '---------------------------------------------------------------'
    write-host 'There should be a line: hello'
    write-host 'There should be a line: world'
    write-host 'There should be a PASSING VERBOSE message'
    write-host "    @('hello', 'world') | assert-pipelinecount 2 <# line 118 #>"
    write-host '---------------------------------------------------------------'
    @('hello', 'world') | assert-pipelinecount 2
    write-host ''
    write-host ''
}

& {
    $VerbosePreference = 'SilentlyContinue'
    $DebugPreference = 'SilentlyContinue'

    write-host '--------------------------------------------------------------'
    write-host 'There should be a line: hello'
    write-host 'There should be an ERROR message'
    write-host '    try   {@('hello') | assert-pipelinecount 2} <# line 132 #>'
    write-host '--------------------------------------------------------------'
    try   {@('hello') | assert-pipelinecount 2}
    catch {$_ | out-host}
    write-host ''
    write-host ''
}

& {
    $VerbosePreference = 'Continue'
    $DebugPreference = 'SilentlyContinue'

    write-host '--------------------------------------------------------------'
    write-host 'There should be a line: hello'
    write-host 'There should be a VERBOSE and an ERROR message (order matters)'
    write-host '    try   {@('hello') | assert-pipelinecount 2} <# line 147 #>'
    write-host '--------------------------------------------------------------'
    try   {@('hello') | assert-pipelinecount 2}
    catch {$_ | out-host}
    write-host ''
    write-host ''
}

& {
    $VerbosePreference = 'SilentlyContinue'
    $DebugPreference = 'Continue'

    write-host '--------------------------------------------------------------'
    write-host 'There should be a line: hello'
    write-host 'There should be a DEBUG and an ERROR message (order matters)'
    write-host '    try   {@('hello') | assert-pipelinecount 2} <# line 162 #>'
    write-host '--------------------------------------------------------------'
    try   {@('hello') | assert-pipelinecount 2}
    catch {$_ | out-host}
    write-host ''
    write-host ''
}

& {
    $VerbosePreference = 'Continue'
    $DebugPreference = 'Continue'

    write-host '-------------------------------------------------------------------'
    write-host 'There should be a line: hello'
    write-host 'There should be a VERBOSE, DEBUG and ERROR messages (order matters)'
    write-host '    try   {@('hello') | assert-pipelinecount 2} <# line 177 #>'
    write-host '-------------------------------------------------------------------'
    try   {@('hello') | assert-pipelinecount 2}
    catch {$_ | out-host}
    write-host ''
    write-host ''
}

write-host $('=' * ($HOST.ui.rawui.buffersize.width - 1))
write-host ''
