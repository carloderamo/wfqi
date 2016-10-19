function [gp] = FQIContinuous(sars, gamma, stateDim, nActions, nIterations, lengthScale, signalSigma, noiseSigma, uMax)
    
    actionIdx = stateDim + 1;
    rewardIdx = stateDim + 2;
    nextStatesIdx = stateDim + 3:2 * stateDim + 2;
    absorbingStateIdx = 2 * stateDim + 3;
    
    fprintf('Iteration: %d\n', 1);

    inputs = sars(:, 1:actionIdx);
    nextStates = sars(:, nextStatesIdx);
    rewards = sars(:, rewardIdx);
    outputs = sars(:, rewardIdx);
    
	actions = linspace(-5, 5, nActions);
    
    gp = fitrgp(inputs, outputs, ...
                'KernelFunction', 'ardsquaredexponential', ...
                'KernelParameters', [lengthScale; signalSigma], ...
                'Sigma', noiseSigma, ...
                'FitMethod', 'fic', ...
                'PredictMethod', 'fic');

    for i = 2:nIterations
        fprintf('Iteration: %d\n', i);

        Q = zeros(size(inputs, 1), nActions);
        for nextA = 1:nActions
            % Action is normalized by 5 (WARNING: ONLY FOR AAAI2017 PENDULUM)
            Q(:, nextA) = gp.predict([nextStates, repmat(actions(nextA) / 5, size(nextStates, 1), 1)]);
            Q(:, nextA) = Q(:, nextA) .* (1 - sars(:, absorbingStateIdx));
        end

        outputs = rewards + gamma * max(Q, [], 2);
        
        gp = fitrgp(inputs, outputs, ...
                    'KernelFunction', 'ardsquaredexponential', ...
                    'KernelParameters', [lengthScale; signalSigma], ...
                    'Sigma', noiseSigma, ...
                    'FitMethod', 'fic', ...
                    'PredictMethod', 'fic');
    end
end
