dir = File.dirname(__FILE__)

require dir + "/helper"

FileUtils.remove_dir(dir + "/../index/test", true)

with_steps_for(:hand_over, :login, :inventory) do
  run_local_story "./text/hand_over_story", :type => RailsStory
end