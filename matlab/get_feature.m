function features = get_feature(features, X, index)
% features is a instance * feature matrix, X is a single instance, index is
% the index of X
% X is in the form that packet * subcarrier
[~, c] = size(X);
features(index, c*0 + 1:c) = mean(X);
features(index, c*1 + 1:c*2) = std(X);
features(index, c*2 + 1:c*3) = var(X);
features(index, c*3 + 1:c*4) = min(X);
features(index, c*4 + 1:c*5) = max(X);
features(index, c*5 + 1:c*6) = median(X);
features(index, c*6 + 1:c*7) = rms(X);
features(index, c*7 + 1:c*8) = rssq(X);

end