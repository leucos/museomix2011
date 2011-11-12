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
  # the index action is called automatically when no other action is specified
  def index
    @title = 'Welcome to Ramaze!'
  end

  # the string returned at the end of the function is used as the html body
  # if there is no template for the action. if there is a template, the string
  # is silently ignored
  def notemplate
    @title = 'Welcome to Ramaze!'
    
    return 'There is no \'notemplate.xhtml\' associated with this action.'
  end
end

class AppController < MainController
  def start
    @title = "Start controller"
    exec('ssh pvincent@192.168.100.179 "DISPLAY=:0.0 python /home/pvincent/Programmation/PyMT/museotouch2/app/main.py -a"') if fork.nil?
  end
  
  def push
    
  end
end

class Photo < MainController
  def generate
  end
  
  def view
  end
end
