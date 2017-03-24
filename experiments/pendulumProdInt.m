clear all;
% Parse ReLe dataset
initialPath = '/home/shirokuma/Desktop';

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

nEpisodes = 10;
horizon = 100;
rewardNoiseSigma = 0;

nBins = 1e2;
J = zeros(nExperiments, 1);

nEpisodesStr = strcat(int2str(nEpisodes), 'Episodes');

for e = 0:nExperiments - 1
    fprintf('Experiment: %d\n', e + 1);

    % Make sars dataset    
    sars = collectDataset(rewardNoiseSigma, nEpisodes, horizon, nActions);

    % W-Fitted Q-Iteration
    noisyTest = false;

    % Trapz
    nTrapz = 1e3;
    integralLimit = 10;
    [gp, tTrapz] = WFQIProdInt(sars, gamma, stateDim, nIterations, ...
                     lengthScale, signalSigma, noiseSigma, ...
                     noisyTest, nTrapz, integralLimit, ...
                     lowerAction, upperAction, false, 0, 0);
    JTrapz(e + 1) = evaluatePolicy(gp, nBins, horizon);
    
    % Sampling
    nPoints = 1e4;
    nSamples = 100;
    [gp, tSampl] = WFQIProdInt(sars, gamma, stateDim, nIterations, ...
                     lengthScale, signalSigma, noiseSigma, ...
                     noisyTest, nTrapz, integralLimit, ...
                     lowerAction, upperAction, true, nPoints, nSamples);
    JSampl(e + 1) = evaluatePolicy(gp, nBins, horizon);
end

savePath = strcat(initialPath, '/');
save(strcat(savePath, 'results'), 'JTrapz', 'tTrapz', 'JSampl', 'tSampl');