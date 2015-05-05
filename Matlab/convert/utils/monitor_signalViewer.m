function eeg_ax = monitor_signalViewer(bbci, varargin)
%MONITOR_SIGNALVIEWER - Display raw-EEG signals is real-time!
%
%This scripts opens a figure and plots the real-time EEG into as traces.
%Press 'q' in that figure to quit.
%
%Synopsis:
% monitor_signalViewer(BBCI, OPT)
% 
%Arguments:
%  BBCI -  the field 'calibrate' holds parameters that specify the EEG
%  acquisition. espeacially, bbci.source should be specified accordingly.
%
%  OPT  -  some further options (optional)
%  
% (firstVersion) 03-2014 JohannesHoehne


fprintf('Press <q> in activated figure to quit the EEG Monitor.\n');

props = {'FigNo'            gcf            'DOUBLE'
         'Maximize'         false          'BOOL'
         'CloseOnExit'      false          'BOOL'
         'CLab'             '*'            'CHAR|CELL{CHAR}'
         'CLabTick'         '*'            'CHAR|CELL{CHAR}'
         'VBorder'          [0.01 0.02]    'DOUBLE'
         'HBorder'          [0.05 0.01]    'DOUBLE[2]'
         'Band'             [2 45]         'DOUBLE[2]'
         'Range'            50             'DOUBLE'
         'Baselining'       false          'BOOL'
         'tracesColor'      []             'DOUBLE[- 3]'
         'tracesLineWidth'  1.5            'DOUBLE'
         'RefCLab'          []             'CHAR'
         'ZerolineColor'    0.7*[1 1 1]    'DOUBLE[1 3]'
         'MonitorFps'       25             'DOUBLE'};

if nargin==0,
  eeg_ax =props; return
end

%% Process input arguments
opt= opt_proplistToStruct(varargin{:});
[opt, isdefault]= opt_setDefaults(opt, props);
opt_checkProplist(opt, props);

if opt.Maximize,
  fig_set(opt.FigNo, 'GridSize',[1 1]);
else
  figure(opt.FigNo);
end
clf;
set(gcf, 'Color',[0 0 0], 'UserData',[]);

bbci.source.record_signals= 0;
bbci.feature = [];
bbci.feature.ival = [-1000/opt.MonitorFps 0];
if ~isempty(opt.Band),
 if isfield(bbci.source.acquire_param{1}, 'fs'),
    [filt_b,filt_a]= cheby2(5, 20, opt.Band/bbci.source.acquire_param{1}.fs*2);
    bbci.signal = [];
    bbci.signal.proc= {{@online_filt, filt_b, filt_a}};
    fprintf('bandpass filter was set up\n');
  else
    error('no sampling freq found -- no filters')
 end
end
bbci.signal.clab= opt.CLab;
bbci.control.condition.interval= 1000/opt.MonitorFps;

bbci= bbci_apply_setDefaults(bbci);
[data, bbci]= bbci_apply_initData(bbci);


winlen= 8000;
winlen_sa= winlen/1000*data.source.fs;
clearlen= 100;
clearlen_sa= clearlen/1000*data.source.fs;

eeg_ax= subplotxl(1, 1, 1, opt.VBorder, opt.HBorder);
clab= data.signal.cnt.clab;
eeg_chansTick= util_chanind(clab, opt.CLabTick);
nChans= length(clab);

if isempty(opt.tracesColor),
  opt.tracesColor= cmap_rainbow(nChans);
end
YLim= ([-2.5 2.5] +[0 nChans-1]) * opt.Range;
hold on;
eeg_YData= zeros(nChans, winlen_sa);
yOffset= [nChans-1:-1:0] * opt.Range;
for cc= 1:nChans,
  y0= yOffset(cc);
  line([1 winlen_sa],[y0 y0], 'Color',opt.ZerolineColor);
  thiscol= opt.tracesColor(1+mod(cc-1,nChans),:);
  eeg_trace(cc)= plot(y0 + nan(winlen_sa,1), 'Color',thiscol);
  eeg_YData(cc,:)= get(eeg_trace(cc), 'YData');
  if ismember(cc, eeg_chansTick),
    text(0, y0, clab(cc), ...
         'Color', thiscol, ...
         'HorizontalAli','right', 'FontSize',16, 'FontWeight','bold');
  end
end
set(eeg_trace, 'LineWidth',opt.tracesLineWidth);
eeg_bar= line([1 1], YLim, 'Color','k', 'LineWidth',2);
set(eeg_ax, 'Box','on', ...
            'XLim', [1 winlen_sa], ...
            'YLim', YLim, ...
            'XTick',[], ...
            'YTick', []);

set(gcf, 'KeyPressFcn', @(dmy,key)(set(gcf,'UserData',key.Character)));

x0= 1;
ptr_old = -10;
run= true;
while run,
  [data.source, data.marker]= ...
          bbci_apply_acquireData(data.source, bbci.source, data.marker);
  if ~data.source.state.running,
    break;
  end
  data.marker.current_time= data.source.time;
  data.signal= bbci_apply_evalSignal(data.source, data.signal, bbci.signal);
  data.control.time= data.source.time;
  event= bbci_apply_evalCondition(data.marker, data.control, bbci.control);
  data.control.lastcheck= data.marker.current_time;
  if isempty(event),
    continue;
  end
  data.feature= ...
        bbci_apply_evalFeature(data.signal, bbci.feature, event);
  xstep= size(data.feature.x,1)/nChans;
  data.feature.x= reshape(data.feature.x, [xstep nChans]);
  
  yOffsetMat = ones(xstep,1)*yOffset;
   
  if xstep==0,
    continue;
  end
  x0= x0 + xstep;
  xiv= [x0-xstep+1:x0];
  ptr= 1+mod(x0, winlen_sa);
   
  if ptr<ptr_old && opt.Baselining,
    yOffset= yOffset - repmat(nanmean(eeg_YData,2),1, 1)' + ...
          [nChans-1:1:0] * opt.Range;
  end
  ptr_old = ptr;
  ptr_iv= 1+mod(xiv, winlen_sa);
  ptr_clear= 1+mod(x0+1:x0+clearlen_sa, winlen_sa);

  % update EEG traces
  set(eeg_bar, 'XData', [1 1]*ptr);
  eeg_YData(:,ptr_iv)= data.feature.x';
  if ~isempty(opt.RefCLab)
    eeg_YData(:,ptr_iv) = eeg_YData(:,ptr_iv) - ...
        repmat(eeg_YData(opt.RefCLab,ptr_iv),nChans,1);
  end
  eeg_YData(:,ptr_iv) = eeg_YData(:,ptr_iv) + yOffsetMat';
  eeg_YData(:,ptr_clear)= NaN;
  for cc= 1:nChans,
    set(eeg_trace(cc), 'YData',eeg_YData(cc,:));
  end
  drawnow;
  run= bbci_apply_evalQuitCondition(data.marker, bbci);
  if isequal(get(gcf, 'UserData'),'q'),
    run= false;
  end
end

bbci_apply_close(bbci, data);
if opt.CloseOnExit,
  close;
end

end



function ax= subplotxl(m, n, p, mv, mh)
%ax= subplotxl(m, n, p, mv, mh)
%
% copied from toolbox
if ~exist('mv','var') || isempty(mv), mv= 0; end
if ~exist('mh','var') || isempty(mh), mh= 0; end

if length(mv)==1, mv= [mv mv mv]; end
if length(mv)==2, mv= [mv(1) 0 mv(2)]; end
if length(mh)==1, mh= [mh mh mh]; end
if length(mh)==2, mh= [mh(1) 0 mh(2)]; end

if iscell(p),
  p1= p{1};
  p2= p{2};
  if length(p1)==1 && length(p2)>1,
    p1= p1*ones(1, length(p2));
  elseif length(p2)==1 && length(p1)>1,
    p2= p2*ones(1, length(p1));
  end
  ax= zeros(1, length(p1));
  for ii= 1:length(p1),
    ax(ii)= subplotxl(m, n, [p1(ii) p2(ii)], mv, mh);
  end
  return;
end

if isempty(n),
  mn= m;
  m= floor(sqrt(mn));
  n= ceil(mn/m);
end

pv= ( 0.999 - mv(1) - mv(3) - mv(2)*(m-1) ) / m;
ph= ( 0.999 - mh(1) - mh(3) - mh(2)*(n-1) ) / n;
if length(p)==1,
  iv= m - 1 - floor((p-1)/n);
  ih= mod(p-1, n);
else
  iv= m - p(1);
  ih= p(2) - 1;
end
pos= [mh(1) + ih*(mh(2)+ph),  mv(1) + iv*(mv(2)+pv),  ph,  pv];
ax= axes('position', pos);

end