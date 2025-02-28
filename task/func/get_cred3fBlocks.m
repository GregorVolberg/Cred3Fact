function [blocks] = get_cred3fBlocks(trialmat, ncatch, diffCatch, ISI, frame_s)

trialsPerBlock = 48;

% randomize trial matrix
randomIndex    = Shuffle(1:size(trialmat,1));
randomMat      = trialmat(randomIndex, :);

% get catch trials
nCatchTrials    =  Sample(ncatch(1):ncatch(2));
goodCatchTrials = 0;
while ~goodCatchTrials
    catchT = sort(randsample(1:size(trialmat,1), nCatchTrials));
    goodCatchTrials = ~any(diff(catchT) < diffCatch(1) | diff(catchT) > diffCatch(2));
end
cTrials = zeros(size(trialmat, 1), 1);
cTrials(catchT) = 1;

% add catch trials to randomized matrix, move to column 5
randomMat.catch = cTrials;
randomMat = movevars(randomMat, 'catch', 'Before', 6);

% compute frame-exact ISI
actualISI = randsample([ISI(1):frame_s:ISI(2)], size(randomMat,1), true) - frame_s/2; 
randomMat.ISI = actualISI';

blockStart = [1:trialsPerBlock:size(trialmat,1)];
blockStop  = [trialsPerBlock:trialsPerBlock:size(trialmat,1)];

blocks = cell(1,10);
for k = 1:10
blocks{k} = randomMat(blockStart(k):blockStop(k),:);
end

% randomize all with the following constraints: 
% - no repetitions of topics
% - no repetition within any of the three factors in the first and last
%   <noRepetitions> per block 
% 
% % get block start / stop indices
% blockIndicesStart = [1:trialsPerBlock:size(trialmat,1)];
% blockIndicesStop  = [trialsPerBlock-(noRepetitions-1):trialsPerBlock:size(trialmat,1)];
% 
% % get <noRepetition> indices at the beginning and end of each block
% indxStart = [blockIndicesStart', blockIndicesStart' + [1:(noRepetitions-1)]];
% indxStop = [blockIndicesStop', blockIndicesStop' + [1:(noRepetitions-1)]];
% allIndices = [indxStart, indxStop];
% targetIndices = reshape(allIndices', 1, numel(allIndices));
% 
% % select relevant columns for randomizing
% relevantCols = [trialmat.topic, trialmat.truth == 't', ...
%                 ismember(cellstr(trialmat.language), 'll'), ...
%                 ismember(cellstr(trialmat.visual), 'vl')];
%             
% goodBlock = 0;
% fprintf('Generate blocks...\n');
% while ~goodBlock
%     % randomize
%     randomIndex    = Shuffle(1:size(relevantCols,1));
%     randomMat      = relevantCols(randomIndex, :);
%     % test
%     diffMat   = ([1 1 1 1; diff(randomMat)]);
%     diffMat   = diffMat~=0;
%     %topicRep  = any(diffMat(:,1) == 0); 
%     %factorRep = sum(abs(diffMat(targetIndices,2:4)),2) >= 1;
%     goodBlock      = all(sum(diffMat,2) < 2); 
%     %goodBlock = all(~topicRep & factorRep);
% end
% fprintf('... finished.\n');
% 
% tProbability   = targetProbability(1) + (targetProbability(2) - targetProbability(1)) * rand(1);
% numRepetitions = round(tProbability * blockLength);
% numNoRepetitions  = blockLength - numRepetitions - noRepetitionAtStartAndEnd*2;
% 
% 
% 
% repetitions = [ones(1, noRepetitionAtStartAndEnd), tempRepetitions, ones(1, noRepetitionAtStartAndEnd)];
% aBlock{j}    = repelem(allBlock, repetitions); %repelem(tempBlock(((j - 1) * blockLength + 1):(j * blockLength)), repetitions);
% rFlag{j} = [0, diff(aBlock{j}) == 0];
% end
end