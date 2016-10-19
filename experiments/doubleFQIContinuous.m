function [gps] = doubleFQIContinuous(sars, gamma, stateDim, nActions, nIterations, lengthScale, signalSigma, noiseSigma, shuffle)
    
    gps = cell(2, 1);
    
    actionIdx = stateDim + 1;
    rewardIdx = stateDim + 2;
    nextStatesIdx = stateDim + 3:2 * stateDim + 2;
    absorbingStateIdx = 2 * stateDim + 3;
    
    fprintf('Iteration: %d\n', 1);
    
    if shuffle
        idxs = randperm(size(sars, 1));
    else
        idxs = linspace(1, size(sars, 1), size(sars, 1));
    end
    
    halfSars = sars(idxs(1:floor(length(idxs) / 2)), :);
    inputs = halfSars(:, 1:actionIdx);
    outputs = halfSars(:, rewardIdx);
    gps{1} = fitrgp(inputs, outputs, ...
                    'KernelFunction', 'ardsquaredexponential', ...
                    'KernelParameters', [lengthScale; signalSigma], ...
                    'Sigma', noiseSigma, ...
                    'FitMethod', 'fic', ...
                    'PredictMethod', 'fic');

    halfSars = sars(idxs(floor(length(idxs) / 2) + 1:end), :);
    inputs = halfSars(:, 1:actionIdx);
    outputs = halfSars(:, rewardIdx);
    gps{2} = fitrgp(inputs, outputs, ...
                    'KernelFunction', 'ardsquaredexponential', ...
                    'KernelParameters', [lengthScale; signalSigma], ...
                    'Sigma', noiseSigma, ...
                    'FitMethod', 'fic', ...
                    'PredictMethod', 'fic');
                
    actions = linspace(-5, 5, nActions);

    inputs = cell(2, 1);
    outputs = cell(2, 1);
    for i = 2:nIterations
        fprintf('Iteration: %d\n', i);
        
        if shuffle
            idxs = randperm(length(idxs));
        end
        
        halfSarsIdxs = {idxs(1:floor(length(idxs) / 2)), idxs(floor(length(idxs) / 2) + 1:end)};
        for r = 1:2
            halfSars = sars(halfSarsIdxs{r}, :);
            inputs{r} = halfSars(:, 1:actionIdx);

            Q = zeros(size(inputs{r}, 1), nActions);
            for nextA = 1:nActions
                % Action is normalized by 5 (WARNING: ONLY FOR AAAI2017 PENDULUM)
                Q(:, nextA) = gps{r}.predict([halfSars(:, nextStatesIdx), repmat(actions(nextA) / 5, size(halfSars, 1), 1)]);
            end

            otherQ = zeros(size(inputs{r}, 1), 1);

            for j = 1:length(otherQ)
                maxActionsIdxs = find(Q(j, :) == max(Q(j, :)));
                selectedMaxIdx = datasample(maxActionsIdxs, 1);
                % Action is normalized by 5 (WARNING: ONLY FOR AAAI2017 PENDULUM)
                otherQ(j) = gps{3 - r}.predict([halfSars(j, nextStatesIdx), actions(selectedMaxIdx) / 5]);

                otherQ(j) = otherQ(j) * (1 - halfSars(j, absorbingStateIdx));
            end

            outputs{r} = halfSars(:, rewardIdx) + gamma * otherQ;
        end
        
        for r = 1:2
            gps{r} = fitrgp(inputs{r}, outputs{r}, ...
                'KernelFunction', 'ardsquaredexponential', ...
                'KernelParameters', [lengthScale; signalSigma], ...
                'Sigma', noiseSigma, ...
                'FitMethod', 'fic', ...
                'PredictMethod', 'fic');
        end
    end
end
