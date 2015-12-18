: <<'=cut'

=head1 uze

general informations about `uze` are available on
L<the project page|https://zsh-uze.github.com/>. this document is the `uze.zsh`
manual.

in the current manual, we expect `uze.zsh` to be loaded.

=head2 default behaviours

those defaults are discuted in the programming guide, they became mine after 
years of zsh programming and hours of zsh debuging.

    setopt warncreateglobal nounset       # make zsh stricter
    setopt extendedglob braceccl rcquotes # make zsh more expressive

see also the "yada yada operator" from the helpers section.

=head2 namespaces and modules

for more details about the behavior of `uze`, see the project page.

=head2 other helpers

=head3 shush, shush1, shush2

redirect standard IOs to C</dev/null> so you can silently run a commmand

    shush  redirect both stderr and stdout
    shush1 redirect only stdout
    shush2 redirect only stderr

so

    shush grep foo bar && echo ok

is like 

    shush grep &> /dev/null && echo ok

=head3 warn

warn prints a message in stderr without changing the last command return (C<$?>).

=head3 die

die warns and exit.

=head3 fill

read multiple lines into a list of variables 

    date +"%Y\n%m" | fill year month
    echo $year

=head3 slurp

read multiple lines in an array

    getent passwd | slurp users
    print "entry of root is" $users[1]

=head3 my% and my@ aliases

those are shorter, memorizable aliases for C<typeset -A>
(local associative array) and C<typeset -a> (local array). 

    Perl                     | zsh                   | uze
    ------------------------------------------------------------
    my %foo                  | typeset -A  foo       | my% foo
    my @bar                  | typeset -a  bar       | my@ bar
    ref $user                | ${(t)user}            |
    (ref $user) // 'no more' | ${(t)user-no more}    |
    exists $user{cpan}       | (( $+user[cpan] ))    |

`my@` is only usefull inside a function to prevent the declaration
of a global array.

=head3 defined

=head3 apply

=head3 epply

=head3 pipify

=head3 the yada yada operator (...)

=cut

setopt warncreateglobal nounset extendedglob braceccl pathdirs rcquotes

shush1   () { "$@" 1> /dev/null }
shush2   () { "$@" 2> /dev/null }
shush    () { "$@" &> /dev/null }
warn     () { local r=$?; print -u2 "$*"; return $r }
die      () { local r=$?; print -u2 "$*"; exit $r   }
slurp    () { IFS=$'\n' read -d '' -A $1 }
fill     () { local __garbage; IFS=$'\n' read -d '' "$@" __garbage }

alias my@='typeset -a'
alias my%='typeset -A'

apply  ()  { local it; while {read it} { "$@" $it } }
epply  ()  { local it; while {read it} { eval "$@" } }
defined () { eval '(( ${+'${1?symbol to test }'} ))' }
pipify ()  { eval "$1- () {local it; while {read it} { $1 \"\$@\" \$it }}" }

alias ...='{warn "Unimplemented in $0 line $LINENO"; return 255}'

uzu/alias () {
    local uzu_al
    for uzu_al { alias $uzu_al=$uzu_ns/$uzu_al }
}

uzu () {

    local uzu_ns=$1 uzu_does
    shift
    typeset -a uzu_can
    uzu_can=( ${^path}/{,uze/}$uzu_ns(N) )

    ((#uzu_can)) || {
        warn "can't find $uzu_ns in \$path"
        return
    }

    . $uzu_can[1]
    typeset -a UZU_EXPORT
    local uzu_exporter=uzu/$uzu_ns  
    if {shush which $uzu_exporter} {
        if {$uzu_exporter $@} { uzu/alias $UZU_EXPORT }
    } else { uzu/alias $@ }
}

uze/pkg/path () {
    path=( ${(u)path} )
    __FILE__=($^path/$1.zsh([1]ND))
}

uze/pkg/do () {
    local __FILE__
    uze/pkg/path $1
    shift
    "$@"
}

uze/doc    () { uze/pkg/do $1 eval "perldoc ${@[2,-1]} \$__FILE__" }
uze/doc/md () { uze/doc $1 -o Markdown }

# call a function if declared
uze/iffn () { (( ${+functions[$1]} )) && "$@" }

uze () {
    local __PACKAGE__=$1 UZE_
    my@ UZE
    shift
    .  $__PACKAGE__.zsh
    for UZE_
        uze/iffn uze/import/$__PACKAGE__/$UZE_ ||
            UZE+=$UZE_
    for UZE_ ($UZE) { alias $UZE_=$__PACKAGE__/$UZE_ }
}

alias uze/help='uze/doc ${0%/*}'
alias uze/pkg='0=${0%.zsh};'
# alias uze/pkg='uzed_+=$0; 0=${0%.zsh};'
