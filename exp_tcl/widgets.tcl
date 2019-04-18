##########################################################################
# Useful functions for building tk interfaces

##########################################################################
##########################################################################
## Create entry/checkbutton/combobox and pack it into a
## simple grid. This can be used for making configuration forms.
## It came from fork_pulse program.
# w - entry widget name
# v - entry var name
# t - entry title

proc mk_entry {w v t} {
  if {[regexp {^pars(.*)$} $v]} { global pars}\
  else {global $v}
  entry $w -textvariable $v -width 12
  label ${w}_l -text $t
  grid ${w}_l ${w} -sticky nw
}
## Same for checkbutton
proc mk_check {w v t} {
  if {[regexp {^pars(.*)$} $v]} { global pars}\
  else {global $v}
  checkbutton $w -text $t -variable $v -bd 0 -highlightthickness 1
  grid $w -sticky nw -columnspan 2
}
## Same for combobox
proc mk_combo {w v t} {
  if {[regexp {^pars(.*)$} $v]} { global pars}\
  else {global $v}
  ttk::combobox $w -width 9 -textvariable $v
  label ${w}_l -text $t
  grid ${w}_l ${w} -sticky nw
}

##########################################################
# Change state of a widget with all its children (disabled or normal)
proc widget_state {widget state}  {
  if {[lsearch {Frame Labelframe Graph Menu Scrollbar} [winfo class $widget]] == -1} {
    $widget configure -state $state }
  foreach ch [winfo children $widget] { widget_state $ch $state}
}

# Set background color of a widget and all its children
proc widget_bg {widget bg} {
  foreach ch [winfo children $widget] { widget_bg $ch $bg }
  $widget configure -background $bg
  if {[lsearch {Checkbutton Entry} [winfo class $widget]] != -1} {
    $widget configure -highlightbackground $bg
  }
}

