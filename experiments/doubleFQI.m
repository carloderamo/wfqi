function [gps] = doubleFQI(sars, gamma, stateDim, nActions, nIterations, lengthScale, signalSigma, noiseSigma, shuffle)
    
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

                Q = zeros(size(inputs{r, a}, 1), nActions);
                for nextA = 1:nActions
                    Q(:, nextA) = gps{r, nextA}.predict(halfSars(halfSars(:, actionIdx) == a - 1, nextStatesIdx));
                end

                otherQ = zeros(size(inputs{r, a}, 1), 1);
                currentDataIdx = halfSars(:, actionIdx) == a - 1;
                currentDataIdx = linspace(1, length(currentDataIdx), length(currentDataIdx)) .* currentDataIdx';
                currentDataIdx = currentDataIdx(currentDataIdx > 0);
                
                for j = 1:length(otherQ)
                    maxActionsIdxs = find(Q(j, :) == max(Q(j, :)));
                    selectedMaxIdx = datasample(maxActionsIdxs, 1);
                    otherQ(j) = gps{3 - r, selectedMaxIdx}.predict(halfSars(currentDataIdx(j), nextStatesIdx));
                    
                    otherQ(j) = otherQ(j) * (1 - halfSars(currentDataIdx(j), absorbingStateIdx));
                end

                outputs{r, a} = halfSars(halfSars(:, actionIdx) == a - 1, rewardIdx) + gamma * otherQ;
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
