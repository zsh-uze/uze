: <<'=cut'

=head1 uze for impatients

uze make your zsh more perlish

download [uze](https://raw.githubusercontent.com/zsh-uze/uze/master/lib/uze.zsh)
somewhere in your local drive and add this in your `.zshenv`

  . /path/to/uze.zsh
  # or just
  . uze.zsh
  # if uze.zsh is in your path

now, the behaviors described below applies. so you can write

    uze my-lib :all

    if {which perl} {
        warn "perl is ready to run"
    } else {
        # yes! you can use yada now
        ...
    }

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

=head2 functions

=head3 uze

C<uze> loads a module and execute the C<uze/import/the/module> function. then
exports the functions declared in C<EXPORT_TAGS> and C<EXPORT> variables.

see the project page documentation for more details about writting modules and
dealing with namespaces. 

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

=head3 apply

apply a function (with arguments) for each lines of C<stdin> as C<$it>.

    greetings () { print "$* $it" }
    seq 3 |apply greetings hello

will output

    hello 1
    hello 2
    hello 3

=head3 epply

eval a block for each lines of C<stdin> as C<$it>.

    seq 3 |epply 'print hello $it'

will output

    hello 1
    hello 2
    hello 3


=head3 pipify

for an existing command C<foo>, pipify create a C<foo-> command that
takes an extra argument from C<stdin> repeatidly. 

    pipify foo 

is like

    foo- () {
        local it
        while {read it} {foo "$@" $it}
    }

=head3 the yada yada operator (...)

warns an "unimplemented" message and returns false.

=head3 herror macro

herror is a violent contraction of 'here error', it warns an error message
prefixed by the place it was rised.

=cut

setopt warncreateglobal nounset extendedglob braceccl pathdirs rcquotes

shush1   () { "$@" 1> /dev/null }
shush2   () { "$@" 2> /dev/null }
shush    () { "$@" &> /dev/null }
warn     () { local r=$?; print -u2 -- "$*"; return $r }
die      () { local r=$?; print -u2 -- "$*"; exit $r   }
slurp    () { IFS=$'\n' read -d '' -A $1 }
fill     () { local __garbage; IFS=$'\n' read -d '' "$@" __garbage }

alias my@='typeset -a'
alias my%='typeset -A'

apply  ()  { local it; while {read it} { "$@" $it } }
epply  ()  { local it; while {read it} { eval "$@" } }
defined () { eval '(( ${+'${1?symbol to test }'} ))' }
pipify ()  { eval "$1- () {local it; while {read it} { $1 \"\$@\" \$it }}" }

alias ...='{warn "Unimplemented in $0 line $LINENO"; return 255}'
alias herror='print -u2 -- "$0:$LINENO error"'

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

uze () {
    my% EXPORT_TAGS
    my@ EXPORT
    local __PACKAGE__=$1 UZE_ __SUB__ ok=true msg
    shift
    .  $__PACKAGE__.zsh
    () { shush whence -w $1 && $1 } uze/import/$__PACKAGE__

    for UZE_ {
        if [[ $UZE_ == :* ]] {
            if (( $+EXPORT_TAGS[$UZE_] )) { EXPORT+=( $=EXPORT_TAGS[$UZE_] ) }\
            else {
                warn "$UZE_ isn't an EXPORT_TAG"
                ok=false
            }
        } else { EXPORT+=$UZE_ }
    }

    for UZE_ ( ${(u)EXPORT} ) {
        __SUB__=$__PACKAGE__/$UZE_
        msg="$UZE_ was $(shush2 whence -m $UZE_), redefined as $__SUB__" &&
            { warn $msg; ok=false }
        shush which $__SUB__ ||
            { warn "exported $__SUB__ is not defined"; ok=false }
        alias $UZE_=$__SUB__
    }

    $ok

}

alias uze/help='uze/doc ${0%/*}'
alias uze/pkg='0=${0%.zsh};'
# alias uze/pkg='uzed_+=$0; 0=${0%.zsh};'
