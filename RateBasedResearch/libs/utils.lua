function Round(num)
    if math.abs(num) > 2 ^ 52 then
        return num
    end
    return num < 0 and num - 2 ^ 52 + 2 ^ 52 or num + 2 ^ 52 - 2 ^ 52
end

function RoundAtPoint(exact, quantum)
    return Round(exact / quantum) * quantum
end

function CalDecPoint(value)
    local i = 0
    while value < 1 and i < 32 do
        i = i + 1
        value = value * 10
    end
    return i
end

function RoundAtPointOffset(exact, offset)
    return RoundAtPoint(exact, 1 / (10 ^ (CalDecPoint(exact) + offset)))
end
