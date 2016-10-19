function [reward, nextState] = step(state, torque, rewardNoiseSigma)

    stepTime = 0.01;
    maxVelocity = pi / 4 / stepTime;
    mass = 1.0;
    l = 1.0;
    g = 9.8;

    theta = state(1);
    velocity = state(2);
    
    thetaAcc = -stepTime * velocity + mass * g * l * sin(theta) + torque;
    velocity = velocity + thetaAcc;
    if velocity > maxVelocity
        velocity = maxVelocity;
    elseif velocity < -maxVelocity
        velocity = -maxVelocity;
    end
    theta = theta + velocity * stepTime;

    if theta >= pi
        theta = theta - 2.0 * pi;
    elseif theta < -pi
        theta = theta + 2.0 * pi;
    end

    nextState = [theta, velocity];

    reward = cos(nextState(1)) + normrnd(0, rewardNoiseSigma);
end