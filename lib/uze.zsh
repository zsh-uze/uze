# options are documented in man zshoptions
# make expansions more robust and powerful
#
# as example:
#
# * complains if a global variable is created
#   from a function or a sourced file
# * warn while using unset value. use :- :+ := ...

setopt warncreateglobal nounset pipefail \
    globstarshort extendedglob braceccl \
    pathdirs rcquotes \
    promptsubst promptbang promptpercent

it= k= v=
alias @='for it'
alias %='for k v'
alias %-='while {read k v}'
alias @-='while {read it}'
alias @--='while {IFS= read -r it}'
-\? () { local it; @- { "$@" $it && l $it } }

alias my@='typeset -a'
alias my%='typeset -A'
alias our@='typeset -ga'
alias our%='typeset -gA'

alias warn='() { local r=$?; print -u2 "$*"; return $r } "at $0 line $LINENO, warning: "'
alias die='() { local r=$?; print -u2 "$*"; return $r } "died at $0 line $LINENO: "'
alias ...='{warn unimplemented; return 255}'

l         () print -l "$@"
shush1    () "$@" 1> /dev/null
shush2    () "$@" 2> /dev/null
shush     () "$@" &> /dev/null
slurp     () IFS=$'\n' read -d '' -A $1
getlines  () { local _; IFS=$'\n' read -d '' "$@" _ }

alias uze/strict='setopt localoptions nounset warncreateglobal'
alias uze/no/strict='setopt localoptions unset nowarncreateglobal'

defined     () {
    local it
    @ { (( ${(P)+it} )) || return 1 }
}
uze/alias   () eval "$2 () { $1 "' "$@" }'
uze/which   () l $^path/$1.zsh(N)
uze/ns/dump () { local it; @ (${(Mk)functions:#$~1}) which $it }

uze () {

    my% EXPORT_TAGS # set of tags that can be defined in uze/import/$__PACKAGE__
    my@ EXPORT      # symbols declared to be exported
    local __PACKAGE__=$1 __SUB__ __CALLER__ it=

    shift
    .  $__PACKAGE__.zsh

    # execute the exporter if it is available
    # the exporter is in charge to
    # - define EXPORT_TAGS
    # - define EXPORT
    # - define the boolean delegate

    () {
        local delegate=true
        shush whence -w $1 && "$@"
        $delegate && { shift; EXPORT+=( "$@" ) }
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
