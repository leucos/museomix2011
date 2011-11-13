# Default url mappings are:
# 
# * a controller called Main is mapped on the root of the site: /
# * a controller called Something is mapped on: /something
# 
# If you want to override this, add a line like this inside the class:
#
#  map '/otherurl'
#
# this will force the controller to be mounted on: /otherurl.
class MainController < Controller
  #@@museotouch_command = 'ssh pvincent@192.168.100.181 "DISPLAY=:0.0 python /home/pvincent/Programmation/PyMT/museotouch2/app/main.py -a"'
  @@museotouch_command = 'ssh user@192.168.101.153 "DISPLAY=:0.0 /home/user/app/museotouch-remote.sh"'

  # the index action is called automatically when no other action is specified
  def index
    @title = 'Welcome to Ramaze!'
  end
end

class AppController < MainController
  def start
    @title = "Start controller"
    exec(@@museotouch_command) if fork.nil?
  end
  
  def push(id_auth, id_chair)
    r = Redis.new
    r.rpush('lemuriens.id_auth', id_auth)
    r.rpush('lemuriens.id_chair', id_chair)
  end
end

