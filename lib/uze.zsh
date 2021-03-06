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
them=()
alias @='for it'
alias %='for k v'
alias %-='while {read k v}'
alias @-='while {read it}'
alias @--='while {IFS= read -r it}'
\?- () { local it; @- { "$@" $it && l $it } }

# so now you can use (#b) pattern matching without zsh
# to complain for undefined variables
alias local:match='local -a mbegin mend match'

alias my@='typeset -a'
alias my%='typeset -A'
alias our@='typeset -ga'
alias our%='typeset -gA'

alias warn='() { local r=$?; print -u2 "$*"; return $r } "at $0 line $LINENO, warning:"'
alias die='()  { local r=$?; print -u2 "$*"; exit $r   } "died at $0 line $LINENO:"; exit'
alias ...='{warn unimplemented; return 255}'

l         () print -l "$@"
shush1    () "$@" 1> /dev/null
shush2    () "$@" 2> /dev/null
shush     () "$@" &> /dev/null

# slurp should be as simple as
# slurp     () IFS=$'\n' read -r -d '' -A $1
# but if you do so, empty lines are ignored
# so ...

slurp () {
    local it
    local _Slurp4rr4y_=${1:-them}
    set --
    @-- { set -- "$@" "$it" }
    set -A "${(@)_Slurp4rr4y_}" "$@"
}

getlines  () {
    local G371in3z
    for G371in3z { IFS= read -r $G371in3z }
}

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
            (:*)
                if [[ -z ${EXPORT_TAGS[$it]:-} ]] {
                    # TODO: add in the message:
                    # test if uze/export/$__PACKAGE__
                    warn "\$EXPORT_TAGS doesn't provide a '$it' tag for $__PACKAGE__. is uze/export/$__PACKAGE__ defined ?"
                } else {
                    exportable+=( ${=EXPORT_TAGS[$it]} )
                }
            ;;
            (*)  exportable+=$it ;;
        }
    }

    @ ( ${(u)exportable} ) uze/alias $__PACKAGE__/$it $it
}
