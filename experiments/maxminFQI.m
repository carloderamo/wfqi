function [gps] = maxminFQI(sars, gamma, stateDim, nActions, nIterations, lengthScale, signalSigma, noiseSigma, shuffle)
    
    gps = cell(2, nActions);
      
    actionIdx = stateDim + 1;
    rewardIdx = stateDim + 2;
    nextStatesIdx = stateDim + 3:2 * stateDim + 2;
    absorbingStateIdx = 2 * stateDim + 3;
    
    if shuffle
        idxs = randperm(size(sars, 1));
    else
        idxs = linspace(1, size(sars, 1), size(sars, 1));
    end
    
    fprintf('Iteration: %d\n', 1);
    
    % fit gps on different subsets of data
    for a = 1:nActions
        halfSars = sars(idxs(1:floor(length(idxs) / 2)), :);
        inputs = halfSars(halfSars(:, actionIdx) == a - 1, 1:stateDim);
        outputs = halfSars(halfSars(:, actionIdx) == a - 1, rewardIdx);
        gps{1, a} = fitrgp(inputs, outputs, ...
                    'KernelFunction', 'ardsquaredexponential', ...
                    'KernelParameters', [lengthScale; signalSigma], ...
                    'Sigma', noiseSigma, ...
                    'FitMethod', 'exact', ...
                    'PredictMethod', 'exact');
                
        halfSars = sars(idxs(floor(length(idxs) / 2) + 1:end), :);
        inputs = halfSars(halfSars(:, actionIdx) == a - 1, 1:stateDim);
        outputs = halfSars(halfSars(:, actionIdx) == a - 1, rewardIdx);
        gps{2, a} = fitrgp(inputs, outputs, ...
                    'KernelFunction', 'ardsquaredexponential', ...
                    'KernelParameters', [lengthScale; signalSigma], ...
                    'Sigma', noiseSigma, ...
                    'FitMethod', 'exact', ...
                    'PredictMethod', 'exact');
    end

    inputs = cell(2, nActions);
    outputs = cell(2, nActions);
    for i = 2:nIterations
        fprintf('Iteration: %d\n', i);
        
        if shuffle
            idxs = randperm(length(idxs));
        end
        
        halfSarsIdxs = {idxs(1:floor(length(idxs) / 2)), idxs(floor(length(idxs) / 2) + 1:end)};
        for r = 1:2
            for a = 1:nActions
                halfSars = sars(halfSarsIdxs{r}, :);
                inputs{r, a} = halfSars(halfSars(:, actionIdx) == a - 1, 1:stateDim);
                % prediction from first Q function
                Q = zeros(size(inputs{r, a}, 1), nActions);
                for nextA = 1:nActions
                    q1 = gps{r, nextA}.predict(halfSars(halfSars(:, actionIdx) == a - 1, nextStatesIdx));
                    q2 = gps{3 - r, nextA}.predict(halfSars(halfSars(:, actionIdx) == a - 1, nextStatesIdx));
                    Q(:, nextA) = min(q1,q2);
                    Q(:, nextA) = Q(:, nextA) .* (1 - halfSars(halfSars(:, actionIdx) == a - 1, absorbingStateIdx));
                end
                   
                outputs{r, a} = halfSars(halfSars(:, actionIdx) == a - 1, rewardIdx) + gamma * max(Q, [], 2);
            end
        end
        
        for r = 1:2
            for a = 1:nActions
                gps{r, a} = fitrgp(inputs{r, a}, outputs{r, a}, ...
                    'KernelFunction', 'ardsquaredexponential', ...
                    'KernelParameters', [lengthScale; signalSigma], ...
                    'Sigma', noiseSigma, ...
                    'FitMethod', 'exact', ...
                    'PredictMethod', 'exact');
            end
        end
    end
end
