function [J] = evaluatePolicy(gps, nBins, horizon)

    uMax = 5.0;
    actions = linspace(-uMax, uMax, nBins);
    nTestExp = 36;
    J = zeros(nTestExp, horizon);

    for i = 0:nTestExp - 1
        theta = -pi + 2 * pi * i / nTestExp;
        velocity = 0;
        state = [theta, velocity];
        
        for j = 1:horizon
            if length(gps) == 1
                qs = zeros(nBins, 1);
                for k = 1:nBins
                    qs(k) = gps.predict([state ./ [pi, pi / 4 / 0.01], actions(k) / uMax]);
                end
            else
                if size(gps, 1) == 2
                    if size(gps, 2) == 1
                        qs = zeros(nBins, 1);
                        for k = 1:length(qs)
                            prediction1 = gps{1}.predict([state ./ [pi, pi / 4 / 0.01], actions(k) / uMax]);
                            prediction2 = gps{2}.predict([state ./ [pi, pi / 4 / 0.01], actions(k) / uMax]);
                            qs(k) = mean([prediction1, prediction2]);
                        end
                    else
                        qs = zeros(size(gps, 2), 1);
                        for k = 1:length(qs)
                            prediction1 = gps{1, k}.predict(state ./ [pi, pi / 4 / 0.01]);
                            prediction2 = gps{2, k}.predict(state ./ [pi, pi / 4 / 0.01]);
                            qs(k) = mean([prediction1, prediction2]);
                        end
                    end
                else
                    qs = zeros(length(gps), 1);
                    for k = 1:length(qs)
                        qs(k) = gps{k}.predict(state ./ [pi, pi / 4 / 0.01]);
                    end                    
                end
            end

            [~, action] = max(qs);
            action = find(qs == qs(action));
            action = datasample(action, 1);
            
            actions = linspace(-uMax, uMax, nBins);
            action = actions(action);
            
            [reward, state] = step(state, action, 0);
            J(i + 1, j) = reward;
        end
    end
    
    J = mean(mean(J, 2));
end
