clear all;
% Parse ReLe dataset
initialPath = '/home/shirokuma/Desktop/AAAI2017-GP/Continuous';

% Algorithm
gamma = 0.9;
stateDim = 2;
nActions = 0;
lowerAction = -5;
upperAction = 5;
nIterations = 10;
lengthScale = [0.5 0.5 0.5]';
signalSigma = 1;
noiseSigma = 1;
nExperiments = 10;
algorithm = 'wfqi';

nEpisodes = 5;
horizon = 100;
rewardNoiseSigma = 0;

nBins = 1e2;
J = zeros(nExperiments, 1);

nEpisodesStr = strcat(int2str(nEpisodes), 'Episodes');

parfor e = 0:nExperiments - 1
    fprintf('Experiment: %d\n', e + 1);
    
    % Make sars dataset    
    sars = collectDataset(rewardNoiseSigma, nEpisodes, horizon, nActions);

    % W-Fitted Q-Iteration
    noisyTest = false;
    nTrapz = 1e3;
    integralLimit = 10;
    gp = WFQIProdInt(sars, gamma, stateDim, nIterations, ...
                     lengthScale, signalSigma, noiseSigma, ...
                     noisyTest, nTrapz, integralLimit, ...
                     lowerAction, upperAction);

    J(e + 1) = evaluatePolicy(gp, nBins, horizon);
end

savePath = strcat(initialPath, '/', nEpisodesStr,'/');
save(strcat(savePath, 'resultsProdInt.txt'), 'J', '-ascii');
