clear all;
rng('shuffle');

% Algorithm
gamma = 0.9;
stateDim = 2;
nActions = 100;
nIterations = 10;
lengthScale = [0.5 0.5 0.5]';
signalSigma = 1;
noiseSigma = 1;
nExperiments = 10;
algorithms = {'fqi', 'dfqi', 'wfqi'};

nEpisodes = 5;
horizon = 100;
rewardNoiseSigma = 0;

nEpisodesStr = strcat(int2str(nEpisodes), 'Episodes');

J = zeros(nExperiments, length(algorithms));

parfor e = 0:nExperiments - 1
    fprintf('Experiment: %d\n', e + 1);
    
    % Make sars dataset
    sars = collectDataset(rewardNoiseSigma, nEpisodes, horizon, 0);
    
    for i = 1:length(algorithms)
        algorithm = char(algorithms(i));

        if strcmp(algorithm, 'fqi')
            % Fitted Q-Iteration
            gp = FQIContinuous(sars, gamma, stateDim, nActions, nIterations, lengthScale, signalSigma, noiseSigma);
            
            fqiJ = evaluatePolicy(gp, nActions, horizon);
        elseif strcmp(algorithm, 'dfqi')
            % Double Fitted Q-Iteration
            shuffle = false;
            gp = doubleFQIContinuous(sars, gamma, stateDim, nActions, nIterations, lengthScale, signalSigma, noiseSigma, shuffle);
            
            dFqiJ = evaluatePolicy(gp, nActions, horizon);
        elseif strcmp(algorithm, 'wfqi')
            % W-Fitted Q-Iteration
            noisyTest = false;
            nSamples = 500;
            gp = WFQIContinuous(sars, gamma, stateDim, nActions, nIterations, lengthScale, signalSigma, noiseSigma, noisyTest, nSamples);
            
            wFqiJ = evaluatePolicy(gp, nActions, horizon);
        end
    end
    
    J(e + 1, :) = [fqiJ, dFqiJ, wFqiJ];
end

savePath = strcat('../results/', nEpisodesStr, 'Continuous.txt');
save(strcat(savePath, 'results.txt'), 'J', '-ascii');
