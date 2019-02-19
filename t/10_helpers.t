. uze.zsh
path+=( t/bin )
uze TAP :all

TAP/do

got=()
slurp got <<\.

this is it

a simple test to with some spaces

.

expected=(
    ""
    "this is it"
    ""
    "a simple test to with some spaces"
    ""
)

for line ( {1..$#expected} ) {
    [[ "$got[line]" = "$expected[line]" ]]
    ok line $line matches "'$got[line]'"
}

local -A lines=(
    a ""
    b "this is it"
    c ""
    d "a simple test to with some spaces"
    e ""
)
local keys=( {a..e} )
local -A expected_lines

getlines expected_lines\[$^keys] <<\.

this is it

a simple test to with some spaces

.

# getlines expected_lines\[$^keys]

for k ($keys) {
    [[ "$expected_lines[$k]" = "$lines[$k]" ]]
    ok "line $k is identical" ||
        note "'$expected_lines[$k]' = '$lines[$k]'"
}

TAP/done

