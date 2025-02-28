function [vp, instruct, responseHand, rkeys] = get_experimentInfo()
  vp = input('\nParticipant (three characters, e.g. S01)? ', 's');
    if length(vp)~=3 
       error ('Use three characters for the name, e. g. ''S04'''); end

   response_mapping = str2num(input('\nResponse mapping?\n1: left hand, \n2: right hand\n', 's'));    
      if ~ismember(response_mapping, [1, 2])
        error('\nUse only numbers 1 or 2 for the response mapping.'); end
   
    switch response_mapping
    case  1
        instruct = 'Use the LEFT hand (keys y, x, c, and v) for responding.\n';
        responseHand = 'left';
    case  2
        instruct = 'Use the RIGHT hand (keys y, x, c, and v) for responding.\n';
        responseHand = 'right';
    end
rkeys = {'y', 'x', 'c', 'v'};
end

    

