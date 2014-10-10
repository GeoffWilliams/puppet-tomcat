
# side-by-side install of tomcat
tomcat { ["apache-tomcat-7.0.55", "apache-tomcat-7.0.56"]: }

# remove a specific version of tomcat
tomcat { "apache-tomcat-7.0.54":
  ensure => absent,
}
