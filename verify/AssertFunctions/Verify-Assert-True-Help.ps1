write-host $('=' * ($HOST.ui.rawui.buffersize.width - 1))
write-host $MyInvocation.MyCommand
write-host $('=' * ($HOST.ui.rawui.buffersize.width - 1))
write-host ''
write-host ''

& {
    write-host '------------------------------------'
    write-host 'There should be a complete help file'
    write-host '    get-help assert-true -Full'
    write-host '------------------------------------'
    get-help assert-true -Full
}

write-host $('=' * ($HOST.ui.rawui.buffersize.width - 1))
write-host ''
write-host ''
