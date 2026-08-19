function tsd_out = TSD_SelectChannel(tsd_in,channel_label,options)
% function tsd_out = TSD_SelectChannel(tsd_in,channel_label)
% Parameters:
%     tsd_in: tsd object to be select from
%     channel_label: char,str or cell of channel index that is used to
%       select from the tsd
% Optional:
%     iloc: numeric array of index, default is an empty array,
%       if iloc is provided it will be used instead of channel_label.
% returns tsd containing only channels with labels in channel_label
%
% MvdM 2015-11-03 initial version

% argument block
arguments
    tsd_in {CheckTSD}
    channel_label 

    % Optional inputs
    options.iloc {mustBeNumeric, mustBeInteger} = []
end


if ~isempty(options.iloc)
    [ntraces,~] = size(tsd_in.data);
    if any(options.iloc>ntraces) || any(options.iloc<1)
        error("Index out of bound. Index must be positive and not exceed %d.",ntraces)
    end
    keep_idx = options.iloc;
elseif ~iscell(channel_label)
   keep_idx = strmatch(channel_label,tsd_in.label,'exact');
else
   keep_idx = [];
   for iCh = 1:length(channel_label)
       
      keep_idx = cat(1,keep_idx,strmatch(channel_label{iCh},tsd_in.label,'exact'));
       
   end
end

if isempty(keep_idx)
    error('No channels selected.');
end

tsd_out = tsd_in;
tsd_out.data = tsd_out.data(keep_idx,:);
tsd_out.label = tsd_out.label(keep_idx);