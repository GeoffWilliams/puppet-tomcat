
# Create a tomcat instance
tomcat::instance { "myapp_dev":
    instance_user => "tomcat",
    https_port    => "8080",
    http_port     => "8081",
    jmx_port      => "8088",
    shutdown_port => "8089",
    jmx_enabled   => true,
}

# Create a tomcat instance
tomcat::instance { "myotherapp_prod":
    instance_user => "tomcat",
    https_port    => "8090",
    http_port     => "8091",
    jmx_port      => "8098",
    shutdown_port => "8099",
    jmx_enabled   => true,
}

