function props= live_signalCheck(bbci, varargin)

def_cmap= cmap_whitered(64);
props = {'FigNo'       gcf        'DOUBLE'
         'Maximize'    false      'BOOL'
         'Window'      2000       'DOUBLE'
         'CLab'        '*'        'CHAR|CELL{CHAR}'
         'CLim1'       [15 30]   'DOUBLE[2]'
         'CLim2'       [10 35]     'DOUBLE[2]'
         'Colormap'    def_cmap   'DOUBLE[- 3]'};

if nargin==0,
  return
end

opt= opt_proplistToStruct(varargin{:});
[opt, isdefault]= opt_setDefaults(opt, props);
opt_checkProplist(opt, props);

if opt.Maximize,
  fig_set(opt.FigNo, 'GridSize',[1 1]);
else
  figure(opt.FigNo);
end
clf;
colormap(opt.Colormap);

bbci.source.record_signals= 0;
bbci.feature = [];
bbci.feature.ival = [-opt.Window 0];
bbci.feature.fcn= {@proc_spectrum};
bbci.feature.param= {{[41 50]}};
bbci.signal.clab= opt.CLab;

bbci= bbci_apply_setDefaults(bbci);
[data, bbci]= bbci_apply_initData(bbci);

cidx= util_chanind(bbci.source.acquire_param{1}.clab, opt.CLab);
clab= bbci.source.acquire_param{1}.clab(cidx);

mnt= mnt_setElectrodePositions(clab);
wnull= zeros(length(clab), 1);
opt_sl= {'DrawEars',1, 'LineProperties',{'LineWidth',3}};
axis_subplot(1, 2, 1, 0, 0.01);
H1= plot_scalpLoading(mnt, wnull, opt_sl{:}, 'CLim',opt.CLim1);
axis_subplot(1, 2, 2, 0, 0.01);
H2= plot_scalpLoading(mnt, wnull, opt_sl{:}, 'CLim',opt.CLim2);

set(gcf, 'KeyPressFcn', @(dmy,key)(set(gcf,'UserData','QUIT')));

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
  data.feature= ...
        bbci_apply_evalFeature(data.signal, bbci.feature, event);
  
  spec= reshape(data.feature.x, [10 length(clab)]);
  w1= mean(spec(1:9,:));
  w2= spec(10,:) - mean(spec(8:9,:),1);
  update_scalpLoading(H1, w1, opt);
  update_scalpLoading(H2, w2, opt);
  drawnow;
  
  run= bbci_apply_evalQuitCondition(data.marker, bbci);
  ud= get(gcf, 'UserData');
  if isequal(ud,'QUIT'),
    run= false;
  end
end

bbci_apply_close(bbci, data);
%set(gcf, 'KeyPressFcn', []);
close;



function update_scalpLoading(H, w, opt)

nColors= size(opt.Colormap,1);
CLim= get(H.ax, 'CLim');
ci= round( nColors * (w-CLim(1))/diff(CLim) );
ci= max(ci, 1);
for chan= 1:numel(ci),
  if ci(chan)>nColors,
    %set(H.patch(chan), 'FaceColor',[0 0 0]);
    %set(H.patchBorder(chan), 'Color', [0.85 0 0]);
    set(H.label_markers(chan), 'MarkerFaceColor',[0 0 0]);
    set(H.label_markers(chan), 'MarkerEdgeColor', [0.85 0 0]);
    set(H.label_text(chan), 'Color', [0.85 0 0]);
  else
    %set(H.patch(chan), 'FaceColor',opt.Colormap(ci(chan),:));
    %set(H.patchBorder(chan), 'Color', [0 0 0]);
    set(H.label_markers(chan), 'MarkerFaceColor',opt.Colormap(ci(chan),:));
    set(H.label_markers(chan), 'MarkerEdgeColor', [0 0 0]);
    set(H.label_text(chan), 'Color', [0 0 0]);
  end
end
