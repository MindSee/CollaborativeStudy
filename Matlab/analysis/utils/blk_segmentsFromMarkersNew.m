function blk = blk_segmentsFromMarkersNew(mrk, varargin)
%BLK_SEGMENTSFROMMARKERS - Define segments based on markers
%
% usage:
%    area = blk_segmentsFromMarkers(filename, <opt>)
%    area = blk_segmentsFromMarkers(mrk, <opt>)
%
% input:
%   mrk - BV marker structure (struct of arrays) such as return by
%          eegfile_readBVmarkers(..., 0) or
%   filename-  (in this case markers are loaded from that file)
%
%   opt:
%    start_marker: Default: {'New Segment'}
%    end_marker: If end_marker is empty, each segments ends with the
%       beginning of the next one. Default [].
%    exclude_start_marker: []
%    include_start_marker: []
%    fs: resample markers to this sampling rate
%
% output:
%   blk      an nx2 array with intervals
%
% see also:
%   mrk_evenlyInBlocks

% GUIDO DORNHEGE; 19/03/2004 (getActivation Areas)
% Benjamin Blankertz Oct 2007

% opt= opt_proplistToStruct(varargin{:});
% opt= opt_setDefaults(opt, ...
%                   {'start_marker', {'New Segment',''}; ...
%                   'end_marker', ''; ...
%                   'exclude_start_marker', ''; ...
%                   'exclude_end_marker', ''; ...
%                   'start_first_block', 0; ...
%                   'skip_unfinished', 1});

opt= opt_proplistToStruct(varargin{:});

props={'start_marker'     {'New Segment',''} 'CHAR'
       'end_marker'             ''           'CHAR'
       'exclude_start_marker'   ''            'BOOL'
       'exclude_end_marker'     ''             'BOOL'
       'start_first_block'      0              'BOOL'
       'skip_unfinished'        1              'BOOL'};

if nargin==0,
  blk= props; 
  return
end

opt= opt_proplistToStruct(varargin{:});
opt= opt_setDefaults(opt, props);
opt_checkProplist(opt, props);

misc_checkType(mrk, 'STRUCT(time event)');
misc_checkType(mrk.event, 'STRUCT(desc)', 'mk.event');
%misc_checkType(classDef, 'CELL');

classDef= {opt.start_marker, ...
           opt.end_marker, ...
           opt.exclude_start_marker, ...
           opt.exclude_end_marker};

% if ischar(mrk),  %% first argument is the filename
%   [mrk, fs]= file_loadMatlab(mrk, 'vars',{'mrk_orig','fs_orig'});
%   mrk= mrk_arrayOfStructs2structOfArrays(mrk, fs);
%   mrk= mrk_resample(mrk, opt.fs);
% end
if isfield(mrk, 'desc'),
  mrk= mrk_defineClasses(mrk, classDef, 'RemoveVoidClasses',0); %maybecomment
else
  mkk= mrk;
  mkk.className= {'start','end','start of pause','end of pause'};
  mkk.y= zeros(length(classDef), size(mkk.y,2));
  for cc= 1:length(classDef),
    ci= strmatch(classDef{cc}, mrk.className, 'exact');
    if ~isempty(ci),
      mkk.y(cc,:)= mrk.y(ci,:);
    end
  end
  mrk= mrk_selectEvents(mkk, 'valid', 'RemoveVoidClasses',0);
end

blk = [];
if opt.start_first_block>0,
  if ~mrk.y(1,1),
    %% first marker is non a start marker: start block at the beginning
    status= 1;
    mrk_start= opt.start_first_block;
    warning('missing start marker: starting first block as specified');
  end
else
  status = 0;
end

for i = 1:size(mrk.y,2);
  switch status
   case 0   % no session started, wait for marker 1
    if mrk.y(1,i),
      if isempty(opt.end_marker),  %% do not expect end marker
        if ~isnan(mrk_start),
          blk = cat(1, blk, [mrk_start,mrk.time(i)]);
        end
      else
        status = 1;
      end
      mrk_start = mrk.time(i);
    end
   case 1   % session started, no pause, wait for end or pause start
    if mrk.y(2,i)
      blk = cat(1,blk,[mrk_start,mrk.time(i)]);
      status = 0;
    end
    if mrk.y(3,i)
      blk = cat(1,blk,[mrk_start,mrk.time(i)]);
      status = 2;
    end
   case 2   %paused wait for pause end
    if mrk.y(4,i)
      mrk_start = mrk.time(i);
      status = 1;
    end
    if mrk.y(2,i)
      status = 0;
    end
  end
end

if status==1,
  if opt.skip_unfinished,
    warning('last active phase has no end marker (skipped)');
  else
    blk = cat(1, blk, [mrk_start,mrk.time(end)]);
    warning('last active phase has no end marker (took last marker instead)');
  end
end

blk= struct('ival',blk');