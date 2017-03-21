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
nExperiments = 5;
algorithm = 'wfqi';

nEpisodes = 100;
horizon = 100;
rewardNoiseSigma = 0;

nBins = 1e2;
Jt = zeros(nExperiments, 1);
Js = zeros(nExperiments, 1);

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
    sampling = false;
    tic
    gp = WFQIProdInt(sars, gamma, stateDim, nIterations, ...
                     lengthScale, signalSigma, noiseSigma, ...
                     noisyTest, nTrapz, integralLimit, ...
                     lowerAction, upperAction, sampling);
    toc
    
    tic
    Jt(e + 1) = evaluatePolicy(gp, nBins, horizon);
    toc
    
    % Sampling
    %sampling = true;
    %gp = WFQIProdInt(sars, gamma, stateDim, nIterations, ...
    %                 lengthScale, signalSigma, noiseSigma, ...
    %                 noisyTest, nTrapz, integralLimit, ...
    %                 lowerAction, upperAction, sampling);
    %Js(e + 1) = evaluatePolicy(gp, nBins, horizon);
end

savePath = strcat(initialPath, '/', nEpisodesStr,'/');
save(strcat(savePath, 'resultsProdIntTrapz.txt'), 'Jt', '-ascii');
%save(strcat(savePath, 'resultsProdIntSampling.txt'), 'Js', '-ascii');
