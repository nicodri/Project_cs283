% author_name = Nicolas Drizard
% Processing

% Test of different features extractor on the whales dataset

% Loading two images
% Ia=single(rgb2gray(imread('../heads/whale_08017/w_1106.jpg')));
% Ia=rgb2gray(imread('../heads/whale_08017/w_6177.jpg'));
Ia=rgb2gray(imread('../heads/whale_24458/w_2071.jpg'));
% Ib=single(rgb2gray(imread('../heads/whale_26288/w_266.jpg')));
% Ib=rgb2gray(imread('../heads/whale_26288/w_4394.jpg'));
% Ib=rgb2gray(imread('../heads/whale_24458/w_8551.jpg'));
Ib=rgb2gray(imread('../heads/whale_24458/w_4963.jpg'));

%%
% SIFT descriptor

% To run vl feat
%run /Users/nicolasdrizard/vlfeat-0.9.20/toolbox/vl_setup.m
Ia_S = single(Ia);
Ib_S = single(Ib);

% features format [X;Y;S;TH], where X,Y is the (fractional) center of the
% frame, S is the scale and TH is the orientation (in radians)
[fa, da] = vl_sift(Ia_S) ;
[fb, db] = vl_sift(Ib_S) ;
[mab,sab]=vl_ubcmatch(da,db);
[mba,sba]=vl_ubcmatch(db,da);

% Eliminate matches that are not symmetric.
% Store results in 2xK arrays: M12_sym, M23_sym
Mab_sym=[];
for i=1:size(mab,2)
	mba_i=find(mba(2,:)==mab(1,i));
	if ~isempty(mba_i)
		if mba(1,mba_i)==mab(2,i)
			Mab_sym=[Mab_sym, mab(:,i)];
		end
	end
end

% Strip away unmatched points
fa=fa(:,Mab_sym(1,:));
fb=fb(:,Mab_sym(2,:));

% Display the matches
figure; 
%set(gcf,'position',[59 342 937 266]);

subplot(1,2,1); imshow(Ia,[]); hold on;
ha=vl_plotframe(fa);

subplot(1,2,2); imshow(Ib,[]); hold on;
hb=vl_plotframe(fb);

%%
% Computer Vision Toolbox

% HARRIS features: Find the corners
pointsa = detectHarrisFeatures(Ia);
pointsb = detectHarrisFeatures(Ib);

% SURF features
% pointsa = detectBRISKFeatures(Ia);
% pointsb = detectBRISKFeatures(Ib);

% Extract the neighborhood features
[featuresa, valid_pointsa] = extractFeatures(Ia, pointsa);
[featuresb, valid_pointsb] = extractFeatures(Ib, pointsb);

% Match the features
indexPairs = matchFeatures(featuresa, featuresb);

% Retrieve locations
matchedPointsa = valid_pointsa(indexPairs(:, 1), :);
matchedPointsb = valid_pointsb(indexPairs(:, 2), :);

% Display the features
figure; showMatchedFeatures(Ia, Ib, matchedPointsa, matchedPointsb);