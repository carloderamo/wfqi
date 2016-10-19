function [gps] = WFQI(sars, gamma, stateDim, nActions, nIterations, lengthScale, signalSigma, noiseSigma, noisyTest, nSamples)
    
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
            sigmaQ = zeros(size(inputs{a}, 1), nActions);
            samples = zeros(size(inputs{a}, 1), nSamples, nActions);
            for nextA = 1:nActions
                [Q(:, nextA), sigmaQ(:, nextA)] = gps{nextA}.predict(sars(sars(:, actionIdx) == a - 1, nextStatesIdx));
                
                if ~noisyTest
                    sigmaQ(:, nextA) = sqrt(sigmaQ(:, nextA).^2 - gps{nextA}.Sigma^2);
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
                            randn(size(inputs{a}, 1), nSamples);
            end
            
            [~, maxIdxs] = max(samples, [], 3);
            
            occCount = zeros(size(inputs{a}, 1), nActions);
            [occ, val] = hist(maxIdxs', unique(maxIdxs));
            occ = occ';
            
            for j = 1:size(occCount, 1)
                currentOcc = occ(j, :);
                occCount(j, val(currentOcc > 0)) = currentOcc(currentOcc > 0);
            end
            
            probs = occCount / nSamples;
            
            W = sum(probs .* Q, 2);
            
            W = W .* (1 - sars(sars(:, actionIdx) == a - 1, absorbingStateIdx));

            outputs{a} = sars(sars(:, actionIdx) == a - 1, rewardIdx) + gamma * W;
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
