clear all;
rng('shuffle');
% Parse ReLe dataset
initialPath = '/home/pirotta/AAAI17/Continuous';

% Algorithm
gamma = 0.9;
stateDim = 2;
nActions = 100;
lowerAction = -5;
upperAction = 5;
nIterations = 10;
lengthScale = [0.5 0.5 0.5]';
signalSigma = 1;
noiseSigma = 1;
nExperiments = 10;
algorithms = {'fqi', 'dfqi', 'wfqi', 'pi'};

nEpisodes = 5;
horizon = 100;
rewardNoiseSigma = 0;

nBins = 1e2;
J = zeros(nExperiments, length(algorithms));

nEpisodesStr = strcat(int2str(nEpisodes), 'Episodes');

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
        elseif strcmp(algorithm, 'pi')
	    % W-Fitted Q-Iteration
	    noisyTest = false;
	    nTrapz = 1e3;
	    integralLimit = 10;
	    gp = WFQIProdInt(sars, gamma, stateDim, nIterations, ...
	                     lengthScale, signalSigma, noiseSigma, ...
	                     noisyTest, nTrapz, integralLimit, ...
	                     lowerAction, upperAction);
	
	    wFQIpiJ = evaluatePolicy(gp, nBins, horizon);

        end
    end
    
    J(e + 1, :) = [fqiJ, dFqiJ, wFqiJ, wFQIpiJ];
end

savePath = strcat(initialPath, '/', nEpisodesStr, '/');
mkdir(savePath);
save(strcat(savePath, 'resultsALL.txt'), 'J', '-ascii', '-append');
