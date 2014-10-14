#
# install a file into a tomcat instance directory based on a template
#
define tomcat::template_file($file_params, $file_key_map) {

  # Absolute path to the file we want to write
  $filename = $title

  # Corresponding key of file within the file_params map.  This will be
  # used to retrieve the parameters and template to use when creating
  # this file
  #
  # example: file "/var/lib/tomcat/myapp/bin/setenv.sh" uses the key
  # "/bin/setenv.sh" in the $file_params map.
  $key = $file_key_map[$filename]

  # once the key into the $file_params map has been obtained, use it
  # to lookup the correct (raw) file parameters
  $raw_params_hash = $file_params[$key]

  # the passed in parameters MUST include a value for template so that
  # it can be passed to the template function when creating the file
  if (! has_key($raw_params_hash, "template")) {
    notify { "raw hash $file_params": }
#    fail("Must supply value for template in parameter '${key}' in tomcat::instance")
  }

  #
  # build a complete has for ensure_resource()
  #
  #
  # ensure_resource() creates a resource from a hash and is part of stdlib
  # see reference at:  
  # https://forge.puppetlabs.com/puppetlabs/stdlib/readme#ensure_resource

  # We need to pass some extra parameters to the hash we pass to 
  # ensure_resource().
  #
  # ensure => file
  # set here to avoid having to do it for every hash
  # definition.  It needs to be set to allow the spec tests to pass
  # 
  # content => template(...) 
  # execute the template() function here and store the output of the compiled
  # .erb file in the hash.  There doesn't seem to be another way to do this
  # because variables the template relies on will be out of scope if called at
  # an earlier point such as within params.pp
  $extras_hash = {
    "ensure"  => file,
    "content" => template($raw_params_hash["template"]),
  }

  # We must remove the custom "template" parameter from the hash we send to
  # ensure_resource() or it will complain.  Delete is part of stdlib, reference:
  # https://forge.puppetlabs.com/puppetlabs/stdlib/readme#delete
  $params_hash = delete($raw_params_hash, "template")

  # merge our 'fixed' parameter list plus the extra parameters into one big
  # hash.  Merge is part of stdlib, reference: 
  # https://forge.puppetlabs.com/puppetlabs/stdlib/readme#merge
  $params =  merge($params_hash, $extras_hash)

  # use ensure_resource to create $filename using $params.  ensure_resource is
  # part of stdlib, reference: 
  # https://forge.puppetlabs.com/puppetlabs/stdlib/readme#ensure_resource
  ensure_resource("file", $filename, $params)
  
}
