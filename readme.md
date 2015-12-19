the current documentation was extracted from the module. 
thinks we still have to do

# uze

general informations about \`uze\` are available on
[the project page](https://zsh-uze.github.com/). this document is the \`uze.zsh\`
manual.

in the current manual, we expect \`uze.zsh\` to be loaded.

## default behaviours

those defaults are discuted in the programming guide, they became mine after
years of zsh programming and hours of zsh debuging.

    setopt warncreateglobal nounset       # make zsh stricter
    setopt extendedglob braceccl rcquotes # make zsh more expressive

see also the "yada yada operator" from the helpers section.

## functions

### uze

`uze` loads a module and execute the `uze/import/the/module` function. then
exports the functions declared in `EXPORT_TAGS` and `EXPORT` variables.

see the project page documentation for more details about writting modules and
dealing with namespaces. 

### shush, shush1, shush2

redirect standard IOs to `/dev/null` so you can silently run a commmand

    shush  redirect both stderr and stdout
    shush1 redirect only stdout
    shush2 redirect only stderr

so

    shush grep foo bar && echo ok

is like

    shush grep &> /dev/null && echo ok

### warn

warn prints a message in stderr without changing the last command return (`$?`).

### die

die warns and exit.

### fill

read multiple lines into a list of variables

    date +"%Y\n%m" | fill year month
    echo $year

### slurp

read multiple lines in an array

    getent passwd | slurp users
    print "entry of root is" $users[1]

### my% and my@ aliases

those are shorter, memorizable aliases for `typeset -A`
(local associative array) and `typeset -a` (local array).

    Perl                     | zsh                   | uze
    ------------------------------------------------------------
    my %foo                  | typeset -A  foo       | my% foo
    my @bar                  | typeset -a  bar       | my@ bar
    ref $user                | ${(t)user}            |
    (ref $user) // 'no more' | ${(t)user-no more}    |
    exists $user{cpan}       | (( $+user[cpan] ))    |

\`my@\` is only usefull inside a function to prevent the declaration
of a global array.

### apply

apply a function (with arguments) for each lines of `stdin` as `$it`.

    greetings () { print "$* $it" }
    seq 3 |apply greetings hello

will output

    hello 1
    hello 2
    hello 3

### epply

eval a block for each lines of `stdin` as `$it`.

    seq 3 |epply 'print hello $it'

will output

    hello 1
    hello 2
    hello 3

### pipify

for an existing command `foo`, pipify create a `foo-` command that
takes an extra argument from `stdin` repeatidly. 

    pipify foo 

is like

    foo- () {
        local it
        while {read it} {foo "$@" $it}
    }

### the yada yada operator (...)

warns an "unimplemented" message and returns false.
