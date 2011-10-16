require 'asakusa_satellite/hook'
class AsakusaSatellite::Hook::ASAndroidNotifier < AsakusaSatellite::Hook::Listener

  def after_create_message(context)
    message = context[:message]
    room = context[:room]

    text = "#{message.user.name} / #{message.body}"[0,150]

    members = room.members - [ message.user ]
    devices = members.map {|user|
      user.devices
    }.flatten

    android = devices.select {|device|
      device.device_type == 'android'
    }

    android.to_a.map{|device|
      { :registration_id => device.name,
        :data => {
          :message => text,
          :id => room.id
        }
      }
    }.tap{|xs|
      C2DM.send_notifications(ENV[:android_mail_address],
        ENV[:android_password],
        xs,
        ENV[:android_application_name])
    }

  end

end
