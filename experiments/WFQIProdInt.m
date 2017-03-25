function [gp, t] = WFQIProdInt(sars, gamma, stateDim, nIterations, ...
                            lengthScale, signalSigma, noiseSigma, ...
                            noisyTest, nTrapz, integralLimit, ...
                            lowerAction, upperAction, approximated, nPoints, nSamples)
        
    actionIdx = stateDim + 1;
    rewardIdx = stateDim + 2;
    nextStatesIdx = stateDim + 3:2 * stateDim + 2;
    absorbingStateIdx = 2 * stateDim + 3;
    
    fprintf('Iteration: %d\n', 1);

    inputs = sars(:, 1:actionIdx);
    nextStates = sars(:, nextStatesIdx);
    outputs = sars(:, rewardIdx);
    
    gp = fitrgp(inputs, outputs, ...
                'KernelFunction', 'ardsquaredexponential', ...
                'KernelParameters', [lengthScale; signalSigma], ...
                'Sigma', noiseSigma, ...
                'FitMethod', 'fic', ...
                'PredictMethod', 'fic');

    for i = 2:nIterations
        fprintf('Iteration: %d\n', i);
        W = zeros(size(sars, 1), 1);
        t = zeros(size(sars, 1), 1);
        for j = 1:length(W)
            if ~approximated
                tic
                % Trapz
                xs = linspace(-integralLimit, integralLimit, nTrapz);
                % Action is normalized by 5 (WARNING: ONLY FOR AAAI2017 PENDULUM)
                xa = linspace(lowerAction, upperAction, nTrapz) / 5;

                gpInput = repmat(nextStates(j, :), length(xa), 1);
                gpInput = [gpInput, xa'];
                [means, sigma] = gp.predict(gpInput);
                if ~noisyTest
                    sigma = sqrt(sigma.^2 - gp.Sigma^2);
                end;

                pdfs = normpdf(repmat(xs', 1, length(means)), ...
                               repmat(means', length(xs), 1), ...
                               repmat(sigma', length(xs), 1));
                cdfs = normcdf(repmat(xs', 1, length(means)), ...
                               repmat(means', length(xs), 1), ...
                               repmat(sigma', length(xs), 1));

                cdfs(cdfs < 1e-6) = 1e-6;
                productInt = exp(trapz(xa, log(cdfs')));
                W(j) = trapz(xs, trapz(xa, repmat(means, ...
                                                  1, ...
                                                  size(pdfs, 2)) .* ...
                                                  pdfs' ./ cdfs') .* ...
                                                  productInt);
                t(j) = toc;
            else
                % Sampling
                tic
                E = zeros(nPoints, 1);
                minZ = -1;
                maxZ = 1;

                y =  2 * maxZ * rand(nPoints, 1) - maxZ;

                gpInput = [repmat(nextStates(j, :), nPoints, 1), y];
                [meanY, sigmaY] = gp.predict(gpInput);

                samples = normrnd(repmat(meanY, 1, nSamples), repmat(sigmaY, 1, nSamples));

                zIdx = 1;
                yIdx = 1;
                zSample = 1;
                for n = 1:nPoints - 1
                    yIdx = yIdx + 1;
                    if(samples(yIdx, 1) > samples(zIdx, zSample))
                       zIdx = yIdx;
                       zSample = 1;
                    else
                        zSample = mod(zSample, nSamples) + 1;
                    end
                    E(n) = meanY(zIdx);
                end
                W(j) = mean(E);
                t(j) = toc;
            end
        end

        W = W .* (1 - sars(:, absorbingStateIdx));
        outputs = sars(:, rewardIdx) + gamma * W;
    
        gp = fitrgp(inputs, outputs, ...
                'KernelFunction', 'ardsquaredexponential', ...
                'KernelParameters', [lengthScale; signalSigma], ...
                'Sigma', noiseSigma, ...
                'FitMethod', 'fic', ...
                'PredictMethod', 'fic');
    end
end
