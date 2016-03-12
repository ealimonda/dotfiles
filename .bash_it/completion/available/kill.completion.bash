#!bash
#

_kill ()
{
    local cur aux

    COMPREPLY=()
    cur=${COMP_WORDS[COMP_CWORD]}

    COMPREPLY=( $( compgen -W '$( ps -u $USER -o pid )' -- "$cur" ))

    if [ $COMP_TYPE -eq 63 ]; then
        echo ""
        #ps -lu $USER |\
        #    awk -v cur=$cur '{if (index($4,cur)==1 || NR==1)\
        #        print "\033[1m" $4 "\033[0m" "\t" $5 "\t" $14}'
        ps -lu $USER |\
            awk -v cur=$cur '{if (index($4,cur)==1 || NR==1)\
                print "\033[1m" $2 "\033[0m" "\t" $3 "\t" $15}'
    fi

    return 0
}
complete -F _kill kill

