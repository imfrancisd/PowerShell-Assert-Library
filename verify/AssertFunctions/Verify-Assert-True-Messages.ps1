write-host $('=' * ($HOST.ui.rawui.buffersize.width - 1))
write-host $MyInvocation.MyCommand
write-host $('=' * ($HOST.ui.rawui.buffersize.width - 1))
write-host ''
write-host ''

& {
    $VerbosePreference = 'SilentlyContinue'
    $DebugPreference = 'SilentlyContinue'

    write-host '-----------------------------------'
    write-host 'There should be no messages'
    write-host '    assert-true $true <# line 15 #>'
    write-host '-----------------------------------'
    assert-true $true
    write-host ''
    write-host ''
}

& {
    $VerbosePreference = 'SilentlyContinue'
    $DebugPreference = 'SilentlyContinue'

    write-host '--------------------------------------------'
    write-host 'There should be a PASSING VERBOSE message'
    write-host '    assert-true $true -verbose <# line 28 #>'
    write-host '--------------------------------------------'
    assert-true $true -verbose
    write-host ''
    write-host ''
}

& {
    $VerbosePreference = 'SilentlyContinue'
    $DebugPreference = 'SilentlyContinue'

    write-host '------------------------------------------'
    write-host 'There should be no messages'
    write-host '    assert-true $true -debug <# line 41 #>'
    write-host '------------------------------------------'
    assert-true $true -debug
    write-host ''
    write-host ''
}

& {
    $VerbosePreference = 'SilentlyContinue'
    $DebugPreference = 'SilentlyContinue'

    write-host '---------------------------------------------------'
    write-host 'There should be a PASSING VERBOSE message'
    write-host '    assert-true $true -verbose -debug <# line 54 #>'
    write-host '---------------------------------------------------'
    assert-true $true -verbose -debug
    write-host ''
    write-host ''
}

& {
    $VerbosePreference = 'SilentlyContinue'
    $DebugPreference = 'SilentlyContinue'

    write-host '-----------------------------------'
    write-host 'There should be no messages'
    write-host '    assert-true $true <# line 67 #>'
    write-host '-----------------------------------'
    assert-true $true
    write-host ''
    write-host ''
}

& {
    $VerbosePreference = 'Continue'
    $DebugPreference = 'SilentlyContinue'

    write-host '-----------------------------------------'
    write-host 'There should be a PASSING VERBOSE message'
    write-host '    assert-true $true <# line 80 #>'
    write-host '-----------------------------------------'
    assert-true $true
    write-host ''
    write-host ''
}

& {
    $VerbosePreference = 'SilentlyContinue'
    $DebugPreference = 'Continue'

    write-host '-----------------------------------'
    write-host 'There should be no messages'
    write-host '    assert-true $true <# line 93 #>'
    write-host '-----------------------------------'
    assert-true $true
    write-host ''
    write-host ''
}

& {
    $VerbosePreference = 'Continue'
    $DebugPreference = 'Continue'

    write-host '-----------------------------------------'
    write-host 'There should be a PASSING VERBOSE message'
    write-host '    assert-true $true <# line 106 #>'
    write-host '-----------------------------------------'
    assert-true $true
    write-host ''
    write-host ''
}

& {
    $VerbosePreference = 'SilentlyContinue'
    $DebugPreference = 'SilentlyContinue'

    write-host '---------------------------------------------'
    write-host 'There should be an ERROR message'
    write-host '    try   {assert-true $false} <# line 119 #>'
    write-host '---------------------------------------------'
    try   {assert-true $false}
    catch {$_ | out-host}
    write-host ''
    write-host ''
}

& {
    $VerbosePreference = 'Continue'
    $DebugPreference = 'SilentlyContinue'

    write-host '--------------------------------------------------------------'
    write-host 'There should be a VERBOSE and an ERROR message (order matters)'
    write-host '    try   {assert-true $false} <# line 133 #>'
    write-host '--------------------------------------------------------------'
    try   {assert-true $false}
    catch {$_ | out-host}
    write-host ''
    write-host ''
}

& {
    $VerbosePreference = 'SilentlyContinue'
    $DebugPreference = 'Continue'

    write-host '------------------------------------------------------------'
    write-host 'There should be a DEBUG and an ERROR message (order matters)'
    write-host '    try   {assert-true $false} <# line 147 #>'
    write-host '------------------------------------------------------------'
    try   {assert-true $false}
    catch {$_ | out-host}
    write-host ''
    write-host ''
}

& {
    $VerbosePreference = 'Continue'
    $DebugPreference = 'Continue'

    write-host '-------------------------------------------------------------------'
    write-host 'There should be a VERBOSE, DEBUG and ERROR messages (order matters)'
    write-host '    try   {assert-true $false} <# line 161 #>'
    write-host '-------------------------------------------------------------------'
    try   {assert-true $false}
    catch {$_ | out-host}
    write-host ''
    write-host ''
}

write-host $('=' * ($HOST.ui.rawui.buffersize.width - 1))
write-host ''
