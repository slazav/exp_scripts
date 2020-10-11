##########################################################################
# Useful functions for building tk interfaces

##########################################################################
##########################################################################
## Create entry/checkbutton/combobox and pack it into a
## simple grid. This can be used for making configuration forms.
## It came from fork_pulse program.
# w - widget path
# v - global var name or array element name
# t - title

## label
proc mk_label {w v t} {
  if {[regexp {^(.*)\(.*\)$} $v a arr]} {global $arr}\
  else {global $v}
  label $w -textvariable $v -width 12\
    -bd 1 -relief sunken -anchor w -fg #505050
  label ${w}_l -text $t
  grid ${w}_l ${w} -sticky nw
}
## entry
proc mk_entry {w v t} {
  if {[regexp {^(.*)\(.*\)$} $v a arr]} {global $arr}\
  else {global $v}
  entry $w -textvariable $v -width 12
  label ${w}_l -text $t
  grid ${w}_l ${w} -sticky nw
}
## checkbutton
proc mk_check {w v t} {
  if {[regexp {^(.*)\(.*\)$} $v a arr]} {global $arr}\
  else {global $v}
  checkbutton $w -text $t -variable $v -bd 0 -highlightthickness 1
  grid $w -sticky nw -columnspan 2
}
## combobox
proc mk_combo {w v t} {
  if {[regexp {^(.*)\(.*\)$} $v a arr]} {global $arr}\
  else {global $v}
  ttk::combobox $w -width 9 -textvariable $v
  label ${w}_l -text $t
  grid ${w}_l ${w} -sticky nw
}

##########################################################
## Entry element. Value is checked and
## applied after KeyReturn or FocusOut.
proc mk_entry_check {w v t vcmd} {
  entry $w -width 12 -validate key -vcmd "mk_entry_check_test $w %P \"$vcmd\""
  label ${w}_l -text $t
  grid ${w}_l ${w} -sticky nw
  mk_entry_check_apply $w $v $vcmd
  bind $w <Key-Return>  "mk_entry_check_apply $w $v \"$vcmd\""
  bind $w <FocusOut>    "mk_entry_check_apply $w $v \"$vcmd\""
  bind $w <ButtonPress> "$w configure -fg darkgreen"
}
proc mk_entry_check_apply {w v vcmd} {
  if {$vcmd eq {} || [{*}$vcmd [$w get]]} {
    set ::$v [$w get] }\
  else {
    $w delete 0 end;
    $w insert 0 [set ::$v]
  }
  $w configure -fg black
}
proc mk_entry_check_test {w val vcmd} {
  if {$vcmd eq {} || [{*}$vcmd $val]} { $w configure -fg darkgreen }\
  else { $w configure -fg darkred }
  return 1
}

##########################################################
# Make one of the above widgets according with type parameter.
proc mk_conf_el {type w v t} {
  switch -exact -- $type {
    const  {mk_label $w $v $t}
    bool   {mk_check $w $v $t}
    string {mk_entry_check $w $v $t {}}
    int    {mk_entry_check $w $v $t {regexp {^\s*\[+-\]?\[0-9\]+\s*$}}}
    float  {mk_entry_check $w $v $t {string is double}}
    default {
       mk_combo $w $v $t
       $w configure -values $type
    }
  }
}

# Make frame with a few elements:
# wid - widget name, sub elements will be "wid.<name>"
# arr - array name, variables will be "arr(<name>)"
# desc - {{<name> <type> <title>}}
proc mk_conf {wid arr desc} {
  frame $wid
  foreach d $desc {
    set name  [lindex $d 0]
    set type  [lindex $d 1]
    set title [lindex $d 2]
    mk_conf_el $type "$wid.$name" "${arr}($name)" $title
  }
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

