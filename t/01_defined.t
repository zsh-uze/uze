uze TAP :all

helpers_are_working () {

    # variables listed in $expectations shoud be
    # * tested as undefined (at BEFOREDEF)
    # * declared (at DEF)
    # * tested as defined (at AFTERDEF)
    # the listed in $still_undefined are
    # unset keys of defined arrays, they should
    # remain undef (at STILL)

    my@ expectations=(
        expected_as_defined
        expected
        expected_for
        'expected[1]'
        'expected_for[testing]'
    )

    my@ still_undefined=(
        'expected[2]'
        'expected_for[failing]'
    )

    # 1 pass on still_undefined, 2 on expectations
    # so the plan is
    # 3 tests for MULTIP
    plan $[ 3 + $#still_undefined + $#expectations * 2 ]

    # BEFOREDEF

    @ ($expectations) {
        ! defined $it
        ok "$it isn't defined"
    }

    # DEF

    local  expected_as_defined
    my@ expected=( foo )
    my% expected_for=( testing 'foo' )

    # AFTERDEF

    @ ($expectations) {
        defined $it
        ok "$it is defined"
    }

    # STILL

    @ ($still_undefined) {
        ! defined $it
        ok "$it remains undefined"
    }

    # MULTIP : multiple params
    defined $expectations
    ok "test all defined together"
    ! defined $expectations $still_undefined
    ok "test all together with undefined values at the end"
    ! defined $still_undefined $expectations
    ok "test all together with undefined values at the begining"


}

TAP/prove helpers_are_working
