% Plot results
Xt = Xm(:,1);

i_fig = 0;

if (0),
for i = 1:n_FVs
  name = strtrim(FVs(i,:));
  % get column number
  col = csv_lookup(name,csv);
  if (col>=1),
    name = strrep(name,'_',' ');
    i_fig = i_fig + 1;
    figure(i_fig);
    plot(Xt,Xm(:,col))
    xlabel('Time (hr)')
    ylabel(name)
    legend('Meas')
    title(['FV: ' name])
  end
end
end

if (1),
for i = 1:n_MVs
  name = strtrim(MVs(i,:));
  % get column number
  col = csv_lookup(name,csv);
  if (col>=1),
    name = strrep(name,'_',' ');
    i_fig = i_fig + 1;
    figure(i_fig);
    plot(Xt,Xm(:,col))
    xlabel('Time (hr)')
    ylabel(name)
    legend('Meas')
    title(['MV: ' name])
  end
end
end

if (0),
for i = 1:n_SVs
  name = strtrim(SVs(i,:));
  name = strrep(name,'_',' ');
  i_fig = i_fig + 1;
  figure(i_fig);
  plot(Xt,Xs(:,i))
  xlabel('Time (hr)')
  ylabel(name)
  legend('Model')
  title(['SV: ' name])
end
end

if(1),
for i = 1:n_CVs
  name = strtrim(CVs(i,:));
  % get column number
  col = csv_lookup(name,csv);
  i_fig = i_fig + 1;
  figure(i_fig);
  name = strrep(name,'_',' ');
  if (col>=1),
    plot(Xt,Xc(:,i),'b-')
    hold on;
    plot(Xt,Xm(:,col),'r.-')
    xlabel('Time (hr)')
    ylabel(name)
    legend('Model','Meas')
    title(['CV: ' name])
  else
    plot(Xt,Xc(:,i),'b-')
    xlabel('Time (hr)')
    ylabel(name)
    legend('Model')
    title(['CV: ' name])
  end
end
end
