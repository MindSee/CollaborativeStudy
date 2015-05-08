function [cnt, blk, mrk_new]= proc_concatBlocksNew(cnt, blk, mrk)

ii=1;
[cnt_new,  mrk_new]= proc_selectIval(cnt, mrk, blk.ival(:,ii)');
for ii= 2:size(blk.ival,2);
    [cnt_temp, mrk_temp]= proc_selectIval(cnt, mrk, blk.ival(:,ii)');
    [cnt_new, mrk_new]= proc_appendCnt(cnt_new, cnt_temp, mrk_new, mrk_temp);
end
mrk_new=mrk_sortChronologically(mrk_new);



