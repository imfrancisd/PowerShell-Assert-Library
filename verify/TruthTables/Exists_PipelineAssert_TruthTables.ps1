$collections = @('@()', '@(5)', '@(4, 5)', '@(1..5)')
$functions   = @('Assert-PipelineExists', 'Assert-PipelineNotExists')
$predicates  = @('{param($n) $n -eq 4}', '{param($n) $n -eq 5}', '{param($n) $n -eq 6}', '{param($n) $n -ge 4}')
$quantity = @('', '-Quantity Any', '-Quantity Single', '-Quantity Multiple')

'Exists (Pipeline Assert) Truth Tables'
'====================================='
Group-ListItem -CartesianProduct $collections, $functions, $predicates, $quantity |
    ForEach-Object  {
        $cmd = [scriptblock]::create($_.Items[0] + ' | ' + ($_.Items[1..3] -join ' '))
        $props = @{
            Collection = $_.Items[0]
            Function   = $_.Items[1]
            Predicate  = $_.Items[2]
            Quantity   = $_.Items[3]
            Output     = (& {try {& $cmd} catch {$_}} | Out-String).Trim()
        }
        New-Object psobject -property $props
    } |
    Format-Table -AutoSize -Wrap -Property Function, Collection, Predicate, Quantity, Output
