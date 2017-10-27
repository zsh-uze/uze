setopt warncreateglobal nounset extendedglob braceccl pathdirs rcquotes \
    promptsubst promptbang promptpercent

it= k= v=
alias @='for it'
alias %='for k v'
alias %-='while {read k v}'
alias @-='while {read it}'
alias l='print -l'

alias my@='typeset -a'
alias my%='typeset -A'
alias our@='typeset -ga'
alias our%='typeset -gA'

warn_ () { local r=$?; print -u2 "$*"; return $r }
die_  () { local r=$?; print -u2 "$*"; exit   $r }
alias warn='warn_ at $0 line $LINENO, warning:'
alias ...='{warn unimplemented; return 255}'
alias die='die_  died at $0 line $LINENO:'
# f () { l 'ok'; ... ; l 'not ok' }

shush1    () { "$@" 1> /dev/null }
shush2    () { "$@" 2> /dev/null }
shush     () { "$@" &> /dev/null }
slurp     () { IFS=$'\n' read -d '' -A $1 }
readlines () { local _; IFS=$'\n' read -d '' "$@" _ }

alias uze/strict='setopt localoptions unset nowarncreateglobal'
alias no/strict='setopt  localoptions nounset warncreateglobal'

defined () (( ${(P)+1} ))

uze/alias () { eval "$2 () { $1 "' "$@" }' }

uze () {

    my% EXPORT_TAGS # set of tags that can be defined in uze/import/$__PACKAGE__
    my@ EXPORT      # symbols declared to be exported
    local __PACKAGE__=$1 __SUB__ __CALLER__ it=

    shift
    .  $__PACKAGE__.zsh
    () {
        if    { shush whence -w $1 } { "$@" }\
        else  { shift; EXPORT=( "$@" ) }
    } uze/export/$__PACKAGE__ "$@"

    my@ exportable
    @ ($EXPORT) {
        case $it {
            (:*) exportable+=( ${=EXPORT_TAGS[$it]?unknown tag $it} ) ;;
            (*)  exportable+=$it ;;
        }
    }

    @ ( ${(u)exportable} ) uze/alias $__PACKAGE__/$it $it
}
