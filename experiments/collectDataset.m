function [sars] = collectDataset(rewardNoiseSigma, nEpisodes, horizon, nActions)

    sars = zeros(nEpisodes * horizon, 7);
    
    counter = 1;
    for i = 1:nEpisodes
        initialTheta = -pi + 2 * pi * rand;
        state = [initialTheta 0];
        for j = 1:horizon
            if nActions > 0
                action = datasample(linspace(0, 10, 11), 1);
                actions = linspace(-5, 5, 11);
                torque = actions(action + 1);
            else
                torque = -5 + 10 * rand;
                action = torque / 5;
            end
            
            [reward, nextState] = step(state, torque, rewardNoiseSigma);
            sars(counter, 1:2) = state ./ [pi, pi / 4 / 0.01];
            sars(counter, 3) = action;
            sars(counter, 4) = reward;
            sars(counter, 5:6) = nextState ./ [pi, pi / 4 / 0.01];

            state = nextState;

            counter = counter + 1;
        end
    end
end

