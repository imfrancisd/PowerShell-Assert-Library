$functions   = @('Test-Exists', 'Test-NotExists')
$collections = @('@()', '@(5)', '@(4, 5)', '@(1..5)')
$predicates  = @('{param($n) $n -eq 4}', '{param($n) $n -eq 5}', '{param($n) $n -eq 6}', '{param($n) $n -ge 3}', '{param($n) $n -ge 4}')
$quantity    = @('', '-Quantity Any', '-Quantity Single', '-Quantity Multiple')

'Exists (Logic) Truth Tables'
'==========================='
Group-ListItem -CartesianProduct $functions, $collections, $predicates, $quantity |
    ForEach-Object  {
        $cmd = [scriptblock]::create($_.Items -join ' ')
        $props = @{
            Function   = $_.Items[0]
            Collection = $_.Items[1]
            Predicate  = $_.Items[2]
            Quantity   = $_.Items[3]
            Output     = & {try {& $cmd} catch {$_}} | Out-String
        }
        New-Object psobject -property $props
    } |
    Format-Table -AutoSize -Wrap -Property Function, Collection, Predicate, Quantity, Output
