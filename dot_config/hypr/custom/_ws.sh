current_ws=$(hyprctl activeworkspace -j | jq -r ".id")
if [ "$current_ws" -eq "$1" ]; then
  hyprctl dispatch workspace previous
else
  hyprctl dispatch workspace "$1"
fi
