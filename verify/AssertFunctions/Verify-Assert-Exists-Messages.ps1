write-host $('=' * ($HOST.ui.rawui.buffersize.width - 1))
write-host $MyInvocation.MyCommand
write-host $('=' * ($HOST.ui.rawui.buffersize.width - 1))
write-host ''
write-host ''

& {
    $VerbosePreference = 'SilentlyContinue'
    $DebugPreference = 'SilentlyContinue'

    write-host '------------------------------------------------------------'
    write-host 'There should be no messages'
    write-host '    assert-exists @(1, 2) {param($n) $n -gt 1} <# line 15 #>'
    write-host '------------------------------------------------------------'
    assert-exists @(1, 2) {param($n) $n -gt 1}
    write-host ''
    write-host ''
}

& {
    $VerbosePreference = 'SilentlyContinue'
    $DebugPreference = 'SilentlyContinue'

    write-host '---------------------------------------------------------------------'
    write-host 'There should be a PASSING VERBOSE message'
    write-host '    assert-exists @(1, 2) {param($n) $n -gt 1} -verbose <# line 28 #>'
    write-host '---------------------------------------------------------------------'
    assert-exists @(1, 2) {param($n) $n -gt 1} -verbose
    write-host ''
    write-host ''
}

& {
    $VerbosePreference = 'SilentlyContinue'
    $DebugPreference = 'SilentlyContinue'

    write-host '-------------------------------------------------------------------'
    write-host 'There should be no messages'
    write-host '    assert-exists @(1, 2) {param($n) $n -gt 1} -debug <# line 41 #>'
    write-host '-------------------------------------------------------------------'
    assert-exists @(1, 2) {param($n) $n -gt 1} -debug
    write-host ''
    write-host ''
}

& {
    $VerbosePreference = 'SilentlyContinue'
    $DebugPreference = 'SilentlyContinue'

    write-host '----------------------------------------------------------------------------'
    write-host 'There should be a PASSING VERBOSE message'
    write-host '    assert-exists @(1, 2) {param($n) $n -gt 1} -verbose -debug <# line 54 #>'
    write-host '----------------------------------------------------------------------------'
    assert-exists @(1, 2) {param($n) $n -gt 1} -verbose -debug
    write-host ''
    write-host ''
}

& {
    $VerbosePreference = 'SilentlyContinue'
    $DebugPreference = 'SilentlyContinue'

    write-host '------------------------------------------------------------'
    write-host 'There should be no messages'
    write-host '    assert-exists @(1, 2) {param($n) $n -gt 1} <# line 67 #>'
    write-host '------------------------------------------------------------'
    assert-exists @(1, 2) {param($n) $n -gt 1}
    write-host ''
    write-host ''
}

& {
    $VerbosePreference = 'Continue'
    $DebugPreference = 'SilentlyContinue'

    write-host '------------------------------------------------------------'
    write-host 'There should be a PASSING VERBOSE message'
    write-host '    assert-exists @(1, 2) {param($n) $n -gt 1} <# line 80 #>'
    write-host '------------------------------------------------------------'
    assert-exists @(1, 2) {param($n) $n -gt 1}
    write-host ''
    write-host ''
}

& {
    $VerbosePreference = 'SilentlyContinue'
    $DebugPreference = 'Continue'

    write-host '------------------------------------------------------------'
    write-host 'There should be no messages'
    write-host '    assert-exists @(1, 2) {param($n) $n -gt 1} <# line 93 #>'
    write-host '------------------------------------------------------------'
    assert-exists @(1, 2) {param($n) $n -gt 1}
    write-host ''
    write-host ''
}

& {
    $VerbosePreference = 'Continue'
    $DebugPreference = 'Continue'

    write-host '-------------------------------------------------------------'
    write-host 'There should be a PASSING VERBOSE message'
    write-host '    assert-exists @(1, 2) {param($n) $n -gt 1} <# line 106 #>'
    write-host '-------------------------------------------------------------'
    assert-exists @(1, 2) {param($n) $n -gt 1}
    write-host ''
    write-host ''
}

& {
    $VerbosePreference = 'SilentlyContinue'
    $DebugPreference = 'SilentlyContinue'

    write-host '---------------------------------------------------------------------'
    write-host 'There should be an ERROR message'
    write-host '    try   {assert-exists @(1, 2) {param($n) $n -gt 2}} <# line 119 #>'
    write-host '---------------------------------------------------------------------'
    try   {assert-exists @(1, 2) {param($n) $n -gt 2}}
    catch {$_ | out-host}
    write-host ''
    write-host ''
}

& {
    $VerbosePreference = 'Continue'
    $DebugPreference = 'SilentlyContinue'

    write-host '---------------------------------------------------------------------'
    write-host 'There should be a VERBOSE and an ERROR message (order matters)'
    write-host '    try   {assert-exists @(1, 2) {param($n) $n -gt 2}} <# line 133 #>'
    write-host '---------------------------------------------------------------------'
    try   {assert-exists @(1, 2) {param($n) $n -gt 2}}
    catch {$_ | out-host}
    write-host ''
    write-host ''
}

& {
    $VerbosePreference = 'SilentlyContinue'
    $DebugPreference = 'Continue'

    write-host '---------------------------------------------------------------------'
    write-host 'There should be a DEBUG and an ERROR message (order matters)'
    write-host '    try   {assert-exists @(1, 2) {param($n) $n -gt 2}} <# line 147 #>'
    write-host '---------------------------------------------------------------------'
    try   {assert-exists @(1, 2) {param($n) $n -gt 2}}
    catch {$_ | out-host}
    write-host ''
    write-host ''
}

& {
    $VerbosePreference = 'Continue'
    $DebugPreference = 'Continue'

    write-host '---------------------------------------------------------------------'
    write-host 'There should be a VERBOSE, DEBUG and ERROR messages (order matters)'
    write-host '    try   {assert-exists @(1, 2) {param($n) $n -gt 2}} <# line 161 #>'
    write-host '---------------------------------------------------------------------'
    try   {assert-exists @(1, 2) {param($n) $n -gt 2}}
    catch {$_ | out-host}
    write-host ''
    write-host ''
}

write-host $('=' * ($HOST.ui.rawui.buffersize.width - 1))
write-host ''
