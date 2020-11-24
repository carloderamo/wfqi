clear all;
clc;
close all;
type = './results/Discrete';
listing = dir(type);

data = [];

for i = 1:length(listing)
    name = listing(i).name;
    if isdir([type, '/', name]) && length(name) > 8 && ...
            strcmp(name(end-7:end), 'Episodes')
        fprintf('processing %s\n', name);
        nbEpisodes = str2num(name(1:end-8));
        R = dlmread([type, '/', name, '/results.txt']);
        avg = mean(R);
        err = std(R) / sqrt(size(R,1))*2;
        data = [data; nbEpisodes, avg, err];
    else
        fprintf('omitted %s\n', name);
    end
end

%%
[~, I] = sort(data(:,1));
data = data(I,:);

algs = {'FQI', 'Double FQI', 'Weighted FQI'};
nalgs = length(algs);


%%
close all;
figure(1);
hold on;
symb = {'o--','d-', '*-'}
%colors_ = {[0.00000,0.44700,0.74100], [0.46600,0.67400,0.18800], [0.85000,0.32500,0.09800]};
colors_ = {[0.92900,0.69400,0.12500], [0.63500,0.07800,0.18400], [0.46600,0.67400,0.18800]};
for i = 1:nalgs
    %     plot(data(:,1), data(:,i+1));
    H = shadedErrorBar(data(:,1), data(:,i+1), data(:,i+1+nalgs), {symb{i},...
        'linewidth', 1.4, 'color', colors_{i}, 'MarkerFaceColor', colors_{i}, 'MarkerSize',4}, 0.5);
    P{i} = H.mainLine;
end
legend([P{:}], algs{:}, 'Location', 'southeast')
set(gca, 'XTick', data(:,1));
xlabel('Number of episodes');
ylabel('Average reward');
grid on;
hold off;

%%
% figure;
% hold on;
% 
% colors_ = {'g','y','b'}
% 
% for i = 1:nalgs
%     x = data(:,1);
%     y = data(:,i+1);
%     dy = data(:,i+1+nalgs);
%     fill([x;flipud(x)], [y-dy;flipud(y+dy)], colors_{i}, 'linestyle', 'none');
%     alpha(.5);
%     plot(x,y, 'o-', 'color', colors_{i}, 'linewidth', 2);
% end
% legend('', 'fqi', '', 'wfqi', '', 'dfqi');
% 
% hold off;
