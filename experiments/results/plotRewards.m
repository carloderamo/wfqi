type = 'Discrete';

if strcmp('Discrete', type)
    path1 = strcat(type, '/25Episodes/');
    path2 = strcat(type, '/50Episodes/');
    path3 = strcat(type, '/75Episodes/');
    path4 = strcat(type, '/100Episodes/');

    fqi1 = dlmread(strcat(path1, 'results.txt'));
    fqi2 = dlmread(strcat(path2, 'results.txt'));
    fqi3 = dlmread(strcat(path3, 'results.txt'));
    fqi4 = dlmread(strcat(path4, 'results.txt'));

    nExperiments = size(fqi1, 1);

    mF1 = mean(fqi1(:, 1));
    mD1 = mean(fqi1(:, 2));
    mW1 = mean(fqi1(:, 3));
    eF1 = 2 * std(fqi1(:, 1), 0)' / sqrt(nExperiments);
    eD1 = 2 * std(fqi1(:, 2), 0)' / sqrt(nExperiments);
    eW1 = 2 * std(fqi1(:, 3), 0)' / sqrt(nExperiments);

    mF2 = mean(fqi2(:, 1));
    mD2 = mean(fqi2(:, 2));
    mW2 = mean(fqi2(:, 3));
    eF2 = 2 * std(fqi2(:, 1), 0)' / sqrt(nExperiments);
    eD2 = 2 * std(fqi2(:, 2), 0)' / sqrt(nExperiments);
    eW2 = 2 * std(fqi2(:, 3), 0)' / sqrt(nExperiments);

    mF3 = mean(fqi3(:, 1));
    mD3 = mean(fqi3(:, 2));
    mW3 = mean(fqi3(:, 3));
    eF3 = 2 * std(fqi3(:, 1), 0)' / sqrt(nExperiments);
    eD3 = 2 * std(fqi3(:, 2), 0)' / sqrt(nExperiments);
    eW3 = 2 * std(fqi3(:, 3), 0)' / sqrt(nExperiments);

    mF4 = mean(fqi4(:, 1));
    mD4 = mean(fqi4(:, 2));
    mW4 = mean(fqi4(:, 3));
    eF4 = 2 * std(fqi4(:, 1), 0)' / sqrt(nExperiments);
    eD4 = 2 * std(fqi4(:, 2), 0)' / sqrt(nExperiments);
    eW4 = 2 * std(fqi4(:, 3), 0)' / sqrt(nExperiments);

    mF = [mF1, mF2, mF3, mF4];
    mD = [mD1, mD2, mD3, mD4];
    mW = [mW1, mW2, mW3, mW4];

    eF = [eF1, eF2, eF3, eF4];
    eD = [eD1, eD2, eD3, eD4];
    eW = [eW1, eW2, eW3, eW4];

    figure;
    x = 1:1:3;
    hold on;

    a = [mF', mD', mW'];
    barplot = bar(a);

    b = [eF', eD', eW'];

    xF = 0.777:3.777;
    errorbar(xF, mF, eF, 'x', 'Color', [0,0,0.35])
    barplot(1).FaceColor='b';

    xD = 1:4;
    errorbar(xD, mD, eD, 'x', 'Color', [0.35,0,0])
    barplot(2).FaceColor='r';

    xW = 1.223:4.223;
    errorbar(xW, mW, eW, 'x', 'Color', [0,0.35,0])
    barplot(3).FaceColor='g';

    legend('FQI', 'DFQI', 'WFQI');
else
    path1 = strcat(type, '/25Episodes/');
    path1C = strcat(type, '/25Episodes/');

    fqi1 = dlmread(strcat(path1, 'results.txt'));
    fqiC1 = dlmread(strcat(path1, 'resultsProdInt.txt'));

    nExperiments = size(fqi1, 1);

    mF1 = mean(fqi1(:, 1));
    mD1 = mean(fqi1(:, 2));
    mW1 = mean(fqi1(:, 3));
    mCW1 = mean(fqiC1);
    eF1 = 2 * std(fqi1(:, 1), 0)' / sqrt(nExperiments);
    eD1 = 2 * std(fqi1(:, 2), 0)' / sqrt(nExperiments);
    eW1 = 2 * std(fqi1(:, 3), 0)' / sqrt(nExperiments);
    eCW1 = 2 * std(fqiC1, 0)' / sqrt(nExperiments);

    mF = [mF1];
    mD = [mD1];
    mW = [mW1];
    mCW = [mCW1];

    eF = [eF1];
    eD = [eD1];
    eW = [eW1];
    eCW = [eCW1];

    figure;
    x = 1:1:4;
    hold on;

    a = [mF', mD', mW', mCW'];
    barplot = bar(a);

    b = [eF', eD', eW', eCW'];

    xF = 0.777:3.777;
    errorbar(xF, mF, eF, 'x', 'Color', [0,0,0.35])
    barplot(1).FaceColor='b';

    xD = 1:4;
    errorbar(xD, mD, eD, 'x', 'Color', [0.35,0,0])
    barplot(2).FaceColor='r';

    xW = 1.223:4.223;
    errorbar(xW, mW, eW, 'x', 'Color', [0,0.35,0])
    barplot(3).FaceColor='g';

    xCW = 2.223:5.223;
    errorbar(xCW, mCW, eCW, 'x', 'Color', [0,0.35,0])
    barplot(4).FaceColor='y';

    legend('FQI', 'DFQI', 'WFQI', 'WFQI ProdInt');
end
