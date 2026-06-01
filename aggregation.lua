--AGGREGATION BEHAVIOR
local W = 0.1
local S = 0.01
local PS_MAX = 0.99
local PW_MIN = 0.005
local ALPHA = 0.1
local BETA = 0.05

local MAXRANGE = 30
local MAX_VELOCITY = 15

local PROX_THRESHOLD = 0.1
local RANDOM_TURN_PROBABILITY = 0.05

-- Robot states
local STATE_MOVE = "MOVING"
local STATE_STOPPED = "STOPPED"

function init()
    robot.state = STATE_MOVE
    robot.range_and_bearing.set_data(1, 0)
    robot.leds.set_all_colors("green")
end

function CountRAB()
    local number_robot_sensed = 0
    for i = 1, #robot.range_and_bearing do
        if robot.range_and_bearing[i].range < MAXRANGE 
            and robot.range_and_bearing[i].data[1]==1 then
            number_robot_sensed = number_robot_sensed + 1
        end
    end
    return number_robot_sensed
end

function Bernoulli(p)
    return robot.random.uniform() <= p
end

function ClampVelocity(v)
    return math.max(-MAX_VELOCITY, math.min(MAX_VELOCITY, v))
end

function step()
    local N = CountRAB()

    if robot.state == STATE_MOVE then
        local Ps = math.min(PS_MAX, S + ALPHA * N)
        
        if Bernoulli(Ps) then
            -- Stop the robot
            robot.state = STATE_STOPPED
            robot.range_and_bearing.set_data(1, 1)
            robot.leds.set_all_colors("red")
            robot.wheels.set_velocity(0, 0)
        else
            -- Continue to move randomly
            MoveRandomly()
        end

    elseif robot.state == STATE_STOPPED then
        local Pw = math.max(PW_MIN, W - BETA * N)
        
        if Bernoulli(Pw) then
            -- Start to move
            robot.state = STATE_MOVE
            robot.range_and_bearing.set_data(1, 0)
            robot.leds.set_all_colors("green")
        else
            -- Stay still
            robot.wheels.set_velocity(0, 0)
        end
    end
end

function MoveRandomly()
    local sum_left_sensors = 0
    local sum_right_sensors = 0

    for i=1, 6 do
        sum_left_sensors = sum_left_sensors + robot.proximity[i].value
        sum_right_sensors = sum_right_sensors + robot.proximity[25 - i].value
    end

    if sum_left_sensors > PROX_THRESHOLD or sum_right_sensors > PROX_THRESHOLD then
        local speed_diff = (sum_left_sensors - sum_right_sensors) * 5
        local v_left = ClampVelocity(MAX_VELOCITY + speed_diff)
        local v_right = ClampVelocity(MAX_VELOCITY - speed_diff)
        robot.wheels.set_velocity(v_left, v_right)
    elseif Bernoulli(RANDOM_TURN_PROBABILITY) then
        local turn = (robot.random.uniform() * 2 - 1) * MAX_VELOCITY
        robot.wheels.set_velocity(ClampVelocity(MAX_VELOCITY - turn),
                                  ClampVelocity(MAX_VELOCITY + turn))
    else
        robot.wheels.set_velocity(MAX_VELOCITY, MAX_VELOCITY)
    end
end

function reset()
    init()
end

function destroy()

end
