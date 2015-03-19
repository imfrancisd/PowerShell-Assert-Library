write-host $('=' * ($HOST.ui.rawui.buffersize.width - 1))
write-host $MyInvocation.MyCommand
write-host $('=' * ($HOST.ui.rawui.buffersize.width - 1))
write-host ''
write-host ''

& {
    $VerbosePreference = 'SilentlyContinue'
    $DebugPreference = 'SilentlyContinue'

    write-host '----------------------------------------------------'
    write-host 'There should be a line: hello'
    write-host "    @('hello') | assert-pipelinesingle <# line 15 #>"
    write-host '----------------------------------------------------'
    @('hello') | assert-pipelinesingle
    write-host ''
    write-host ''
}

& {
    $VerbosePreference = 'SilentlyContinue'
    $DebugPreference = 'SilentlyContinue'

    write-host '-------------------------------------------------------------'
    write-host 'There should be a line: hello'
    write-host 'There should be a PASSING VERBOSE message'
    write-host "    @('hello') | assert-pipelinesingle -verbose <# line 29 #>"
    write-host '-------------------------------------------------------------'
    @('hello') | assert-pipelinesingle -verbose
    write-host ''
    write-host ''
}

& {
    $VerbosePreference = 'SilentlyContinue'
    $DebugPreference = 'SilentlyContinue'

    write-host '-----------------------------------------------------------'
    write-host 'There should be a line: hello'
    write-host "    @('hello') | assert-pipelinesingle -debug <# line 42 #>"
    write-host '-----------------------------------------------------------'
    @('hello') | assert-pipelinesingle -debug
    write-host ''
    write-host ''
}

& {
    $VerbosePreference = 'SilentlyContinue'
    $DebugPreference = 'SilentlyContinue'

    write-host '--------------------------------------------------------------------'
    write-host 'There should be a line: hello'
    write-host 'There should be a PASSING VERBOSE message'
    write-host "    @('hello') | assert-pipelinesingle -verbose -debug <# line 56 #>"
    write-host '--------------------------------------------------------------------'
    @('hello') | assert-pipelinesingle -verbose -debug
    write-host ''
    write-host ''
}

& {
    $VerbosePreference = 'SilentlyContinue'
    $DebugPreference = 'SilentlyContinue'

    write-host '----------------------------------------------------'
    write-host 'There should be a line: hello'
    write-host "    @('hello') | assert-pipelinesingle <# line 69 #>"
    write-host '----------------------------------------------------'
    @('hello') | assert-pipelinesingle
    write-host ''
    write-host ''
}

& {
    $VerbosePreference = 'Continue'
    $DebugPreference = 'SilentlyContinue'

    write-host '----------------------------------------------------'
    write-host 'There should be a line: hello'
    write-host 'There should be a PASSING VERBOSE message'
    write-host "    @('hello') | assert-pipelinesingle <# line 83 #>"
    write-host '----------------------------------------------------'
    @('hello') | assert-pipelinesingle
    write-host ''
    write-host ''
}

& {
    $VerbosePreference = 'SilentlyContinue'
    $DebugPreference = 'Continue'

    write-host '----------------------------------------------------'
    write-host 'There should be a line: hello'
    write-host "    @('hello') | assert-pipelinesingle <# line 96 #>"
    write-host '----------------------------------------------------'
    @('hello') | assert-pipelinesingle
    write-host ''
    write-host ''
}

& {
    $VerbosePreference = 'Continue'
    $DebugPreference = 'Continue'

    write-host '-----------------------------------------------------'
    write-host 'There should be a line: hello'
    write-host 'There should be a PASSING VERBOSE message'
    write-host "    @('hello') | assert-pipelinesingle <# line 110 #>"
    write-host '-----------------------------------------------------'
    @('hello') | assert-pipelinesingle
    write-host ''
    write-host ''
}

& {
    $VerbosePreference = 'SilentlyContinue'
    $DebugPreference = 'SilentlyContinue'

    write-host '----------------------------------------------------------------------'
    write-host 'There should be a line: hello'
    write-host 'There should be an ERROR message'
    write-host '    try   {@('hello', 'world') | assert-pipelinesingle} <# line 124 #>'
    write-host '----------------------------------------------------------------------'
    try   {@('hello', 'world') | assert-pipelinesingle}
    catch {$_ | out-host}
    write-host ''
    write-host ''
}

& {
    $VerbosePreference = 'Continue'
    $DebugPreference = 'SilentlyContinue'

    write-host '----------------------------------------------------------------------'
    write-host 'There should be a line: hello'
    write-host 'There should be a VERBOSE and an ERROR message (order matters)'
    write-host '    try   {@('hello', 'world') | assert-pipelinesingle} <# line 139 #>'
    write-host '----------------------------------------------------------------------'
    try   {@('hello', 'world') | assert-pipelinesingle}
    catch {$_ | out-host}
    write-host ''
    write-host ''
}

& {
    $VerbosePreference = 'SilentlyContinue'
    $DebugPreference = 'Continue'

    write-host '----------------------------------------------------------------------'
    write-host 'There should be a line: hello'
    write-host 'There should be a DEBUG and an ERROR message (order matters)'
    write-host '    try   {@('hello', 'world') | assert-pipelinesingle} <# line 154 #>'
    write-host '----------------------------------------------------------------------'
    try   {@('hello', 'world') | assert-pipelinesingle}
    catch {$_ | out-host}
    write-host ''
    write-host ''
}

& {
    $VerbosePreference = 'Continue'
    $DebugPreference = 'Continue'

    write-host '----------------------------------------------------------------------'
    write-host 'There should be a line: hello'
    write-host 'There should be a VERBOSE, DEBUG and ERROR messages (order matters)'
    write-host '    try   {@('hello', 'world') | assert-pipelinesingle} <# line 169 #>'
    write-host '----------------------------------------------------------------------'
    try   {@('hello', 'world') | assert-pipelinesingle}
    catch {$_ | out-host}
    write-host ''
    write-host ''
}

write-host $('=' * ($HOST.ui.rawui.buffersize.width - 1))
write-host ''
