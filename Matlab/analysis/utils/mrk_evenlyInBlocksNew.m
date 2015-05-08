function mrk= mrk_evenlyInBlocksNew(blk, msec, varargin)

% MRK_EVENLYINBLOCKS - inserts additional markers between the existing
% markers, starting msec after the existing markers.
%
% Synopsis:
%   [MRK]= mrk_evenlyInBlocks(mrk, msec, <OPT>)
%
% Arguments:
%   MRK: marker structure
%   MSEC: length of each block in milliseconds
%
% Opt - struct or property/value list of optional fields/properties:
%      .offset_start -  specify offset in milliseconds after which the first
%                       after an existing marker block is to be set (default 0)
%      .offset_end -    minimum length between block and next marker (default msec) 
%      .removeold -  if 1, removes the old markers and keeps only the newly
%                    made blocks (default 0)
%
% Returns:
%   MRK: updated marker structure

% Author: Benjamin B
% 7-2010: Documented, extended, cleaned up (Matthias T)
props= {'offset_end',       msec  
        'offset_start'       0
        'removeold'  0  };


opt= opt_proplistToStruct(varargin{:});
opt= opt_setDefaults(opt, props);
opt_checkProplist(opt, props);

%%
mrk= struct('time',[], 'fs',blk.fs, 'blkno',[]);
if isfield(blk, 'y'),
  [nClasses, nBlocks]= size(blk.y);
  mrk.y= zeros(nClasses,0);
  mrk.className= blk.className;
end
%step= round(msec/1000*blk.fs);
%offset_start= round(opt.offset_start/1000*blk.fs); % start offset in samples
%offset_end= round(opt.offset_end/1000*blk.fs); % end offset in samples

step = msec;
offset_start= opt.offset_start; % start offset in msec
offset_end= opt.offset_end; % end offset in msec

nBlocks= size(blk.ival,2);
for bb= 1:nBlocks,
  %new_pos= blk.ival(1,bb)+offset_start:step:blk.ival(2,bb)-offset_end;
  new_time= blk.ival(1,bb):msec:blk.ival(2,bb)-offset_end;
  nMrk= length(new_time);
  mrk.time= cat(2, mrk.time, new_time);
  mrk.blkno= cat(2, mrk.blkno, bb*ones(1,length(new_time)));
  if isfield(blk, 'y'),
    new_y= zeros(nClasses, nMrk);
    iClass= find(blk.y(:,bb));
    new_y(iClass,:)= 1;
    mrk.y= cat(2, mrk.y, new_y);
  end
end
%mrk= mrk_addIndexedField(mrk, 'blkno');
