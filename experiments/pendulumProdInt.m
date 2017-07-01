clear all;

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

horizon = 100;
rewardNoiseSigma = 0;

nBins = 1e2;
J = zeros(nExperiments, 1);

for nEpisodes = [5, 10, 25, 37, 50, 62, 75, 87, 100]
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
        gp = WFQIProdInt(sars, gamma, stateDim, nIterations, ...
                         lengthScale, signalSigma, noiseSigma, ...
                         noisyTest, nTrapz, integralLimit, ...
                         lowerAction, upperAction, false, 0, 0);
        J(e + 1) = evaluatePolicy(gp, nBins, horizon);
    end

    savePath = strcat('../results/', nEpisodesStr, 'ProdInt.txt');
    save(strcat(savePath), 'J', '-ascii');
end
