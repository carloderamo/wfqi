clear all;
rng('shuffle');

% Algorithm
gamma = 0.9;
stateDim = 2;
nActions = 11;
nIterations = 10;
lengthScale = [0.5 0.5]';
signalSigma = 1;
noiseSigma = 1;
nExperiments = 100;
algorithms = {'fqi', 'dfqi', 'wfqi','maxminfqi'};

horizon = 100;
rewardNoiseSigma = 0;

for nEpisodes = [5, 10, 25, 37, 50, 62, 75, 87, 100]
    nEpisodesStr = strcat(int2str(nEpisodes), 'Episodes');

    J = zeros(nExperiments, length(algorithms));

    parfor e = 0:nExperiments - 1
        fprintf('Experiment: %d\n', e + 1);
        
        % Make sars dataset
        sars = collectDataset(rewardNoiseSigma, nEpisodes, horizon, nActions);
        
        for i = 1:length(algorithms)
            algorithm = char(algorithms(i));

            if strcmp(algorithm, 'fqi')
                % Fitted Q-Iteration
                gps = FQI(sars, gamma, stateDim, nActions, nIterations, lengthScale, signalSigma, noiseSigma);
                
                fqiJ = evaluatePolicy(gps, nActions, horizon);
            elseif strcmp(algorithm, 'maxminfqi')
                shuffle = false;
                gps = maxminFQI(sars, gamma, stateDim, nActions, nIterations, lengthScale, signalSigma, noiseSigma, shuffle);
                
                maxminFqiJ = evaluatePolicy(gps, nActions, horizon);
            elseif strcmp(algorithm, 'dfqi')
                % Double Fitted Q-Iteration
                shuffle = false;
                gps = doubleFQI(sars, gamma, stateDim, nActions, nIterations, lengthScale, signalSigma, noiseSigma, shuffle);
                
                dFqiJ = evaluatePolicy(gps, nActions, horizon);
            elseif strcmp(algorithm, 'wfqi')
                % W-Fitted Q-Iteration
                noisyTest = false;
                nSamples = 500;
                gps = WFQI(sars, gamma, stateDim, nActions, nIterations, lengthScale, signalSigma, noiseSigma, noisyTest, nSamples);
                
                wFqiJ = evaluatePolicy(gps, nActions, horizon);
            end
        end
        
        J(e + 1, :) = [fqiJ, dFqiJ, maxminFqiJ, wFqiJ];
    end

    savePath = strcat('./results/', nEpisodesStr, 'Discrete.txt');
    save(strcat(savePath), 'J', '-ascii');
end
