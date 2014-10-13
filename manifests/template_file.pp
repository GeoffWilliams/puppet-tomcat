#
# install a file into a tomcat instance directory based on a template
#
#
# Example
# tomcat::template_file { "/var/tomcat/instances/myapp/bin/setenv.sh":
#   templates => $templates,
#   file_key_map => { "/var/tomcat/instances/myapp/bin/setenv.sh" => 
#                       "tomcat/bin/setenv.sh.erb" }
# }

define tomcat::template_file($templates, $file_key_map) {

  # Absolute path to the file we want to write
  $filename = $title

  # Corresponding key of fie within the templates map.  This is how
  # we determine the correct template to use.
  # example: file "/var/lib/tomcat/myapp/bin/setenv.sh" uses the key
  # "/bin/setenv.sh" in the $templates map.
  $template_key = $file_key_map[$filename]

  # once the key into the $templates map has been obtained, use it
  # to lookup the correct template file to use
  $template_file = $templates[$template_key]


  # Finally, create the file from the template
  file { $filename:
    ensure  => file,
    content => template($template_file),
  }
}
