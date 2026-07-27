function o
    switch $argv[1]
        case "chat"
            open "https://chat.openai.com/?model=gpt-4"
        case "*"
            echo "Unknown website alias. Please use a known alias or add a new one."
    end
end
