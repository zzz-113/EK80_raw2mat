% Parse Configuration XML data to a Configuration Matlab structure
% Simrad, Lars Nonboe Andersen, 10/10-13

function confdata = parseconfxmlstruct(xmldata)

% Header

headeridx = find(strcmp({xmldata.Children.Name},'Header'));
headerxml = xmldata.Children(headeridx);

nattributes = length(headerxml.Attributes);

for i = 1:nattributes,
    header.(headerxml.Attributes(i).Name) = headerxml.Attributes(i).Value;
end

transceiversidx = find(strcmp({xmldata.Children.Name},'Transceivers'));
transceiversxml = xmldata.Children(transceiversidx);

ntransceivers = length(transceiversxml.Children);

for i = 1:ntransceivers,
   transceiverxml = transceiversxml.Children(i);
   transceivers(i).id =  transceiverxml.Name;
   nattributes = length(transceiverxml.Attributes);
   for j = 1:nattributes,
       transceivers(i).(transceiverxml.Attributes(j).Name) = transceiverxml.Attributes(j).Value;
   end
   
   channelsxml = transceiverxml.Children;
   nchannels = length(channelsxml.Children);
   channels = [];
   for j = 1:nchannels,
       channelxml = channelsxml.Children(j);
       channels(j).Name = channelxml.Name;
       nattributes = length(channelxml.Attributes);
       for k = 1:nattributes,
           channels(j).(channelxml.Attributes(k).Name) = channelxml.Attributes(k).Value;
       end
       
       transducer = [];
       transducerxml = channelxml.Children;
       nattributes = length(transducerxml.Attributes);
       for m = 1:nattributes,
           transducer.(transducerxml.Attributes(m).Name) = transducerxml.Attributes(m).Value;
       end
       channels(j).transducer = transducer;
   end
   transceivers(i).channels = channels;
end  

% Everything comes through as text, so convert selected numerical
% fields into text
for j = 1:length(transceivers)
    names = fieldnames(transceivers(j).channels);
    for k = 1:length(names)
        if sum(strcmp(names{k}, {'Name', 'ChannelIdLong', 'ChannelIdShort', 'transducer', 'ChannelID'})) == 0
            
            % % 1 transceiver with 2 channels (MUX), loop over all channels
            % (Z. Zhuang) 2023/7/9
            for ChannelNum = 1:1:length(transceivers(j).channels)

                transceivers(j).channels(ChannelNum).(names{k}) ...
                    = str2num(transceivers(j).channels(ChannelNum).(names{k}));

            end

        end
    end
    
    % % 1 transceiver with 2 channels (MUX), loop over all channels 
    % (Z. Zhuang) 2023/7/9
    for ChannelNum = 1:1:length(transceivers(j).channels)
        names = fieldnames(transceivers(j).channels(ChannelNum).transducer);
        for k = 1:length(names)
            if ~strcmp(names{k}, 'TransducerName')
                transceivers(j).channels(ChannelNum).transducer.(names{k}) ...
                    = str2num(transceivers(j).channels(ChannelNum).transducer.(names{k}));
            end
        end
    end
end

confdata.header = header;
confdata.transceivers = transceivers;
