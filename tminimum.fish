function tminimum::operation_list -S
    if test -z $TMUX
        tmux list-sessions 2>/dev/null | while read line
            switch $line
                case '*attached*'
                    echo (set_color $green; echo "attach"; set_color normal; echo "==> [ $line ]")
                case '*'
                    echo (set_color $green; echo "attach"; set_color normal; echo "==> ["; set_color $green; echo "$line"; set_color normal; echo "]")
            end
        end
        echo (set_color $green; echo "attach"; set_color normal; echo "==> ["; set_color $blue; echo "new session"; set_color normal; echo "]")
    else
        tmux list-windows | sed "/active/d" | while read line
            echo (set_color $cyan; echo "switch"; set_color normal; echo "==> [ "(echo $line | awk '{print $1 " " $2 " " $3 " " $4}')" ]")
        end
        echo (set_color $cyan; echo "switch"; set_color normal; echo "==> ["; set_color $blue; echo "new window"; set_color normal; echo "]")
        echo "detach"
        if [ (tmux display-message -p '#{session_windows}') -gt 1 ]
            echo (set_color $red; echo "kill windows")
        end
    end
    tmux has-session 2>/dev/null;
    and echo (set_color $red; echo "kill sessions")
end


function tminimum::kill_session -S
    set -l answer (tminimum::kill_session_list | eval $multi_filter)
    switch $answer
        case '*kill*Server*'
            tmux kill-server
            tminimum
        case '*kill*windows*'
            echo $answer | while read session
                tmux kill-session -t (echo $session | awk '{print $4}' | sed "s/://g")
            end
        case 'back'
            tminimum
    end
end


function tminimum::kill_session_list -S
    tmux list-sessions 2>/dev/null | while read line
        switch $line
            case '*attached*'
                echo (set_color $red; echo "kill"; set_color normal; echo "==> ["; set_color $green; echo $line; set_color normal; echo "]")
            case '*'
                echo (set_color $red; echo "kill"; set_color normal; echo "==> [ $line ]")
        end
    end
    [ (tmux list-sessions 2>/dev/null | grep -c '') = 1 ];
    or echo (set_color $red; echo "kill"; set_color normal; echo "==> ["; set_color $red; echo "Server"; set_color normal; echo "]")
    echo (set_color $blue; echo "back")
end


function tminimum::kill_window -S
    if [ (tmux display-message -p '#{session_windows}') > 1 ]
        set -l answer (tminimum::kill_window_list | eval $multi_filter)
        string match '*kill*' $answer;
        and echo $answer | while read window
            tmux kill-window -t (echo $window | awk '{print $4}' | sed "s/://g")
        end
        string match 'back' $answer;
        and tminimum
    else
        tminimum
    end
end


function tminimum::kill_window_list -S
    tmux list-windows | while read line
        set line (echo $line | awk '{print $1 " " $2 " " $3 " " $4 " " $5 " " $9}')
        # string match '*active*' $line;
        # and set line $line
        echo (set_color $red; echo "kill"; set_color normal; echo "==> [ $line ]")
    end
    echo (set_color $blue; echo "back")
end


function tminimum
    #set color
    set -l red 'ce000f' '--bold'
    set -l blue '48b4fb' '--bold'
    set -l green 'addc10'
    set -l orange 'f6b117'
    set -l cyan '00d7d7'

    set -l filter_method 'fzf'
    set -l filter '$filter_method --ansi --prompt="tminimum >"'
    set -l multi_filter '$filter_method --multi --ansi --prompt="tminimum >"'    
    set -l answer (tminimum::operation_list | eval $filter)
    switch $answer
        case '*new session*'
            tmux new-session
        case '*new window*'
            tmux new-window
        case '*switch*'
            tmux select-window -t (echo "$answer" | awk '{print $4}' | sed "s/://g")
        case '*attach*'
            tmux attach -t (echo "$answer" | awk '{print $4}' | sed 's/://')
        case 'detach'
            tmux detach-client
        case 'kill sessions'
            tminimum::kill_session
        case 'kill windows'
            tminimum::kill_window
    end
end