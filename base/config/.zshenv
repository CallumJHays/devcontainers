
# activate the devel ros environments
if [ -f ~/lyro_ws/devel_isolated/setup.zsh ]; then
  source ~/lyro_ws/devel_isolated/setup.zsh

  function prompt_my_rosenv() {
    p10k segment -f 208 -t '(lyro_ws)'
  }
else # fallback to global
  source /opt/ros/melodic/setup.zsh

  function prompt_my_rosenv() {
    p10k segment -f 208 -t '(melodic)'
  }
fi

# for pip installs
export PATH=$PATH:~/.local/bin