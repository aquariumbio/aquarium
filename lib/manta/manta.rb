module Manta

  def self.start job, user, request, cookies, view = nil

    if Bioturk::Application.config.vision_server_interface != ''

      Thread.new do

        server = "#{Socket.gethostname}:#{request.port}"

        url = Bioturk::Application.config.vision_server_interface + "start?&job=#{job.id}&server=" + server + "&user=" + (user.login) + "&protocol=#{job.path}" + "&location=" + (cookies[:location] ? cookies[:location] : 'undefined')

        begin
          manta = URI::escape url
        rescue Exception => e
          puts "Error on setting up URI: " + e.to_s
        end

        begin
          uri = URI(manta)
          res = Net::HTTP.get(uri)

          if view
            view.logger.info "Message to MANTA on start: " + uri.to_s
            view.logger.info "Message from MANTA on start: " + res
          end
        rescue Exception => e
          puts "Could not talk to MANTA on start: " + e.to_s
        end

      end

    end

  end

  def self.stop job, request, aborted, view = nil

    if Bioturk::Application.config.vision_server_interface != ''

      Thread.new do

        begin
          server = "#{Socket.gethostname}:#{request.port}"
          url = Bioturk::Application.config.vision_server_interface + "stop?&job=#{job.id}&server=" + server + "&abort=" + aborted
          uri = URI(url)
          res = Net::HTTP.get(uri)

          if view
            view.logger.info "Message to MANTA on stop: " + uri.to_s
            view.logger.info "Message from MANTA on stop: " + res
          end
        rescue Exception => e
          puts "Could not talk to MANTA on stop: " + e.to_s
        end

      end

    end

  end

  def self.blinker

    if Rails.env == 'development' && Bioturk::Application.config.vision_server_interface != ''

      "var headerColor = document.getElementById('header-bar').style.background;
      var cameraIsOn = false;

      function blinkHeader() {

        var el = document.getElementById('header-bar');

        if ( cameraIsOn ) {

          if ( el.style.background == 'rgb(255, 0, 0)' ) {
            el.style.background = headerColor;
          } else {
            el.style.background = '#f00';
          }

        } else {
          el.style.background = headerColor;
        }

        setTimeout(blinkHeader,1000);

      }

      blinkHeader();

      function checkCamera() {

        $.ajax({
          type: 'GET',
          url: '#{Bioturk::Application.config.vision_server_interface}statsum?format=json',
          dataType: 'json',
          crossDomain: true,
          success: function(data,status) {
            cameraIsOn = data.cameraIsOn;
          }
        });

        setTimeout(checkCamera,10000);

      }

      checkCamera();"

    else

      "<!-- no manta blinker -->"

    end

  end

  def self.sensor_data job, _request

    if Rails.env == 'development' && Bioturk::Application.config.vision_server_interface != ''

      begin
        # Get recording info from Manta
        manta_recordings_url = Bioturk::Application.config.vision_server_interface + "recordings?format=json"
        uri = URI(manta_recordings_url)
        res = Net::HTTP.get(uri)

        puts manta_recordings_url + " ==> " + res

        html = "<ul class='manta_data'>"
        steps = job.logs.select { |log| log.entry_type == "NEXT" }

        i = 1
        steps.each do |_step|
          html += "<li>#{i}</li>"
          i += 1
        end

        html += "</ul>"

        return html
      rescue
        "<!-- manta connection failed !>"
      end

    else

      "<!-- no manta data !>"

    end

  end

end
