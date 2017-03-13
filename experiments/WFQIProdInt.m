function [gp] = WFQIContinuous(sars, gamma, stateDim, nIterations, ...
                                lengthScale, signalSigma, noiseSigma, ...
                                noisyTest, nTrapz, integralLimit, ...
                                lowerAction, upperAction, sampling)
        
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
        for j = 1:length(W)
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
                W(j)
                N = 1e2;
                E2 = zeros(N,1);
                nsam = 1e2;

                points = (-5 + 10 * rand(nsam * N, 1)) / 5;
                gpInput = repmat(nextStates(j, :), nsam * N, 1);
                gpInput = [gpInput, points];
                [means, sigmas] = gp.predict(gpInput);

                if ~noisyTest
                    sigmas = sqrt(sigmas.^2 - gp.Sigma^2);
                end;
                for z=1:nsam:size(means, 1)
                    [~, idx] = max(normrnd(means(z:z + nsam - 1, :), sigmas(z:z + nsam - 1, :)));
                    E2(round(z / nsam) + 1) = means(idx);
                end
                W(j) = mean(E2);
                W(j)
                pause
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
