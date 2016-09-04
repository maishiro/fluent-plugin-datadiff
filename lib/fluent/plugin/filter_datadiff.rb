module Fluent
  class DataDiffFilter < Filter
    Plugin.register_filter('datadiff', self)

    config_param :diff_idx_key, :string,
               :desc => 'The key to exclude_path data. Multi keys separates comma.'
    config_param :key_diff, :string,
               :desc => 'The key to diff item'
    config_param :key_add, :string,
               :desc => 'The key to add item name'
    config_param :time_format, :string, default: nil
    desc 'The interval time between periodic program runs.'

    def configure(conf)
      super
      #p "DataDiffFilter.configure"
      #print "diff_idx_key:",@diff_idx_key, "\n"

      if @time_format
        f = @time_format
        @time_parse_proc =
          begin
            strptime = Strptime.new(f)
            Proc.new { |str| Fluent::EventTime.from_time(strptime.exec(str)) }
          rescue
            Proc.new {|str| Fluent::EventTime.from_time(Time.strptime(str, f)) }
          end
      else
        @time_parse_proc = Proc.new {|str| Fluent::EventTime.from_time(Time.at(str.to_f)) }
      end

      @mapLast = {}
    end

    def filter(tag, time, record)
      #p "DataDiffFilter.filter"
      #print "diff_idx_key:",@diff_idx_key, "\n"
    end

    def filter_stream(tag, es)
      #p "DataDiffFilter.filter_stream"
      #print "diff_idx_key:",@diff_idx_key, "\n"

      lst = @diff_idx_key.split(",")
      #p lst

      new_es = MultiEventStream.new
      es.each { |time, record|
        begin
          str = ''
          lst.each { |val|
            #p val
            #p record[val].to_s
            str << record[val].to_s
          }
          #p str

          if @mapLast[str] == nil
            #print "nil\n"
            #@mapLast[str] = record[@key_diff]
            @mapLast[str] = record
          else
            preRecord = @mapLast[str]
            #print "prev ",preRecord," \n"
            #print "prev ",preRecord[@key_diff].to_s," \n"

            if @time_format
              #print "time_format ",@time_format," \n"
              val = @time_parse_proc.call(record[@key_diff]) - @time_parse_proc.call(preRecord[@key_diff])
            else
              val = record[@key_diff] - preRecord[@key_diff]
            end

            #@mapLast[str] = record[@key_diff]
            #record[@key_add] = val
            #new_es.add(time, record)
            preRecord[@key_add] = val
            new_es.add(time, preRecord)
            @mapLast[str] = record
          end
       rescue => e
          router.emit_error_event(tag, time, record, e)
        end
      }
      new_es
    end
  end
end