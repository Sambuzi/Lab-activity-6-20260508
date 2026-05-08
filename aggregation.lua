--aggregation.lua

--parametri presi da l'arena che ci ha dato il prof

S = 0.01
W = 0.10
ALPHA = 0.10
BETA = 0.05
PSmax = 0.99
PWmin = 0.005
MAXRANGE = 30 

--parametri per la simulazione

SPEED = 10
TURN_SPEED = 5
OBS_THRESHOLD = 0.10

--STATO DEL ROBOT

WALKING = 1
STOPPED = 0
CURRENT_STATE = WALKING
TURN_DIRECTION = 1
TURN_STEPS= 0

function init()
    CURRENT_STATE = WALKING
    TURN_STEPS = 0
    robot.range_and_bearing.set_data(1, 0)
    robot.leds.set_all_colors("green")
end

function reset()
    init()
end

function step()
    local N = CountStoppedRobots()

    if CURRENT_STATE == WALKING then
        robot.range_and_bearing.set_data(1, 0)
        robot.leds.set_all_colors("green")

        local Ps = math.min(PSmax, S + ALPHA *N)
        if bernoulli(Ps) then
            CURRENT_STATE = STOPPED
            Stop()
        else
            RandomWalk()
        end
    elseif CURRENT_STATE == STOPPED then
        robot.range_and_bearing.set_data(1, 1)
        robot.leds.set_all_colors("red")

        local Pw = math.max(PWmin, W - BETA *N)
        if bernoulli(Pw) then
            CURRENT_STATE = WALKING
            RandomWalk()
        else
            Stop()
        end
    end
end

function destroy()
end

function bernoulli(p)
    local t = robot.random.uniform()
    return t <= p
end

function CountStoppedRobots()
    local num_robots = 0
    for i =1, #robot.range_and_bearing do
        if robot.range_and_bearing[i].range < MAXRANGE then
            if robot.range_and_bearing[i].data[1] == 1 then
                num_robots = num_robots + 1
            end
        end
    end
    return num_robots
end

function Stop()
    robot.wheels.set_velocity(0, 0)
end

function RandomWalk()
    local max_value = 0
    local max_angle = 0

    for i = 1, #robot.proximity do
        if robot.proximity[i].value > max_value then
            max_value = robot.proximity[i].value
            max_angle = robot.proximity[i].angle
        end
    end
    if max_value > OBS_THRESHOLD then
      -- Obstacle on left side -> turn right; obstacle on right side -> turn left
      if max_angle > 0 then
         robot.wheels.set_velocity(TURN_SPEED, -TURN_SPEED)
      else
         robot.wheels.set_velocity(-TURN_SPEED, TURN_SPEED)
      end
      TURN_STEPS = 0
      return
   end

   -- Random walk: sometimes choose a short turn, otherwise go straight
   if TURN_STEPS > 0 then
      robot.wheels.set_velocity(-TURN_DIRECTION * TURN_SPEED,
                                TURN_DIRECTION * TURN_SPEED)
      TURN_STEPS = TURN_STEPS - 1
   else
      if robot.random.uniform() < 0.05 then
         TURN_STEPS = robot.random.uniform(5, 20)
         if robot.random.uniform() < 0.5 then
            TURN_DIRECTION = -1
         else
            TURN_DIRECTION = 1
         end
      else
         robot.wheels.set_velocity(SPEED, SPEED)
      end
   end

end



