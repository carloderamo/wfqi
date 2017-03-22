function [gp] = WFQIProdInt(sars, gamma, stateDim, nIterations, ...
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
%                fprintf('Trapz: %f\n', W(j))
%
%                 N = 1e3;
%                 E2 = zeros(N,1);
%                 nsam = 1e3;
% 
%                 points = (-5 + 10 * rand(nsam * N, 1)) / 5;
%                 gpInput = repmat(nextStates(j, :), nsam * N, 1);
%                 gpInput = [gpInput, points];
%                 [means, sigmas] = gp.predict(gpInput);
% 
%                 if ~noisyTest
%                     sigmas = sqrt(sigmas.^2 - gp.Sigma^2);
%                 end;
%                 for z=1:nsam:size(means, 1)
%                     [~, idx] = max(normrnd(means(z:z + nsam - 1, :), sigmas(z:z + nsam - 1, :)));
%                     E2(round(z / nsam) + 1) = means(idx);
%                 end
%                 W(j) = mean(E2);
%                
%                 fprintf('sampl1: %f\n', W(j))
% 
%                 tic
%                 nsam = 1e3;
%                 points = linspace(-5, 5, nsam) / 5;
%                 gpInput = repmat(nextStates(j, :), nsam, 1);
%                 gpInput = [gpInput, points'];
%                 [means, sigmas] = gp.predict(gpInput);
%                 if ~noisyTest
%                     sigmas = sqrt(sigmas.^2 - gp.Sigma^2);
%                 end;
% 
%                 N = 1e3;
%                 [~, idx] = max(normrnd(repmat(means, 1, N), repmat(sigmas, 1, N)));
%                 E3 = means(idx);
%                 W(j) = mean(E3);
%                 toc
%                 fprintf('Sampl2: %f\n', W(j))
%                 if i == 6
%                    answer = input('Valuta gp: '); 
%                     if strcmp(answer, 'yes')
%                         figure;
%                         hold
%                         plot(linspace(-5, 5, nsam), means - sigmas, 'r');
%                         plot(linspace(-5, 5, nsam), means);
%                         plot(linspace(-5, 5, nsam), means + sigmas, 'r');
%                     end
%                 end               
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
