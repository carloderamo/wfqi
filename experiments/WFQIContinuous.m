function [gp] = WFQIContinuous(sars, gamma, stateDim, nActions, nIterations, lengthScale, signalSigma, noiseSigma, noisyTest, nSamples)
    
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
        
        inputs = sars(:, 1:actionIdx);

        Q = zeros(size(inputs, 1), nActions);
        sigmaQ = zeros(size(inputs, 1), nActions);
        samples = zeros(size(inputs, 1), nSamples, nActions);
        for nextA = 1:nActions
            % Action is normalized by 5 (WARNING: ONLY FOR AAAI2017 PENDULUM)
            [Q(:, nextA), sigmaQ(:, nextA)] = gp.predict([nextStates, repmat(actions(nextA) / 5, size(nextStates, 1), 1)]);

            if ~noisyTest
                sigmaQ(:, nextA) = sqrt(sigmaQ(:, nextA).^2 - gp.Sigma^2);
            end;

            %fact = gps{nextA}.Alpha * gps{nextA}.Y' * pinv(gps{nextA}.Y * gps{nextA}.Y');

            %testInputs = sars(sars(:, actionIdx) == a - 1, nextStatesIdx);
            %ess = zeros(1, size(testInputs, 1));
            %for j = 1:size(testInputs, 1)
            %    x1 = repmat(testInputs(j, :), size(gps{nextA}.ActiveSetVectors, 1), 1);
            %    x2 = gps{nextA}.ActiveSetVectors;
            %    covVec = (x1 - x2).^2 * lengthScale.^-2;
            %    covVec = signalSigma^2 * exp(-0.5 * covVec);
            %    w = covVec' * fact;
            %    ess(j) = norm(w, 1) / norm(w);
            %end

            %ess(ess > 1) = 1;
            %sigmaQ(:, nextA) = sigmaQ(:, nextA) ./ ess';
            samples(:, :, nextA) = repmat(Q(:, nextA), 1, nSamples) + repmat(sigmaQ(:, nextA), 1, nSamples) .* ...
                        randn(size(inputs, 1), nSamples);
        end

        [~, maxIdxs] = max(samples, [], 3);

        occCount = zeros(size(inputs, 1), nActions);
        [occ, val] = hist(maxIdxs', unique(maxIdxs));
        occ = occ';

        for j = 1:size(occCount, 1)
            currentOcc = occ(j, :);
            occCount(j, val(currentOcc > 0)) = currentOcc(currentOcc > 0);
        end

        probs = occCount / nSamples;

        W = sum(probs .* Q, 2);

        W = W .* (1 - sars(:, absorbingStateIdx));

        outputs = rewards + gamma * W;
        
        gp = fitrgp(inputs, outputs, ...
                    'KernelFunction', 'ardsquaredexponential', ...
                    'KernelParameters', [lengthScale; signalSigma], ...
                    'Sigma', noiseSigma, ...
                    'FitMethod', 'fic', ...
                    'PredictMethod', 'fic');
    end
end
