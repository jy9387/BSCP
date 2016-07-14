function [bdKeyPair, SkDist] = pair_sk2bd(skPath, imgPath, maxRadius, show)
%% Match boundary points to skeleton points.
% Inputs:
%       skPath      : The path of the skeleton feature;
%       imgPath     : The path of the image;
%       maxRadius   : The radius used when thickening the skeleton;
%       show        : Decides whether the matching will be shown or not;
% Outputs:
%       bdKeyPair   : The relationship of the boundary key-points and the
%                     skeleton points. It is a N * 2 matrix, whose second
%                     column indicates the boundary key-points, and first
%                     column indicates the corresponding skeleton points.
%       SkDist      : The scale of every boundary point is given according
%                     to two of its nearest key-points. We simply adopt 
%                     linear interpolation to label the scale of each
%                     boundary point.
% 
% If you use the code below, we appreciate it if you cite an appropriate 
% subset of the following papers:
% @article{BSCP_PRL2016,
%   author    = {W. Shen, Y. Jiang, W. Gao, D. Zeng, X. Wang},
%   title     = {Shape Recognition by Bag of Skeleton-associated Contour 
%               Parts},
%   journal   = {Pattern Recognition Letters},
%   year      = {2016},
% }
% 
% Written by Yuan Jiang (mailto: jy9387@outlook.com)
% July. 2016, Shanghai University


if nargin < 4
    show = false;
    if nargin < 3
        maxRadius = sqrt(8);
    end
end

load(skPath);
S = SK; % w.r.t the variable name you used when saving skeletons.
skSize = size(S);

%% Thicken the boundaries so as to find more key-points on the boundary;
[D, S_IDX] = bwdist(S);
S_thick = S; S_thick(D <= maxRadius) = S_IDX(D <= maxRadius);

%% Obtain the longest boundary;
I = imread(imgPath);
assert((size(S,1) == size(I, 1)) & (size(S,2) == size(I,2)));

boundaries = bwboundaries(I, 'noholes');
if length(boundaries) > 1
    fprintf('Warning: the numbers of boundary are more than one.( %s boundaries in %s )',num2str(length(boundaries)),skPath);
    L = zeros(length(boundaries), 1);
    for l = 1:length(L)
        L(l) = size(boundaries{l}, 1);
    end
    [~, maxL] = max(L);
    boundaries = boundaries{maxL};
else
    boundaries = boundaries{1};
end
bdIndex = sub2ind(skSize, boundaries(:,1), boundaries(:,2));
assert(bdIndex(1) == bdIndex(end));
bdIndex = bdIndex(1:end-1);
BW = zeros(skSize); BW(bdIndex) = 1;

%% Find the boundary key-points and their related skeleton pixels;
[~, BW_IDX] = bwdist(BW);
sk2bd_IDX = BW_IDX(S_thick>0);
bdKeyIndex = unique(sk2bd_IDX); % Key-points on the boundary;
bdKeyValue = zeros(length(bdKeyIndex));
bdKeyPair = zeros(length(bdKeyIndex), 2); % 'bdKeyPair' denotes the relationship among the skeleton points and boundary key-points;
bdKeyPair(:, 2) = bdKeyIndex; % second col: indexes of key-points on the boundary; first col: indexes of skeleton points corresponding to these key-points.

for i=1:length(bdKeyIndex)
    S_thickIndex = find(S_thick > 0);
    tmp_SIndex = S_thick(S_thickIndex(sk2bd_IDX == bdKeyIndex(i)));% Points on the original skeleton, where all their closest boundary key-points are the bdKeyIndex(i);
    tmp_SIndex = unique(tmp_SIndex);
    if isempty(tmp_SIndex)
        error('tmp_SIndex is empty! KeyPoint on the boundary match no point on the skeleton.');
    elseif (length(tmp_SIndex) == 1) 
        bdKeyValue(i) = S(tmp_SIndex);
        bdKeyPair(i, 1) = tmp_SIndex;
    else
        tmp_bdKeyRow = mod(bdKeyIndex(i),size(S,1)); tmp_bdKeyCol = (bdKeyIndex(i) - tmp_bdKeyRow)/size(S,1) + 1;
        tmp_skRowOrigin = mod(tmp_SIndex,size(S,1)); tmp_skColOrigin = (tmp_SIndex - tmp_skRowOrigin)/size(S,1) + 1;
        tmp_dist = sqrt((tmp_skRowOrigin - double(tmp_bdKeyRow)).^2 + (tmp_skColOrigin - double(tmp_bdKeyCol)).^2);
        [~, tmp_minIndex] = min(tmp_dist);
        bdKeyValue(i) = S(tmp_SIndex(tmp_minIndex));
        bdKeyPair(i, 1) = tmp_SIndex(tmp_minIndex);            
    end
end

%% Visualization:
if show
    figure;
    imshow(I-S); hold on;
    [y1, x1] = ind2sub(skSize, bdKeyPair(:, 1)); % skeleton pixels;
    [y2, x2] = ind2sub(skSize, bdKeyPair(:, 2)); % boundary pixels;
    for k = 1:length(x1)
        line([x1(k) x2(k)], [y1(k) y2(k)], 'Color', [0 1 0]);
    end
end

%% Interpolate scale-values for rest of the points on the boundary;
% find the first key-point on the list:
bdKeyOrder = zeros(size(bdKeyIndex));
for i = 1:length(bdKeyIndex)
    Order = find(bdIndex == bdKeyIndex(i));
    if length(Order) > 1
        Order = max(Order);
    end
    bdKeyOrder(i) = Order;
end
[bdKeyOrder_First, t] = min(bdKeyOrder);
X = bdKeyOrder-bdKeyOrder_First + 1; % bdKeyOrder_First->bdKeyOrder_Last->length(bdIndex)+1;
X = [X; length(bdIndex) + 1];
Y = [bdKeyValue; bdKeyValue(t)];
xi = 1:(length(bdIndex) + 1);
yi = interp1(X, Y, xi)';
bdValue = yi(1:end-1);
bdValue = [bdValue(end-bdKeyOrder_First + 2:end); bdValue(1:end-bdKeyOrder_First + 1)];

SkDist = zeros(size(S));
SkDist(bdIndex) = bdValue;
save([skPath(1:end-7), '_SkDist.mat'], 'SkDist');
end