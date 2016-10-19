function [gps] = FQI(sars, gamma, stateDim, nActions, nIterations, lengthScale, signalSigma, noiseSigma)
    
    gps = cell(1, nActions);
    
    actionIdx = stateDim + 1;
    rewardIdx = stateDim + 2;
    nextStatesIdx = stateDim + 3:2 * stateDim + 2;
    absorbingStateIdx = 2 * stateDim + 3;

    fprintf('Iteration: %d\n', 1);
    
    for a = 1:nActions
        inputs = sars(sars(:, actionIdx) == a - 1, 1:stateDim);
        outputs = sars(sars(:, actionIdx) == a - 1, rewardIdx);
        
        gps{a} = fitrgp(inputs, outputs, ...
                    'KernelFunction', 'ardsquaredexponential', ...
                    'KernelParameters', [lengthScale; signalSigma], ...
                    'Sigma', noiseSigma, ...
                    'FitMethod', 'exact', ...
                    'PredictMethod', 'exact');
    end

    inputs = cell(1, nActions);
    outputs = cell(1, nActions);
    for i = 2:nIterations
        fprintf('Iteration: %d\n', i);
        
        for a = 1:nActions
            inputs{a} = sars(sars(:, actionIdx) == a - 1, 1:stateDim);
            
            Q = zeros(size(inputs{a}, 1), nActions);
            for nextA = 1:nActions
                Q(:, nextA) = gps{nextA}.predict(sars(sars(:, actionIdx) == a - 1, nextStatesIdx));
                Q(:, nextA) = Q(:, nextA) .* (1 - sars(sars(:, actionIdx) == a - 1, absorbingStateIdx));
            end

            outputs{a} = sars(sars(:, actionIdx) == a - 1, rewardIdx) + gamma * max(Q, [], 2);
        end
        
        for a = 1:nActions
            gps{a} = fitrgp(inputs{a}, outputs{a}, ...
                'KernelFunction', 'ardsquaredexponential', ...
                'KernelParameters', [lengthScale; signalSigma], ...
                'Sigma', noiseSigma, ...
                'FitMethod', 'exact', ...
                'PredictMethod', 'exact');
        end
    end
end
